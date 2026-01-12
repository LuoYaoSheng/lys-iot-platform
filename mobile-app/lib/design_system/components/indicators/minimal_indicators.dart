/// Minimal Indicators - 指示器组件
/// 作者: 罗耀生
/// 版本: 3.0.0
///
/// 包含：状态点、徽章、加载指示器

library;

import 'package:flutter/material.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';

/// ========== 状态点 ==========
/// 用于显示设备在线/离线状态
class MinimalStatusDot extends StatelessWidget {
  const MinimalStatusDot({
    super.key,
    required this.status,
    this.size = 8,
  });

  final MinimalStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case MinimalStatus.online:
        return MinimalTokens.success;
      case MinimalStatus.offline:
        return MinimalTokens.gray300;
      case MinimalStatus.connecting:
        return MinimalTokens.warning;
      case MinimalStatus.error:
        return MinimalTokens.error;
    }
  }
}

/// 状态枚举
enum MinimalStatus { online, offline, connecting, error }

/// ========== 徽章 ==========
/// 用于显示标签、计数等
class MinimalBadge extends StatelessWidget {
  const MinimalBadge({
    super.key,
    required this.label,
    this.type = MinimalBadgeType.primary,
  });

  final String label;
  final MinimalBadgeType type;

  @override
  Widget build(BuildContext context) {
    final colors = _getBadgeColors();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MinimalSpacing.sm,
        vertical: MinimalSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: MinimalBorderRadius.sm,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: MinimalTokens.fontSizeCaption,
          fontWeight: MinimalTokens.fontWeightMedium,
          color: colors.text,
        ),
      ),
    );
  }

  _MinimalBadgeColors _getBadgeColors() {
    switch (type) {
      case MinimalBadgeType.primary:
        return _MinimalBadgeColors(
          background: MinimalTokens.primary.withOpacity(0.1),
          text: MinimalTokens.primary,
        );
      case MinimalBadgeType.success:
        return _MinimalBadgeColors(
          background: MinimalTokens.success.withOpacity(0.1),
          text: MinimalTokens.success,
        );
      case MinimalBadgeType.error:
        return _MinimalBadgeColors(
          background: MinimalTokens.error.withOpacity(0.1),
          text: MinimalTokens.error,
        );
      case MinimalBadgeType.warning:
        return _MinimalBadgeColors(
          background: MinimalTokens.warning.withOpacity(0.1),
          text: MinimalTokens.warning,
        );
      case MinimalBadgeType.gray:
        return _MinimalBadgeColors(
          background: MinimalTokens.gray100,
          text: MinimalTokens.gray500,
        );
    }
  }
}

/// 徽章类型
enum MinimalBadgeType { primary, success, error, warning, gray }

class _MinimalBadgeColors {
  final Color background;
  final Color text;

  _MinimalBadgeColors({required this.background, required this.text});
}

/// ========== 加载指示器 ==========
class MinimalLoadingIndicator extends StatelessWidget {
  const MinimalLoadingIndicator({
    super.key,
    this.size = 24,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: MinimalTokens.primary,
      ),
    );
  }
}

/// 页面级加载状态
class MinimalLoadingPage extends StatelessWidget {
  const MinimalLoadingPage({
    super.key,
    this.message = '加载中...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MinimalLoadingIndicator(size: 48),
          const SizedBox(height: MinimalSpacing.md),
          Text(
            message,
            style: const TextStyle(
              fontSize: MinimalTokens.fontSizeBodySmall,
              color: MinimalTokens.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

/// ========== 空状态 ==========
/// 用于显示无数据、无设备等空状态
class MinimalEmptyState extends StatelessWidget {
  const MinimalEmptyState({
    super.key,
    required this.message,
    this.subMessage,
    this.icon,
    this.actionLabel,
    this.onActionPressed,
  });

  final String message;
  final String? subMessage;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: MinimalEdgeInsets.lg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 64,
                color: MinimalTokens.gray300,
              )
            else
              const Icon(
                Icons.inbox_outlined,
                size: 64,
                color: MinimalTokens.gray300,
              ),
            const SizedBox(height: MinimalSpacing.lg),
            Text(
              message,
              style: const TextStyle(
                fontSize: MinimalTokens.fontSizeBody,
                color: MinimalTokens.gray700,
              ),
            ),
            if (subMessage != null) ...[
              const SizedBox(height: MinimalSpacing.sm),
              Text(
                subMessage!,
                style: const TextStyle(
                  fontSize: MinimalTokens.fontSizeBodySmall,
                  color: MinimalTokens.gray500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: MinimalSpacing.lg),
              FilledButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
