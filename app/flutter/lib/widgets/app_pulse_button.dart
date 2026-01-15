/// 脉冲触发按钮组件
/// 作者: 罗耀生
/// 日期: 2026-01-14
/// 用途: 脉冲触发按钮，支持发送中/成功状态

import 'package:flutter/material.dart';
import 'app_icon.dart';
import '../theme/app_tokens.dart';

enum PulseButtonState {
  idle,
  sending,
  success,
}

class AppPulseButton extends StatelessWidget {
  final PulseButtonState state;
  final String text;
  final String? sendingText;
  final String? successText;
  final int? duration;
  final VoidCallback? onTap;
  final bool disabled;

  const AppPulseButton({
    super.key,
    required this.state,
    this.text = '脉冲触发',
    this.sendingText,
    this.successText,
    this.duration,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || state == PulseButtonState.sending;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: AppDuration.fast,
        height: 56,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: AppRadius.borderRadiusLG,
          border: Border.all(
            color: _getBorderColor(),
          ),
        ),
        child: Center(
          child: _buildContent(),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (state) {
      case PulseButtonState.success:
        return AppColors.success;
      case PulseButtonState.sending:
        return AppColors.bgSecondary;
      case PulseButtonState.idle:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    switch (state) {
      case PulseButtonState.success:
        return AppColors.success;
      case PulseButtonState.sending:
      case PulseButtonState.idle:
        return AppColors.borderPrimary;
    }
  }

  Widget _buildContent() {
    switch (state) {
      case PulseButtonState.sending:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              sendingText ?? '发送中...',
              style: const TextStyle(color: AppColors.textTertiary),
            ),
          ],
        );

      case PulseButtonState.success:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon(AppIcons.check, size: 24, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Text(
              successText ?? (duration != null ? '已发送 ${duration}ms' : '已发送'),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        );

      case PulseButtonState.idle:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIcon(AppIcons.bolt, size: 24, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              text,
              style: AppTextStyles.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        );
    }
  }
}
