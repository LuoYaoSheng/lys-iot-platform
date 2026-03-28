// IoT 智能开关配网 APP
// 作者: 罗耀生
// 日期: 2025-12-13
// 更新: 2025-12-15 - 集成 SDK，添加登录注册功能
// 更新: 2025-12-16 - 添加401自动跳转登录页，支持自定义API地址

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/device_provider.dart';
import 'pages/scan_page.dart';
import 'pages/device_list_page.dart';
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
      mqttPort: customMqttPort ?? 48883,
      enableLogging: true,
    );
  } else {
    // 使用默认配置
    config = IoTConfig.fromEnvironment();
  }

  // 初始化SDK
  final sdk = IoTSdk(config: config);
  await sdk.initialize();

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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const SplashPage(),  // 改为启动页
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DeviceListPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT 智能设备'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DeviceProvider>().loadDevices();
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.devices),
            selectedIcon: Icon(Icons.devices),
            label: '设备',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('添加设备'),
            )
          : null,
    );
  }
}

/// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currentApiUrl = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  Future<void> _loadCurrentConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customApiUrl = prefs.getString('custom_api_url');

      if (mounted) {
        setState(() {
          _currentApiUrl = customApiUrl ?? IoTConfig.fromEnvironment().apiBaseUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentApiUrl = IoTConfig.fromEnvironment().apiBaseUrl;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await IoTSdk.instance.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  void _showServerConfigInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('服务器配置说明'),
          ],
        ),
        content: const Text(
          '服务器地址需要在登录页面进行配置：\n\n'
          '1. 退出登录\n'
          '2. 在登录页面点击右上角的服务器图标\n'
          '3. 输入新的服务器地址\n'
          '4. 应用会自动重启并应用新配置\n\n'
          '注意：修改服务器地址后需要重新登录。',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = IoTSdk.instance.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 用户信息卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text(
                      '账号信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow('用户名', user?.username ?? '未登录'),
                _buildInfoRow('邮箱', user?.email ?? '-'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 服务器配置卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.dns, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text(
                      '服务器配置',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow('API 服务器', _currentApiUrl.isNotEmpty ? _currentApiUrl : '加载中...'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '服务器地址在登录页面统一配置，\n配网时会自动使用该地址。',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showServerConfigInfo,
                    icon: const Icon(Icons.help_outline),
                    label: const Text('如何修改服务器地址？'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 关于卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text(
                      '关于',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow('应用名称', 'IoT 智能设备配网'),
                _buildInfoRow('版本', '1.0.0'),
                _buildInfoRow('作者', '罗耀生'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 退出登录按钮
        FilledButton.icon(
          onPressed: _logout,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('退出登录'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value),
        ],
      ),
    );
  }
}
