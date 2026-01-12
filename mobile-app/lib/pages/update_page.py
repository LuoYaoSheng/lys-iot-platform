# Write device_list_page.dart
content = r"""/// 设备列表页面
/// 作者: 罗耀生
/// 版本: 3.2.0
/// 完全遵循 design-system/prototype/pages/tab-device.html 设计

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
  int _currentTabIndex = 0;
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
          backgroundColor: MinimalTokens.white,
          appBar: AppBar(
            backgroundColor: MinimalTokens.white,
            elevation: 0,
            title: const Text(
              '我的设备',
              style: TextStyle(
                color: MinimalTokens.gray900,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                color: MinimalTokens.gray700,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  await provider.loadDevices();
                  await _loadDevicePositions();
                },
                color: MinimalTokens.primary,
                child: _buildContent(provider),
              ),
              if (_currentTabIndex == 0)
                Positioned(
                  right: 16,
                  bottom: 80,
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
                        decoration: BoxDecoration(
                          color: MinimalTokens.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              offset: Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '+',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              color: MinimalTokens.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MinimalTabBar(
                  currentIndex: _currentTabIndex,
                  onTap: (index) {
                    if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    }
                  },
                  tabs: const [
                    MinimalTabItem(icon: Icons.devices, label: '设备'),
                    MinimalTabItem(icon: Icons.person, label: '我的'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(DeviceProvider provider) {
    if (provider.isLoading && provider.devices.isEmpty) {
      return const Center(
        child: MinimalLoadingIndicator(size: 48),
      );
    }

    if (provider.error != null && provider.devices.isEmpty) {
      return Center(
        child: MinimalEmptyState(
          icon: Icons.error_outline,
          message: '加载失败',
          subMessage: provider.error,
          actionLabel: '重试',
          onActionPressed: () => provider.loadDevices(),
        ),
      );
    }

    if (provider.devices.isEmpty) {
      return const MinimalEmptyState(
        icon: Icons.devices_outlined,
        message: '暂无设备',
        subMessage: '点击下方 + 添加设备',
      );
    }

    final totalDevices = provider.devices.length;
    final onlineDevices = provider.devices.where((d) => d.isOnline).length;

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: MinimalSpacing.md,
        right: MinimalSpacing.md,
        top: MinimalSpacing.sm,
        bottom: 80,
      ),
      itemCount: provider.devices.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return MinimalDeviceStatsCard(
            totalDevices: totalDevices,
            onlineDevices: onlineDevices,
          );
        }

        if (index == provider.devices.length + 1) {
          return Padding(
            padding: const EdgeInsets.all(MinimalSpacing.md),
            child: Text(
              '长按设备卡片可删除',
              style: TextStyle(
                fontSize: MinimalTokens.fontSizeCaption,
                color: MinimalTokens.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final deviceIndex = index - 1;
        final device = provider.devices[deviceIndex];
        return _DeviceCard(
          name: _getDeviceDisplayName(device),
          isOnline: device.isOnline,
          infoItems: _getDeviceInfoItems(device),
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

  List<String> _getDeviceInfoItems(Device device) {
    final items = <String>[];
    final position = _devicePositions[device.deviceId];
    if (device.isOnline &&
        position != null &&
        (device.product?.uiTemplate == 'servo' ||
            device.product?.controlMode == 'servo')) {
      items.add('位置: ${_getPositionText(position)}');
    }
    items.add('固件: 1.0.0');
    return items;
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
    final icon = ControlPanelFactory.getPanelIcon(device);
    final color = ControlPanelFactory.getPanelColor(device);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeviceControlSheet(
        title: title,
        icon: icon,
        iconColor: color,
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
              MinimalToast.showSuccess(context, '设备已删除');
            } else {
              MinimalToast.showError(context, '删除失败');
            }
          }
        },
      ),
    );
  }
}

class _DeviceCard extends StatefulWidget {
  final String name;
  final bool isOnline;
  final List<String> infoItems;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _DeviceCard({
    required this.name,
    required this.isOnline,
    required this.infoItems,
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
    final statusColor = widget.isOnline ? MinimalTokens.success : MinimalTokens.error;

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
        margin: const EdgeInsets.only(bottom: MinimalSpacing.sm),
        decoration: BoxDecoration(
          color: _isPressing ? MinimalTokens.gray50 : MinimalTokens.white,
          borderRadius: MinimalBorderRadius.lg,
          border: Border.all(color: MinimalTokens.gray100, width: 1),
        ),
        padding: const EdgeInsets.all(MinimalSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: MinimalSpacing.sm),
                Expanded(
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: MinimalTokens.fontSizeBody,
                      color: MinimalTokens.gray700,
                      fontWeight: MinimalTokens.fontWeightMedium,
                    ),
                  ),
                ),
                Text(
                  widget.isOnline ? '在线' : '离线',
                  style: TextStyle(
                    fontSize: MinimalTokens.fontSizeBodySmall,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: MinimalSpacing.sm),
                const Icon(Icons.more_horiz, size: 20, color: MinimalTokens.gray300),
              ],
            ),
            const SizedBox(height: MinimalSpacing.sm),
            if (widget.infoItems.isNotEmpty)
              Row(
                children: [
                  for (int i = 0; i < widget.infoItems.length; i++) ...[
                    Text(
                      widget.infoItems[i],
                      style: TextStyle(
                        fontSize: MinimalTokens.fontSizeCaption,
                        color: MinimalTokens.gray500,
                      ),
                    ),
                    if (i < widget.infoItems.length - 1)
                      const SizedBox(width: MinimalSpacing.md),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 64,
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: MinimalTokens.white,
              borderRadius: MinimalBorderRadius.lg,
            ),
            padding: const EdgeInsets.all(MinimalSpacing.xl),
            child: Column(
              children: [
                Text(
                  '删除设备',
                  style: TextStyle(
                    fontSize: MinimalTokens.fontSizeTitle,
                    fontWeight: MinimalTokens.fontWeightSemiBold,
                    color: MinimalTokens.gray900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: MinimalSpacing.sm),
                Text(
                  '确定要删除"$deviceName"吗？\n删除后无法恢复。',
                  style: TextStyle(
                    fontSize: MinimalTokens.fontSizeBody,
                    color: MinimalTokens.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: MinimalSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MinimalTokens.gray700,
                          backgroundColor: MinimalTokens.gray100,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: MinimalBorderRadius.md,
                          ),
                          minimumSize: const Size.fromHeight(44),
                        ),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: MinimalSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: onConfirm,
                        style: FilledButton.styleFrom(
                          backgroundColor: MinimalTokens.error,
                          foregroundColor: MinimalTokens.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: MinimalBorderRadius.md,
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
        ],
      ),
    );
  }
}

class _DeviceControlSheet extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isOnline;
  final Device device;
  final ApiService apiService;
  final Widget child;

  const _DeviceControlSheet({
    required this.title,
    required this.icon,
    required this.iconColor,
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
        onRename: _showRenameDialog,
        onDelete: () => _showDeleteDialogInSheet(widget.device),
      ),
    );
  }

  void _showRenameDialog() {
    showDialog(
      context: context,
      builder: (context) => _RenameDialog(
        currentName: widget.title,
        onSave: (newName) {
          setState(() {});
        },
      ),
    );
  }

  void _showDeleteDialogInSheet(Device device) {
    Navigator.pop(context);
    final provider = context.read<DeviceProvider>();
    showDialog(
      context: context,
      builder: (context) => _DeleteDialog(
        deviceName: widget.title,
        onConfirm: () async {
          Navigator.pop(context);
          final success = await provider.deleteDevice(device.deviceId);
          if (mounted) {
            if (success) {
              MinimalToast.showSuccess(context, '设备已删除');
              Navigator.pop(context);
            } else {
              MinimalToast.showError(context, '删除失败');
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
            color: MinimalTokens.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(MinimalSpacing.md),
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
      padding: const EdgeInsets.symmetric(
        horizontal: MinimalSpacing.md,
        vertical: MinimalSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: MinimalTokens.gray100, width: 1),
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
                color: MinimalTokens.gray700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MinimalTokens.gray900,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: _showActionSheet,
            child: Container(
              padding: const EdgeInsets.all(MinimalSpacing.sm),
              child: const Icon(
                Icons.edit,
                size: 18,
                color: MinimalTokens.gray500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSheet extends StatelessWidget {
  final String deviceName;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _ActionSheet({
    required this.deviceName,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MinimalTokens.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: MinimalSpacing.sm),
            _ActionItem(
              icon: Icons.edit_outlined,
              label: '重命名',
              onTap: () {
                Navigator.pop(context);
                onRename();
              },
            ),
            _ActionItem(
              icon: Icons.delete_outline,
              label: '删除设备',
              isDanger: true,
              onTap: () {
                onDelete();
              },
            ),
            Container(
              height: 1,
              color: MinimalTokens.gray200,
              margin: const EdgeInsets.only(top: MinimalSpacing.sm),
            ),
            _ActionItem(
              label: '取消',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: MinimalSpacing.xl),
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
              Icon(icon, size: 20, color: isDanger ? MinimalTokens.error : MinimalTokens.gray700),
              const SizedBox(width: MinimalSpacing.md),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: MinimalTokens.fontSizeBody,
                color: isDanger ? MinimalTokens.error : MinimalTokens.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  final String currentName;
  final ValueChanged<String> onSave;

  const _RenameDialog({
    required this.currentName,
    required this.onSave,
  });

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 64,
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: MinimalTokens.white,
              borderRadius: MinimalBorderRadius.lg,
            ),
            padding: const EdgeInsets.all(MinimalSpacing.xl),
            child: Column(
              children: [
                Text(
                  '重命名设备',
                  style: TextStyle(
                    fontSize: MinimalTokens.fontSizeTitle,
                    fontWeight: MinimalTokens.fontWeightSemiBold,
                    color: MinimalTokens.gray900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: MinimalSpacing.xl),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: '请输入设备名称',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      widget.onSave(value.trim());
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: MinimalSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MinimalTokens.gray700,
                          backgroundColor: MinimalTokens.gray100,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: MinimalBorderRadius.md,
                          ),
                          minimumSize: const Size.fromHeight(44),
                        ),
                        child: const Text('取消'),
                      ),
                    ),
                    const SizedBox(width: MinimalSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final newName = _controller.text.trim();
                          if (newName.isNotEmpty) {
                            widget.onSave(newName);
                            Navigator.pop(context);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: MinimalTokens.primary,
                          foregroundColor: MinimalTokens.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: MinimalBorderRadius.md,
                          ),
                          minimumSize: const Size.fromHeight(44),
                        ),
                        child: const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
"""

with open('device_list_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('File updated successfully')
