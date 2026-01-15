/// 时长选择芯片组组件
/// 作者: 罗耀生
/// 日期: 2026-01-14
/// 用途: 脉冲时长选择（如 300ms/500ms/1s/2s）

import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class AppDurationChipGroup extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final List<DurationOption> options;

  const AppDurationChipGroup({
    super.key,
    required this.value,
    required this.onChanged,
    this.options = const [
      DurationOption(300, '300ms'),
      DurationOption(500, '500ms'),
      DurationOption(1000, '1s'),
      DurationOption(2000, '2s'),
    ],
  });

  /// 从毫秒列表创建选项
  factory AppDurationChipGroup.fromMilliseconds({
    Key? key,
    required int value,
    required ValueChanged<int> onChanged,
    required List<int> durations,
  }) {
    return AppDurationChipGroup(
      key: key,
      value: value,
      onChanged: onChanged,
      options: durations
          .map((ms) => DurationOption(ms, ms >= 1000 ? '${ms ~/ 1000}s' : '${ms}ms'))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.asMap().entries.map((entry) {
        final option = entry.value;
        final index = entry.key;
        final isSelected = value == option.value;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < options.length - 1 ? AppSpacing.sm : 0,
            ),
            child: _DurationChip(
              label: option.label,
              selected: isSelected,
              onTap: () => onChanged(option.value),
            ),
          ),
        );
      }).toList(),
    );
  }
}

@immutable
class DurationOption {
  final int value;
  final String label;

  const DurationOption(this.value, this.label);
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: AppRadius.borderRadiusMD,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderPrimary,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodySmall?.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
