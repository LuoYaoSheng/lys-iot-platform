/// IoT 智能开关配网 APP
/// 作者: 罗耀生
/// 日期: 2025-12-13
/// 更新: 2025-12-15 - 集成 SDK，添加登录注册功能
/// 更新: 2025-12-16 - 添加401自动跳转登录页，支持自定义API地址
/// 更新: 2025-01-12 - 使用新的 TabBar 主页和个人中心页

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/minimal_theme.dart';
import 'providers/device_provider.dart';
import 'pages/scan_page.dart';
import 'pages/home_page.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';

// 全局导航器键，用于401自动跳转
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 从SharedPreferences读取自定义配置
  final prefs = await SharedPreferences.getInstance();
  final customApiUrl = prefs.getString('custom_api_url');
  final customMqttHost = prefs.getString('custom_mqtt_host');
  final customMqttPort = prefs.getInt('custom_mqtt_port');

  // 初始化SDK配置
  IoTConfig config;
  if (customApiUrl != null && customApiUrl.isNotEmpty) {
    // 使用自定义配置，MQTT 地址自动从 API URL 推导
    String mqttHost = customMqttHost ?? 'localhost';

    // 如果没有保存的 MQTT 地址，尝试从 API URL 提取
    if (customMqttHost == null || customMqttHost.isEmpty) {
      try {
        final uri = Uri.parse(customApiUrl);
        mqttHost = uri.host;
      } catch (e) {
        mqttHost = 'localhost';
      }
    }

    config = IoTConfig(
      apiBaseUrl: customApiUrl,
      mqttHost: mqttHost,
      mqttPort: customMqttPort ?? 42883,
      enableLogging: true,
    );
  } else {
    // 使用默认配置
    config = IoTConfig.fromEnvironment();
  }

  // 初始化SDK（只创建实例，不调用 initialize，由 SplashPage 统一处理）
  IoTSdk(config: config);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceProvider(),
      child: MaterialApp(
        title: 'IoT 智能设备',
        navigatorKey: navigatorKey,  // 设置全局导航器键
        theme: MinimalLightTheme.data,
        home: const SplashPage(),  // 改为启动页
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
