/// Open IoT Platform - 移动端配置应用
/// 主入口文件
/// 作者: 罗耀生
/// 日期: 2026-01-13

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/app_router.dart';
import 'core/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Config',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

// ==================== 数据模型 ====================

/// 设备类型枚举
enum DeviceType {
  servo('舵机开关'),
  wakeup('USB唤醒');

  final String label;
  const DeviceType(this.label);
}

/// 设备状态枚举
enum DeviceStatus {
  online('在线', Colors.green),
  offline('离线', Colors.grey),
  configuring('配置中', Colors.orange);

  final String label;
  final Color color;
  const DeviceStatus(this.label, this.color);
}

/// 设备模型
class Device {
  String id;
  String name;
  DeviceType type;
  DeviceStatus status;
  String? firmware;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.firmware,
  });
}

// ==================== 模拟数据存储 ====================

class MockData {
  static final List<Device> _devices = [
    Device(
      id: 'device_001',
      name: '客厅开关',
      type: DeviceType.servo,
      status: DeviceStatus.online,
      firmware: '1.0.0',
    ),
    Device(
      id: 'device_002',
      name: '电脑唤醒',
      type: DeviceType.wakeup,
      status: DeviceStatus.online,
      firmware: '1.0.0',
    ),
  ];

  static List<Device> get devices => List.from(_devices);

  static void addDevice(Device device) {
    _devices.add(device);
  }

  static void removeDevice(String id) {
    _devices.removeWhere((d) => d.id == id);
  }

  static void updateDevice(String id, {String? name, DeviceStatus? status}) {
    final device = _devices.firstWhere((d) => d.id == id);
    if (name != null) device.name = name;
    if (status != null) device.status = status;
  }
}

// ==================== 启动页 ====================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 检查登录状态（演示：直接跳转设备列表）
    final isLoggedIn = false;

    if (isLoggedIn) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.deviceList);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.devices_other,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Open IoT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3A3C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Platform',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 登录页 ====================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.devices_other,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Open IoT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A3A3C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '欢迎回来，请登录',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: '邮箱',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: '密码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                      child: const Text('忘记密码？'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _handleLogin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('登 录'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '还没有账号？',
                        style: TextStyle(color: Color(0xFF8E8E93)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.register),
                        child: const Text('立即注册'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 服务器设置按钮
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFF8E8E93)),
                onPressed: () => _showServerSettings(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    // 演示：直接跳转设备列表
    Navigator.of(context).pushReplacementNamed(AppRoutes.deviceList);
  }

  void _showServerSettings(BuildContext context) {
    final urlController = TextEditingController(text: 'https://iot.example.com');
    final portController = TextEditingController(text: '443');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('服务器设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: '服务器地址',
                hintText: 'https://iot.example.com',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: portController,
              decoration: const InputDecoration(
                labelText: '端口',
                hintText: '443',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 保存服务器配置
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('服务器设置已保存')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

// ==================== 注册页 ====================

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('注册'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                '创建新账号',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3A3C),
                ),
              ),
              const SizedBox(height: 32),
              const TextField(
                decoration: InputDecoration(
                  labelText: '邮箱',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '确认密码',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('注 册'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 忘记密码页 ====================

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('忘记密码'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '找回密码',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3A3C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '请输入您的注册邮箱，我们将发送密码重置链接。',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                '邮箱',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3A3A3C),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: '请输入邮箱',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('发送重置链接'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入邮箱')),
      );
      return;
    }

    // TODO: 实际发送逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('重置链接已发送')),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.of(context).pop();
    });
  }
}

