/// 状态徽章组件
/// 作者: 罗耀生
/// 日期: 2026-01-14
/// 用途: 显示设备/项目状态的小标签

import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../models/device.dart' show DeviceStatus;

class AppStatusBadge extends StatelessWidget {
  final DeviceStatus status;
  final String? customText;

  const AppStatusBadge({
    super.key,
    required this.status,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final text = customText ?? status.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.borderRadiusSM,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: colors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  ({Color background, Color text}) _getColors() {
    switch (status) {
      case DeviceStatus.online:
        return (
          background: AppColors.success.withOpacity(0.1),
          text: AppColors.success,
        );
      case DeviceStatus.offline:
        return (
          background: AppColors.textTertiary.withOpacity(0.1),
          text: AppColors.textTertiary,
        );
      case DeviceStatus.configuring:
        return (
          background: AppColors.warning.withOpacity(0.1),
          text: AppColors.warning,
        );
    }
  }
}
