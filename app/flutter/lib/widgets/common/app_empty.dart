import 'package:flutter/material.dart';
import '../app_icon.dart';
import '../../theme/app_tokens.dart';

/// 空状态组件
class AppEmpty extends StatelessWidget {
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? customIcon;

  const AppEmpty({
    super.key,
    this.message,
    this.actionText,
    this.onAction,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: AppRadius.borderRadiusXXL,
              ),
              child: customIcon ??
                  AppIcon(AppIcons.inbox, size: 64, color: AppColors.textTertiary),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 加载中组件
class AppLoading extends StatelessWidget {
  final String? message;
  final double? size;

  const AppLoading({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 32,
            height: size ?? 32,
            child: const CircularProgressIndicator(strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 错误状态组件
class AppError extends StatelessWidget {
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;
  final VoidCallback? onRetry;

  const AppError({
    super.key,
    this.message,
    this.actionText,
    this.onAction,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppRadius.borderRadiusXXL,
              ),
              child: AppIcon(AppIcons.error, size: 64, color: AppColors.error),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const AppIcon(AppIcons.refresh, size: 18),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
