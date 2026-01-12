/// 设备列表页面
/// 作者: 罗耀生
/// 版本: 4.0.0
/// 完全遵循截图设计：紫色渐变背景 + 白色卡片内容区

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system/design_system.dart';
import '../providers/device_provider.dart';
import '../services/api_service.dart';
import '../widgets/control_panels/control_panel_factory.dart';
import 'scan_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class DeviceListPage extends StatefulWidget {
  const DeviceListPage({super.key});

  @override
  State<DeviceListPage> createState() => _DeviceListPageState();
}

class _DeviceListPageState extends State<DeviceListPage> {
  final Map<String, String> _devicePositions = {};
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadAPICredentials();
      await context.read<DeviceProvider>().loadDevices();
      _loadDevicePositions();
    });
  }

  Future<void> _loadAPICredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final customApiUrl = prefs.getString('custom_api_url');
    if (customApiUrl != null && customApiUrl.isNotEmpty) {
      _apiService.setBaseUrl(customApiUrl);
    }
    final token = prefs.getString('iot_token');
    if (token != null && token.isNotEmpty) {
      _apiService.setBearerToken(token);
    } else {
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
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8EAF6), // 浅紫色顶部
                  Color(0xFFD1C4E9), // 稍深紫色底部
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // 白色卡片内容区
                      Expanded(
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildContent(provider),
                            ),
                          ),
                        ),
                      ),
                      // 底部占位，给 TabBar 留空间
                      const SizedBox(height: 60),
                    ],
                  ),

                  // FAB 按钮
                  Positioned(
                    right: 24,
                    bottom: 76,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScanPage()),
                        ),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2196F3),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x40000000),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 底部导航栏
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _BottomTabBar(
                      currentIndex: 0,
                      onTap: (index) {
                        if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfilePage()),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(DeviceProvider provider) {
    if (provider.isLoading && provider.devices.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2196F3)),
      );
    }

    if (provider.error != null && provider.devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF999999)),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? '',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadDevices(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (provider.devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              '暂无设备',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方 + 添加设备',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.devices.length + 1,
      itemBuilder: (context, index) {
        if (index == provider.devices.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '长按设备卡片可删除',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final device = provider.devices[index];
        return _DeviceCard(
          name: _getDeviceDisplayName(device),
          isOnline: device.isOnline,
          infoText: _getDeviceInfoText(device),
          onTap: () => _showDeviceControlSheet(device),
          onLongPress: () => _showDeleteDialog(device, provider),
        );
      },
    );
  }

  String _getDeviceDisplayName(Device device) {
    if (device.name != null && device.name!.isNotEmpty) {
      return device.name!;
    }
    if (device.product?.name != null) {
      return device.product!.name;
    }
    return '智能设备';
  }

  String _getDeviceInfoText(Device device) {
    final parts = <String>[];
    final position = _devicePositions[device.deviceId];
    if (device.isOnline &&
        position != null &&
        (device.product?.uiTemplate == 'servo' ||
            device.product?.controlMode == 'servo')) {
      parts.add('位置: ${_getPositionText(position)}');
    }
    parts.add('固件: 1.0.0');
    return parts.join(' ');
  }

  String _getPositionText(String position) {
    switch (position) {
      case 'up':
        return '上';
      case 'down':
        return '下';
      case 'middle':
        return '中';
      default:
        return '中';
    }
  }

  void _showDeviceControlSheet(Device device) {
    final title = _getDeviceDisplayName(device);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeviceControlSheet(
        title: title,
        isOnline: device.isOnline,
        device: device,
        apiService: _apiService,
        child: ControlPanelFactory.createPanel(
          device: device,
          apiService: _apiService,
        ),
      ),
    );
  }

  void _showDeleteDialog(Device device, DeviceProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _DeleteDialog(
        deviceName: _getDeviceDisplayName(device),
        onConfirm: () async {
          Navigator.pop(context);
          final success = await provider.deleteDevice(device.deviceId);
          if (mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('设备已删除'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('删除失败'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

/// 设备卡片 - 匹配截图设计
class _DeviceCard extends StatefulWidget {
  final String name;
  final bool isOnline;
  final String infoText;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _DeviceCard({
    required this.name,
    required this.isOnline,
    required this.infoText,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<_DeviceCard> {
  bool _isPressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () {
        setState(() => _isPressing = false);
        widget.onLongPress();
      },
      onLongPressStart: (_) {
        setState(() => _isPressing = true);
      },
      onLongPressEnd: (_) {
        setState(() => _isPressing = false);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isPressing ? Colors.grey.shade100 : Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // 状态点
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: widget.isOnline ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                shape: BoxShape.circle,
              ),
            ),
            // 设备名称和信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.infoText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // 状态文字
            Text(
              widget.isOnline ? '在线' : '离线',
              style: TextStyle(
                fontSize: 14,
                color: widget.isOnline ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
              ),
            ),
            const SizedBox(width: 8),
            // 右箭头
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

/// 删除确认对话框
class _DeleteDialog extends StatelessWidget {
  final String deviceName;
  final VoidCallback onConfirm;

  const _DeleteDialog({
    required this.deviceName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width - 64,
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '删除设备',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '确定要删除"$deviceName"吗？\\n删除后无法恢复。',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF999999),
                      backgroundColor: const Color(0xFFEEEEEE),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF44336),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('删除'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 设备控制底部面板
class _DeviceControlSheet extends StatefulWidget {
  final String title;
  final bool isOnline;
  final Device device;
  final ApiService apiService;
  final Widget child;

  const _DeviceControlSheet({
    required this.title,
    required this.isOnline,
    required this.device,
    required this.apiService,
    required this.child,
  });

  @override
  State<_DeviceControlSheet> createState() => _DeviceControlSheetState();
}

class _DeviceControlSheetState extends State<_DeviceControlSheet> {
  void _showActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActionSheet(
        deviceName: widget.title,
        onDelete: () => _showDeleteDialogInSheet(),
      ),
    );
  }

  void _showDeleteDialogInSheet() {
    Navigator.pop(context);
    final provider = context.read<DeviceProvider>();
    showDialog(
      context: context,
      builder: (context) => _DeleteDialog(
        deviceName: widget.title,
        onConfirm: () async {
          Navigator.pop(context);
          final success = await provider.deleteDevice(widget.device.deviceId);
          if (mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('设备已删除'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('删除失败'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(
                Icons.chevron_left,
                size: 24,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: _showActionSheet,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.edit,
                size: 18,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 操作菜单
class _ActionSheet extends StatelessWidget {
  final String deviceName;
  final VoidCallback onDelete;

  const _ActionSheet({
    required this.deviceName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            _ActionItem(
              icon: Icons.edit_outlined,
              label: '重命名',
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现重命名
              },
            ),
            _ActionItem(
              icon: Icons.delete_outline,
              label: '删除设备',
              isDanger: true,
              onTap: onDelete,
            ),
            Container(
              height: 1,
              color: const Color(0xFFEEEEEE),
              margin: const EdgeInsets.only(top: 8),
            ),
            _ActionItem(
              label: '取消',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isDanger;
  final VoidCallback onTap;

  const _ActionItem({
    this.icon,
    required this.label,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: isDanger ? const Color(0xFFF44336) : const Color(0xFF333333),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isDanger ? const Color(0xFFF44336) : const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 底部导航栏 - 匹配截图设计
class _BottomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomTabBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(0),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.grid_view,
                    size: 24,
                    color: currentIndex == 0 ? const Color(0xFF2196F3) : const Color(0xFF9E9E9E),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '设备',
                    style: TextStyle(
                      fontSize: 14,
                      color: currentIndex == 0 ? const Color(0xFF2196F3) : const Color(0xFF9E9E9E),
                      fontWeight: currentIndex == 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTap(1),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 24,
                    color: currentIndex == 1 ? const Color(0xFF2196F3) : const Color(0xFF9E9E9E),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '我的',
                    style: TextStyle(
                      fontSize: 14,
                      color: currentIndex == 1 ? const Color(0xFF2196F3) : const Color(0xFF9E9E9E),
                      fontWeight: currentIndex == 1 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
