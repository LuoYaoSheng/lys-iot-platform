/// 位置按钮组组件
/// 作者: 罗耀生
/// 日期: 2026-01-14
/// 用途: 舵机位置选择按钮组（上/中/下）

import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import 'app_position_display.dart';

class AppPositionButtonGroup extends StatelessWidget {
  final ServoPosition value;
  final ValueChanged<ServoPosition> onChanged;
  final List<PositionOption> options;

  const AppPositionButtonGroup({
    super.key,
    required this.value,
    required this.onChanged,
    this.options = const [
      PositionOption(ServoPosition.up, '上'),
      PositionOption(ServoPosition.middle, '中'),
      PositionOption(ServoPosition.down, '下'),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final isSelected = value == option.position;
        final index = options.indexOf(option);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < options.length - 1 ? AppSpacing.sm : 0,
            ),
            child: _PositionButton(
              label: option.label,
              selected: isSelected,
              onTap: () => onChanged(option.position),
            ),
          ),
        );
      }).toList(),
    );
  }
}

@immutable
class PositionOption {
  final ServoPosition position;
  final String label;

  const PositionOption(this.position, this.label);
}

class _PositionButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PositionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: AppRadius.borderRadiusLG,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderPrimary,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelLarge?.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