// ==================== 主页（带TabBar）====================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Device> _devices = MockData.devices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDeviceListPage(),
          _buildSettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            activeIcon: Icon(Icons.devices),
            label: '设备',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        selectedItemColor: const Color(0xFF007AFF),
        unselectedItemColor: const Color(0xFFC7C7CC),
      ),
    );
  }

  Widget _buildDeviceListPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的设备'),
      ),
      body: _devices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.devices, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('暂无设备'),
                  const SizedBox(height: 8),
                  Text(
                    '点击右下角添加设备',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  return _DeviceCard(
                    device: device,
                    onTap: () => _openDevice(device),
                    onLongPress: () => _showDeviceMenu(device),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.scan),
        backgroundColor: const Color(0xFF007AFF),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 40),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('用户', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('user@example.com', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: const Icon(Icons.dns),
                title: const Text('服务器设置'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showServerSettings(),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text('关于'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _logout(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('退出登录'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDevice(Device device) {
    Navigator.of(context).pushNamed(
      AppRoutes.control,
      arguments: {'deviceId': device.id, 'deviceName': device.name},
    );
  }

  void _showDeviceMenu(Device device) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('修改名称'),
              onTap: () {
                Navigator.pop(context);
                _editDeviceName(device);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除设备', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(device);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _editDeviceName(Device device) {
    final controller = TextEditingController(text: device.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改设备名称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入设备名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                MockData.updateDevice(device.id, name: controller.text);
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('设备名称已修改')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除设备'),
        content: Text('确定要删除「${device.name}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              MockData.removeDevice(device.id);
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设备已删除')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  void _showServerSettings() {
    final urlController = TextEditingController(text: 'https://iot.example.com');
    final portController = TextEditingController(text: '443');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('服务器设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: '服务器地址',
                hintText: 'https://iot.example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: portController,
              decoration: const InputDecoration(
                labelText: '端口',
                hintText: '443',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 保存服务器配置到本地存储
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('服务器设置已保存')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

/// 设备卡片
class _DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _DeviceCard({
    required this.device,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: device.status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  device.type == DeviceType.servo ? Icons.toggle_on : Icons.usb,
                  size: 28,
                  color: device.status.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.status.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: device.status.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 设备列表页（兼容路由）====================

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}

// ==================== 扫码配网页 ====================

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    // 模拟扫描过程
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _scanning = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('添加设备'),
      ),
      body: _scanning
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在扫描附近的设备...'),
                ],
              ),
            )
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '发现以下设备',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                _DeviceItem(
                  name: 'IoT-Switch-A1B2',
                  type: DeviceType.servo,
                  onTap: () => _goToConfig('IoT-Switch-A1B2', DeviceType.servo),
                ),
                _DeviceItem(
                  name: 'IoT-Wakeup-C3D4',
                  type: DeviceType.wakeup,
                  onTap: () => _goToConfig('IoT-Wakeup-C3D4', DeviceType.wakeup),
                ),
              ],
            ),
    );
  }

  void _goToConfig(String deviceId, DeviceType type) {
    Navigator.of(context).pushNamed(
      AppRoutes.config,
      arguments: {'deviceId': deviceId, 'type': type},
    );
  }
}

class _DeviceItem extends StatelessWidget {
  final String name;
  final DeviceType type;
  final VoidCallback onTap;

  const _DeviceItem({
    required this.name,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            type == DeviceType.servo ? Icons.toggle_on : Icons.usb,
            size: 28,
            color: Colors.blue,
          ),
        ),
        title: Text(name),
        subtitle: Text(type.label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ==================== WiFi配置页 ====================

class ConfigScreen extends StatefulWidget {
  final Map<String, dynamic>? deviceInfo;

  const ConfigScreen({super.key, this.deviceInfo});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _nameController = TextEditingController();
  final _wifiController = TextEditingController(text: 'MyHome_5G');
  final _passwordController = TextEditingController();

  // 配网状态: 'form' | 'configuring' | 'success' | 'error'
  String _configState = 'form';
  int _configStep = 0;
  String _configMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.deviceInfo != null) {
      final deviceId = widget.deviceInfo!['deviceId'] as String?;
      _nameController.text = deviceId ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wifiController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _configState == 'form'
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(_getConfigTitle()),
      ),
      body: _buildBody(),
    );
  }

  String _getConfigTitle() {
    switch (_configState) {
      case 'form':
        return '配置设备';
      case 'configuring':
        return '配置中';
      case 'success':
        return '配置成功';
      case 'error':
        return '配置失败';
      default:
        return '配置设备';
    }
  }

  Widget _buildBody() {
    switch (_configState) {
      case 'form':
        return _buildForm();
      case 'configuring':
        return _buildProgress();
      case 'success':
        return _buildSuccess();
      case 'error':
        return _buildError();
      default:
        return _buildForm();
    }
  }

  /// 表单页面
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 设备信息卡片
          if (widget.deviceInfo != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.deviceInfo!['type'] == DeviceType.servo
                          ? Icons.toggle_on
                          : Icons.usb,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '扫描到设备',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          widget.deviceInfo!['deviceId'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          widget.deviceInfo!['type'] == DeviceType.servo
                              ? '舵机开关'
                              : 'USB唤醒设备',
                          style: const TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),

          // 设备名称
          const Text(
            '设备名称',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '请输入设备名称，如：客厅开关',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 32),

          // WiFi 配置标题
          const Text(
            'WiFi 配置',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),

          // WiFi 网络
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListTile(
              leading: const Icon(Icons.wifi),
              title: const Text('WiFi 网络'),
              subtitle: Text(_wifiController.text),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showWifiDialog,
            ),
          ),
          const SizedBox(height: 16),

          // WiFi 密码
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'WiFi 密码',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 32),

          // 开始配置按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _startConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('开始配置'),
            ),
          ),
        ],
      ),
    );
  }

  /// 配网进度页面
  Widget _buildProgress() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 进度指示器
            _buildStepIndicator(),
            const SizedBox(height: 48),
            // 状态文本
            Text(
              _configMessage,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  /// 步骤指示器
  Widget _buildStepIndicator() {
    final steps = [
      {'label': '连接设备', 'icon': Icons.bluetooth},
      {'label': '发送配置', 'icon': Icons.send},
      {'label': 'WiFi连接', 'icon': Icons.wifi},
      {'label': '激活设备', 'icon': Icons.check_circle},
    ];

    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            final isCompleted = index < _configStep;
            final isCurrent = index == _configStep;
            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? const Color(0xFF34C759)
                          : isCurrent
                              ? const Color(0xFF007AFF)
                              : Colors.grey[300],
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : isCurrent
                            ? Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.all(6),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                  ),
                  if (index < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index < _configStep
                            ? const Color(0xFF34C759)
                            : Colors.grey[300],
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(steps.length, (index) {
            return Expanded(
              child: Center(
                child: Text(
                  steps[index]['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: index <= _configStep ? Colors.grey[700] : Colors.grey[300],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// 配置成功页面
  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF34C759),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              '配置成功！',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '「${_nameController.text}」已添加到设备列表',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _finishConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                ),
                child: const Text('完成'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 配置失败页面
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              '配置失败',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _configMessage,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _configState = 'form';
                      });
                    },
                    child: const Text('重新配置'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('取消'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWifiDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择 WiFi 网络'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('MyHome_5G'),
              trailing: const Icon(Icons.signal_wifi_4_bar, color: Colors.green),
              onTap: () {
                _wifiController.text = 'MyHome_5G';
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('MyHome_2.4G'),
              trailing: const Icon(Icons.wifi, color: Colors.orange),
              onTap: () {
                _wifiController.text = 'MyHome_2.4G';
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Office_WiFi'),
              trailing: const Icon(Icons.wifi, color: Colors.grey),
              onTap: () {
                _wifiController.text = 'Office_WiFi';
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startConfig() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入设备名称')),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入WiFi密码')),
      );
      return;
    }

    setState(() => _configState = 'configuring');

    // 模拟配网流程
    final steps = [
      {'step': 0, 'message': '正在连接设备...'},
      {'step': 1, 'message': '正在发送配置...'},
      {'step': 2, 'message': '等待设备连接 WiFi...'},
      {'step': 3, 'message': '正在激活设备...'},
    ];

    for (var step in steps) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _configStep = step['step'] as int;
          _configMessage = step['message'] as String;
        });
      }
    }

    // 配置完成
    await Future.delayed(const Duration(milliseconds: 500));

    // 添加设备到列表
    final type = widget.deviceInfo?['type'] as DeviceType? ?? DeviceType.servo;
    final newDevice = Device(
      id: 'device_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      type: type,
      status: DeviceStatus.online,
      firmware: '1.0.0',
    );
    MockData.addDevice(newDevice);

    if (mounted) {
      setState(() => _configState = 'success');
    }
  }

  void _finishConfig() {
    // 返回到设备列表（两级返回：config -> scan -> deviceList）
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
}

