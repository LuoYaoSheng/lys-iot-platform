/// 启动页 - Token 检查与自动登录
/// 作者: 罗耀生
/// 日期: 2025-12-15
/// 更新: 2025-12-16 - 注册401自动跳转回调

import 'package:flutter/material.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import 'login_page.dart';
import 'home_page.dart';
import '../main.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _status = '正在初始化...';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 初始化 SDK - 自动根据构建配置选择环境
      // flutter run --dart-define=ENV=development  (本地调试)
      // flutter run --dart-define=ENV=natapp       (真机调试，默认)
      // flutter run (不指定则使用 natapp)
      final sdk = IoTSdk(config: IoTConfig.fromEnvironment());

      // 注册401未认证回调 - 自动跳转登录页
      sdk.setOnUnauthorized(() async {
        print('[401处理] 检测到未认证，准备跳转登录页');

        // 清除用户会话
        await sdk.logout();

        // 使用全局导航器跳转到登录页
        final context = navigatorKey.currentContext;
        if (context != null && navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );

          // 显示提示
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('登录已过期，请重新登录'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });

      setState(() {
        _status = '正在检查登录状态...';
      });

      // 尝试恢复会话
      final hasSession = await sdk.initialize();

      if (!mounted) return;

      if (hasSession) {
        // 已登录，进入主页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // 未登录，进入登录页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      setState(() {
        _status = '初始化失败: \$e';
      });

      // 延迟后进入登录页
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.devices_other,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // 应用名称
            Text(
              'IoT 智能设备',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '设备配网与控制',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),

            // 加载指示器
            const CircularProgressIndicator(),
            const SizedBox(height: 16),

            // 状态文字
            Text(
              _status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
