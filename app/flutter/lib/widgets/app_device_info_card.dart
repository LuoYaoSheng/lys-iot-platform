/// 设备信息卡片组件
/// 作者: 罗耀生
/// 日期: 2026-01-14
/// 用途: 显示设备详细信息的卡片

import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class AppDeviceInfoCard extends StatelessWidget {
  final List<DeviceInfoItem> items;

  const AppDeviceInfoCard({
    super.key,
    required this.items,
  });

  /// 从 Map 创建信息卡片
  factory AppDeviceInfoCard.fromMap({
    Key? key,
    required Map<String, String?> data,
    Map<String, String>? fieldLabels,
  }) {
    final defaultLabels = {
      'name': '设备名称',
      'id': '设备 ID',
      'deviceId': '设备 ID',
      'type': '产品类型',
      'productType': '产品类型',
      'firmware': '固件版本',
      'location': '位置',
      'model': '型号',
    };

    final labels = {...defaultLabels, ...?fieldLabels};

    final items = data.entries.map((entry) {
      return DeviceInfoItem(
        label: labels[entry.key] ?? entry.key,
        value: entry.value ?? '-',
      );
    }).toList();

    return AppDeviceInfoCard(key: key, items: items);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusLG,
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              _InfoRow(label: item.label, value: item.value),
              if (!isLast)
                const Divider(height: 1, color: AppColors.borderPrimary),
            ],
          );
        }).toList(),
      ),
    );
  }
}

@immutable
class DeviceInfoItem {
  final String label;
  final String value;

  const DeviceInfoItem({
    required this.label,
    required this.value,
  });
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
