/// IoT 示例应用
/// 作者: 罗耀生
/// 日期: 2025-12-14

import 'package:flutter/material.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 SDK
  final sdk = IoTSdk(config: IoTConfig.development());
  await sdk.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT 示例',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: IoTSdk.instance.isLoggedIn
          ? const DeviceListPage()
          : const LoginPage(),
    );
  }
}

/// 登录页面
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入用户名和密码')),
      );
      return;
    }

    setState(() => _loading = true);

    final success = await IoTSdk.instance.login(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    setState(() => _loading = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DeviceListPage()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录失败，请检查用户名和密码')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IoT 平台登录')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.devices_other, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '用户名',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密码',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

/// 设备列表页面
class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  List<Device> _devices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _loading = true);

    final result = await IoTSdk.instance.device.getDeviceList();
    if (result.isSuccess && result.data != null) {
      setState(() {
        _devices = result.data!.list;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: ${result.message}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await IoTSdk.instance.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的设备'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDevices,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _devices.isEmpty
              ? const Center(child: Text('暂无设备'))
              : RefreshIndicator(
                  onRefresh: _loadDevices,
                  child: ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return DeviceCard(
                        device: device,
                        onTap: () => _openDeviceDetail(device),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showActivateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openDeviceDetail(Device device) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceDetailPage(device: device),
      ),
    );
  }

  void _showActivateDialog() {
    final productKeyController = TextEditingController();
    final deviceSNController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('激活设备'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: productKeyController,
              decoration: const InputDecoration(labelText: 'Product Key'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: deviceSNController,
              decoration: const InputDecoration(labelText: '设备序列号'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await IoTSdk.instance.device.activateDevice(
                productKey: productKeyController.text,
                deviceSN: deviceSNController.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                if (result.isSuccess) {
                  _loadDevices();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('设备激活成功')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('激活失败: ${result.message}')),
                  );
                }
              }
            },
            child: const Text('激活'),
          ),
        ],
      ),
    );
  }
}

/// 设备卡片
class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.developer_board,
          color: device.isOnline ? Colors.green : Colors.grey,
          size: 40,
        ),
        title: Text(device.name ?? device.deviceId),
        subtitle: Text('状态: ${device.status.value}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// 设备详情页面
class DeviceDetailPage extends StatefulWidget {
  final Device device;

  const DeviceDetailPage({super.key, required this.device});

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  Map<String, DeviceProperty> _properties = {};
  bool _mqttConnected = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    _connectMqtt();
  }

  Future<void> _loadProperties() async {
    setState(() => _loading = true);
    final result = await IoTSdk.instance.device.getDeviceProperties(
      widget.device.deviceId,
    );
    if (result.isSuccess && result.data != null) {
      setState(() {
        _properties = result.data!;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _connectMqtt() async {
    final connected = await IoTSdk.instance.connectDevice(widget.device);
    setState(() => _mqttConnected = connected);

    // 监听消息
    IoTSdk.instance.mqtt?.messageStream.listen((message) {
      if (message.messageType == IoTMessageType.propertyReport) {
        _loadProperties();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name ?? widget.device.deviceId),
        actions: [
          Icon(
            _mqttConnected ? Icons.cloud_done : Icons.cloud_off,
            color: _mqttConnected ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProperties,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildInfoSection(),
                  const SizedBox(height: 16),
                  _buildPropertiesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('设备信息', style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
            const Divider(),
            _buildInfoRow('设备ID', widget.device.deviceId),
            _buildInfoRow('Product Key', widget.device.productKey),
            _buildInfoRow('状态', widget.device.status.value),
            _buildInfoRow('最后在线', widget.device.lastOnlineAt?.toString() ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildPropertiesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('设备属性', style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
            const Divider(),
            if (_properties.isEmpty)
              const Text('暂无属性数据', style: TextStyle(color: Colors.grey))
            else
              ..._properties.entries.map((e) => _buildPropertyRow(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyRow(String key, DeviceProperty prop) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(prop.value.toString()),
              Text(
                prop.reportedAt.toString().substring(0, 19),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    IoTSdk.instance.disconnectDevice();
    super.dispose();
  }
}
