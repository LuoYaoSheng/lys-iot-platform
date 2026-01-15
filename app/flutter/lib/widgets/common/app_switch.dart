import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';

/// 统一开关组件
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool isDisabled;

  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget switchWidget = Material(
      color: Colors.transparent,
      child: Switch(
        value: value,
        onChanged: isDisabled ? null : onChanged,
        activeColor: AppColors.primary,
        activeTrackColor: AppColors.primaryLight,
        inactiveThumbColor: AppColors.bgPrimary,
        inactiveTrackColor: AppColors.borderSecondary,
      ),
    );

    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDisabled
                  ? AppColors.textDisabled
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          switchWidget,
        ],
      );
    }

    return switchWidget;
  }
}
