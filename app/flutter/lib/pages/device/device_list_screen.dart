/// 设备列表页
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_icon.dart';
import '../../theme/app_tokens.dart';
import '../../core/app_router.dart';
import '../../models/device.dart';
import '../../providers/device_provider.dart';

class DeviceListScreen extends StatefulWidget {
  final bool isNested;

  const DeviceListScreen({super.key, this.isNested = false});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Consumer<DeviceProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // 标题栏
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                color: Colors.white,
                child: const Row(
                  children: [
                    Text(
                      '我的设备',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              // 设备列表
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.devices.isEmpty
                        ? _buildEmpty(provider)
                        : RefreshIndicator(
                            onRefresh: () => provider.refresh(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.devices.length + 1,
                              itemBuilder: (context, index) {
                                if (index == provider.devices.length) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      '长按设备可删除',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                                    ),
                                  );
                                }
                                return _buildDeviceCard(provider.devices[index]);
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppRouter.goToScan(context),
        backgroundColor: AppColors.primary,
        child: const AppIcon(AppIcons.add, size: 24, color: Colors.white),
      ),
    );
  }

  Widget _buildEmpty(DeviceProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIcon(AppIcons.inbox, size: 60, color: Color(0xFF8E8E93)),
          const SizedBox(height: 16),
          const Text('暂无设备', style: TextStyle(color: Color(0xFF8E8E93))),
          if (provider.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: TextStyle(color: Colors.red.shade300, fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('刷新'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    return GestureDetector(
      onTap: () => AppRouter.goToControl(context, device.deviceId),
      onLongPress: () => _showDeleteDialog(device),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: device.isOnline
                        ? const Color(0xFF34C759)
                        : const Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    device.displayName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  device.offlineText,
                  style: TextStyle(
                    fontSize: 14,
                    color: device.isOnline ? const Color(0xFF34C759) : const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    device.deviceType == DeviceType.servo ? '舵机开关' : 'USB唤醒',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                  ),
                  Text(
                    '固件: ${device.firmwareVersion ?? "v1.0.0"}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除设备'),
        content: Text('确定删除「${device.displayName}」？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<DeviceProvider>();
              final success = await provider.deleteDevice(device.deviceId);
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已删除')),
                );
              } else if (provider.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.errorMessage!)),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