// ==================== 设备控制页 ====================

class ControlScreen extends StatefulWidget {
  final String deviceId;

  const ControlScreen({super.key, required this.deviceId});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  Device? _device;

  @override
  void initState() {
    super.initState();
    _loadDevice();
  }

  void _loadDevice() {
    final devices = MockData.devices;
    _device = devices.firstWhere(
      (d) => d.id == widget.deviceId,
      orElse: () => Device(
        id: widget.deviceId,
        name: '未知设备',
        type: DeviceType.servo,
        status: DeviceStatus.offline,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_device == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_device!.name),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud_done, color: _device!.status.color),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'rename') {
                _editDeviceName();
              } else if (value == 'delete') {
                _confirmDelete();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Text('修改名称')),
              const PopupMenuItem(value: 'delete', child: Text('删除设备')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 状态卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _device!.status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_device!.status.label}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _device!.status.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '固件: ${_device!.firmware ?? "未知"}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 控制面板
            Expanded(
              child: _buildControlPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    if (_device!.type == DeviceType.servo) {
      return _ServoControlPanel(device: _device!);
    } else {
      return _UsbWakeupControlPanel(device: _device!);
    }
  }

  void _editDeviceName() {
    final controller = TextEditingController(text: _device!.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改设备名称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入设备名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                MockData.updateDevice(_device!.id, name: controller.text);
                _loadDevice();
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('设备名称已修改')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除设备'),
        content: Text('确定要删除「${_device!.name}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              MockData.removeDevice(_device!.id);
              Navigator.of(context).pop(); // 关闭对话框
              Navigator.of(context).pop(); // 返回列表
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 舵机控制面板
class _ServoControlPanel extends StatefulWidget {
  final Device device;

  const _ServoControlPanel({required this.device});

  @override
  State<_ServoControlPanel> createState() => _ServoControlPanelState();
}

class _ServoControlPanelState extends State<_ServoControlPanel> {
  String _position = 'middle';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '舵机控制',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        // 位置指示
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Positioned(
                left: _position == 'up' ? 20 : _position == 'middle' ? null : 20,
                right: _position == 'down' ? 20 : _position == 'middle' ? null : 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 控制按钮
        Row(
          children: [
            Expanded(
              child: _ControlButton(
                label: '上',
                selected: _position == 'up',
                onTap: () => setState(() => _position = 'up'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ControlButton(
                label: '中',
                selected: _position == 'middle',
                onTap: () => setState(() => _position = 'middle'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ControlButton(
                label: '下',
                selected: _position == 'down',
                onTap: () => setState(() => _position = 'down'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 脉冲触发
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('脉冲触发成功')),
              );
            },
            icon: const Icon(Icons.bolt),
            label: const Text('脉冲触发'),
          ),
        ),
      ],
    );
  }
}

/// USB唤醒控制面板
class _UsbWakeupControlPanel extends StatelessWidget {
  final Device device;

  const _UsbWakeupControlPanel({required this.device});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'USB唤醒控制',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        // 触发按钮
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('唤醒信号已发送')),
                );
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.power_settings_new, size: 64, color: Color(0xFF007AFF)),
                  SizedBox(height: 16),
                  Text('点击唤醒', style: TextStyle(fontSize: 18)),
                  Text('电脑将立即启动', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('定时唤醒设置')),
              );
            },
            icon: const Icon(Icons.schedule),
            label: const Text('定时唤醒'),
          ),
        ),
      ],
    );
  }
}

