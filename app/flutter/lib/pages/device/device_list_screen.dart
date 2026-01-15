/// 设备列表页
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import '../../widgets/app_icon.dart';
import '../../theme/app_tokens.dart';
import '../../core/app_router.dart';

class DeviceListScreen extends StatefulWidget {
  final bool isNested;

  const DeviceListScreen({super.key, this.isNested = false});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<Map<String, dynamic>> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() {
    setState(() {
      _devices = [
        {'id': '1', 'name': 'IoT-Switch-A1B2', 'type': 'servo', 'status': 'online', 'firmware': 'v1.2.0'},
        {'id': '2', 'name': 'IoT-Wakeup-C3D4', 'type': 'wakeup', 'status': 'online', 'firmware': 'v1.0.0'},
        {'id': '3', 'name': 'IoT-Switch-E5F6', 'type': 'servo', 'status': 'offline', 'firmware': 'v1.1.0'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
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
            child: _devices.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _devices.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _devices.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            '长按设备可删除',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                          ),
                        );
                      }
                      return _buildDeviceCard(_devices[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppRouter.goToScan(context),
        backgroundColor: AppColors.primary,
        child: const AppIcon(AppIcons.add, size: 24, color: Colors.white),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIcon(AppIcons.inbox, size: 60, color: Color(0xFF8E8E93)),
          const SizedBox(height: 16),
          const Text('暂无设备', style: TextStyle(color: Color(0xFF8E8E93))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => AppRouter.goToScan(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('添加设备'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final isOnline = device['status'] == 'online';

    return GestureDetector(
      onTap: () => AppRouter.goToControl(context, device['id']),
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
                    color: isOnline ? const Color(0xFF34C759) : const Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    device['name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  isOnline ? '在线' : '离线',
                  style: TextStyle(
                    fontSize: 14,
                    color: isOnline ? const Color(0xFF34C759) : const Color(0xFF8E8E93),
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
                    device['type'] == 'servo' ? '舵机开关' : 'USB唤醒',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                  ),
                  Text(
                    '固件: ${device['firmware']}',
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

  void _showDeleteDialog(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除设备'),
        content: Text('确定删除「${device['name']}」？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _devices.removeWhere((d) => d['id'] == device['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已删除')),
              );
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
