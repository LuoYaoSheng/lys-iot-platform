/// 扫码添加设备页
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';
import '../../core/app_router.dart';
import '../../widgets/app_icon.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devices = [
      {'name': 'IoT-Switch-A1B2', 'type': '舵机开关', 'icon': AppIcons.plug, 'signal': 4},
      {'name': 'IoT-Wakeup-C3D4', 'type': 'USB唤醒', 'icon': AppIcons.bolt, 'signal': 5},
      {'name': 'IoT-Switch-E5F6', 'type': '舵机开关', 'icon': AppIcons.plug, 'signal': 2},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('扫码配网'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3A3A3C),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 扫描状态
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '正在扫描附近的设备...',
                  style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                ),
              ],
            ),
          ),

          // 设备列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return _buildDeviceItem(context, device);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(BuildContext context, Map<String, dynamic> device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AppIcon(device['icon'], size: 24, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  device['type'],
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
                ),
              ],
            ),
          ),
          // 信号强度
          Row(
            children: List.generate(5, (i) {
              return Container(
                width: 4,
                height: (i + 1) * 3.0 + 2,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: i < device['signal']
                      ? const Color(0xFF34C759)
                      : const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => AppRouter.goToConfig(context, device),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '连接',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
