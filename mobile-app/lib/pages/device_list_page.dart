// 设备列表页面
// 作者: 罗耀生
// 日期: 2025-12-13
// 更新: 2025-12-15 - 使用 SDK Device 模型
// 更新: 2025-12-19 - v0.2.0 根据产品信息显示图标和名称，使用BottomSheet控制面板

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/device_provider.dart';
import '../services/api_service.dart';
import '../widgets/control_panels/control_panel_factory.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  // 存储设备位置状态
  final Map<String, String> _devicePositions = {};
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final provider = context.read<DeviceProvider>();
      await _loadAPICredentials();
      if (!mounted) return;
      await provider.loadDevices();
      if (!mounted) return;
      await _loadDevicePositions();
    });
  }

  Future<void> _loadAPICredentials() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载自定义 API 地址（如果有）
    final customApiUrl = prefs.getString('custom_api_url');
    if (customApiUrl != null && customApiUrl.isNotEmpty) {
      _apiService.setBaseUrl(customApiUrl);
    }

    // 优先使用 Bearer Token
    final token = prefs.getString('iot_token');
    if (token != null && token.isNotEmpty) {
      _apiService.setBearerToken(token);
    } else {
      // 降级使用 API Key
      final apiKey = prefs.getString('api_key');
      final apiSecret = prefs.getString('api_secret');
      if (apiKey != null && apiSecret != null) {
        _apiService.setAPIKey(apiKey, apiSecret);
      }
    }
  }

  Future<void> _loadDevicePositions() async {
    final provider = context.read<DeviceProvider>();
    for (final device in provider.devices) {
      final response = await _apiService.getDeviceStatus(device.deviceId);
      if (!mounted) return;
      if (response.isSuccess && response.data != null) {
        setState(() {
          _devicePositions[device.deviceId] = response.data!['position'] ?? 'middle';
        });
      }
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadDevices();
            await _loadDevicePositions();
          },
          child: _buildContent(provider),
        );
      },
    );
  }

  Widget _buildContent(DeviceProvider provider) {
    if (provider.isLoading && provider.devices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('加载失败', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(provider.error!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: () => provider.loadDevices(), icon: const Icon(Icons.refresh), label: const Text('重试')),
          ],
        ),
      );
    }

    if (provider.devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('暂无设备', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text('请添加新设备', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.devices.length,
      itemBuilder: (context, index) {
        final device = provider.devices[index];
        final position = _devicePositions[device.deviceId] ?? 'middle';
        return _DeviceCard(
          device: device,
          position: position,
          onTap: () => _onDeviceTap(device),
          onDelete: () => _onDeviceDelete(device, provider),
        );
      },
    );
  }

  void _onDeviceTap(Device device) {
    // v0.2.0: 使用 BottomSheet 方式显示控制面板
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 顶部拖动指示器
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // 设备标题
                  _buildDeviceHeader(device),
                  const Divider(height: 32),
                  // 动态控制面板
                  ControlPanelFactory.createPanel(
                    device: device,
                    apiService: _apiService,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建设备标题
  Widget _buildDeviceHeader(Device device) {
    final icon = ControlPanelFactory.getPanelIcon(device);
    final color = ControlPanelFactory.getPanelColor(device);
    final title = ControlPanelFactory.getPanelTitle(device);

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: device.isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    device.isOnline ? '在线' : '离线',
                    style: TextStyle(
                      fontSize: 14,
                      color: device.isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    device.deviceId,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onDeviceDelete(Device device, DeviceProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除设备'),
        content: Text('确定要删除设备 "${device.name ?? device.deviceId}" 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.deleteDevice(device.deviceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? '设备已删除' : '删除失败')),
        );
      }
    }
  }
}

class _DeviceCard extends StatelessWidget {
  final Device device;
  final String position;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DeviceCard({
    required this.device,
    required this.position,
    required this.onTap,
    required this.onDelete,
  });

  String get _statusText {
    switch (device.status) {
      case DeviceStatus.online: return '在线';
      case DeviceStatus.offline: return '离线';
      case DeviceStatus.disabled: return '已禁用';
      case DeviceStatus.inactive: return '未激活';
    }
  }

  Color get _statusColor {
    switch (device.status) {
      case DeviceStatus.online: return Colors.green;
      case DeviceStatus.offline: return Colors.grey;
      case DeviceStatus.disabled: return Colors.red;
      case DeviceStatus.inactive: return Colors.orange;
    }
  }

  String get _positionText {
    switch (position) {
      case 'up': return '位置: 上';
      case 'down': return '位置: 下';
      case 'middle': return '位置: 中';
      default: return '位置: 中';
    }
  }

  /// v0.2.0: 根据产品信息获取图标
  IconData get _productIcon {
    final iconName = device.product?.iconName;
    if (iconName == null) return Icons.power_settings_new; // 默认图标

    // Material Icons 映射表
    switch (iconName) {
      case 'power_settings_new': return Icons.power_settings_new;
      case 'touch_app': return Icons.touch_app;
      case 'thermostat': return Icons.thermostat;
      case 'lock': return Icons.lock;
      case 'lightbulb': return Icons.lightbulb;
      case 'curtains': return Icons.curtains;
      case 'bolt': return Icons.bolt;
      default: return Icons.device_unknown;
    }
  }

  /// v0.2.0: 根据产品信息获取颜色
  Color get _productColor {
    final colorHex = device.product?.iconColor;
    if (colorHex == null) return _statusColor; // 降级使用状态颜色

    try {
      // 解析 HEX 颜色 (#FF6B35)
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return _statusColor; // 解析失败降级
    }
  }

  /// v0.2.0: 根据产品信息获取设备名称
  String get _deviceDisplayName {
    // 优先级: device.name > product.name > "智能设备"
    if (device.name != null && device.name!.isNotEmpty) {
      return device.name!;
    }
    if (device.product?.name != null) {
      return device.product!.name;
    }
    return '智能设备';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // v0.2.0: 使用产品图标和颜色
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: _productColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_productIcon, color: _productColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // v0.2.0: 使用产品名称
                    Text(
                      _deviceDisplayName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.deviceId,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: _statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (device.status == DeviceStatus.online) ...[
                    const SizedBox(height: 4),
                    Text(
                      _positionText,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
