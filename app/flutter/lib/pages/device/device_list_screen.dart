/// 设备列表页
/// 作者: 罗耀生
/// 日期: 2026-01-13

import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_card.dart';
import '../../widgets/common/app_empty.dart';
import '../../widgets/common/app_toast.dart';
import '../../models/device.dart';
import '../../core/app_router.dart';

class DeviceListScreen extends StatefulWidget {
  /// 是否嵌套在TabBar中（嵌套时不显示AppBar）
  final bool isNested;

  const DeviceListScreen({
    super.key,
    this.isNested = false,
  });

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<Device> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() {
    setState(() {
      _devices = MockData.devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = _devices.isEmpty
        ? AppEmpty(
            message: '暂无设备',
            actionText: '添加设备',
            onAction: () => AppRouter.goToScan(context),
          )
        : RefreshIndicator(
            onRefresh: () async => _loadDevices(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
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
          );

    if (widget.isNested) {
      // 嵌套模式：只返回内容区域，有自定义标题栏和FAB
      return Scaffold(
        body: Column(
          children: [
            // 自定义标题栏
            Container(
              height: 44 + MediaQuery.of(context).padding.top,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: const BoxDecoration(
                color: AppColors.bgPrimary,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderSecondary, width: 0.5),
                ),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 16), // 左边距
                  Text(
                    '我的设备',
                    style: AppTextStyles.headlineSmall,
                  ),
                ],
              ),
            ),
            // 内容区域
            Expanded(child: content),
          ],
        ),
        // FAB添加设备按钮
        floatingActionButton: FloatingActionButton(
          onPressed: () => AppRouter.goToScan(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    } else {
      // 独立模式：显示完整AppBar和FAB
      return Scaffold(
        appBar: const AppBar(
          title: Text('我的设备'),
        ),
        body: content,
        floatingActionButton: FloatingActionButton(
          onPressed: () => AppRouter.goToScan(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }
  }

  /// 设备卡片
  Widget _DeviceCard({
    required Device device,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 卡片头部：状态点 + 设备名 + 状态文本 + 更多图标
              Row(
                children: [
                  // 状态指示点
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: device.status == DeviceStatus.online
                          ? const Color(0xFF34C759) // 在线绿色
                          : const Color(0xFF8E8E93), // 离线灰色
                    ),
                  ),
                  // 设备名称
                  Expanded(
                    child: Text(
                      device.name,
                      style: AppTextStyles.titleMedium,
                    ),
                  ),
                  // 状态文本
                  Text(
                    device.statusText,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: device.status == DeviceStatus.online
                          ? AppColors.textPrimary
                          : const Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // 更多图标（三个点）
                  Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // 卡片底部：位置/型号 + 固件版本
              Row(
                children: [
                  // 位置或型号信息
                  Text(
                    device.location != null
                        ? '位置: ${device.location}'
                        : device.model ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // 固件版本
                  Text(
                    '固件: ${device.firmware ?? "未知"}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 打开设备详情
  void _openDevice(Device device) {
    AppRouter.goToControl(context, device.id);
  }

  /// 显示设备菜单
  void _showDeviceMenu(Device device) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑设备'),
              onTap: () {
                Navigator.pop(context);
                if (mounted) AppToast.show(context, '编辑设备: ${device.name}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除设备', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirm(device);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  /// 显示删除确认对话框
  void _showDeleteConfirm(Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除设备"\${device.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _devices.removeWhere((d) => d.id == device.id);
              });
              Navigator.pop(context);
              if (mounted) AppToast.show(context, '设备已删除');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