/// 控制按钮
class _ControlButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ControlButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF007AFF) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== 设置页 ====================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('设置'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 40),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('用户', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('user@example.com', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: const Icon(Icons.dns),
                title: const Text('服务器设置'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showServerSettings(),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text('关于'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('退出登录'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  void _showServerSettings() {
    final urlController = TextEditingController(text: 'https://iot.example.com');
    final portController = TextEditingController(text: '443');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('服务器设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: '服务器地址',
                hintText: 'https://iot.example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: portController,
              decoration: const InputDecoration(
                labelText: '端口',
                hintText: '443',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 保存服务器配置到本地存储
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('服务器设置已保存')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

// ==================== 关于页 ====================

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final List<LinkItem> _links = [
    LinkItem(
      label: '项目落地页',
      url: 'https://open.iot.i2kai.com',
      icon: Icons.language,
    ),
    LinkItem(
      label: '个人主页',
      url: 'https://i2kai.com',
      icon: Icons.person,
    ),
    LinkItem(
      label: 'Gitee 仓库',
      url: 'https://gitee.com/luo-yao-sheng/open-iot-platform',
      icon: Icons.code,
    ),
    LinkItem(
      label: 'GitHub 仓库',
      url: 'https://github.com/luoyaosheng/open-iot-platform',
      icon: Icons.code,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('关于'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.devices_other,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Open IoT Platform',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '版本 1.0.0',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // 链接列表
            Card(
              child: Column(
                children: _links.map((link) => _buildLinkItem(context, link)).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // 公众号信息（点击复制）
            Card(
              child: InkWell(
                onTap: () => _copyToClipboard('落落在厦', '公众号名称'),
                child: const ListTile(
                  leading: Icon(Icons.chat_bubble),
                  title: Text('公众号'),
                  subtitle: Text('落落在厦'),
                  trailing: Icon(Icons.copy, size: 16),
                ),
              ),
            ),

            const SizedBox(height: 48),
            Center(
              child: Text(
                '© 2026 罗耀生',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(BuildContext context, LinkItem link) {
    return InkWell(
      onTap: () => _launchUrl(link.url),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(link.icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(link.label, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Icon(Icons.open_in_new, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无法打开 $url')),
        );
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    // TODO: 使用 flutter/services 的 ClipboardData
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已复制 $label')),
    );
  }
}

class LinkItem {
  final String label;
  final String url;
  final IconData icon;

  LinkItem({
    required this.label,
    required this.url,
    required this.icon,
  });
}
