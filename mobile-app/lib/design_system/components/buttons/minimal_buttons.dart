/// Primary Button - 主要按钮
/// 作者: 罗耀生
/// 版本: 3.0.0
///
/// 遵循 MINIMAL_UI.md 规范:
/// - 背景: #007AFF
/// - 文字: White
/// - 圆角: 8px
/// - 高度: 44px

library;

import 'package:flutter/material.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';

/// 主要按钮样式
/// 用于页面中主要的操作按钮，如"登录"、"确认"等
class MinimalPrimaryButton extends StatelessWidget {
  const MinimalPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isEnabled = true,
    this.isLoading = false,
    this.width,
    this.height = 44,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isEnabled;
  final bool isLoading;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && !isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: FilledButton(
        onPressed: effectiveEnabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: MinimalTokens.primary,
          disabledBackgroundColor: MinimalTokens.gray300,
          foregroundColor: MinimalTokens.white,
          padding: EdgeInsets.symmetric(horizontal: MinimalSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MinimalRadius.md),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MinimalTokens.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: MinimalSpacing.sm),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: MinimalTokens.fontSizeBody,
                      fontWeight: MinimalTokens.fontWeightMedium,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 次要按钮样式
/// 用于页面中次要的操作按钮，如"取消"、"返回"等
class MinimalSecondaryButton extends StatelessWidget {
  const MinimalSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isEnabled = true,
    this.width,
    this.height = 44,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isEnabled;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: isEnabled ? MinimalTokens.primary : MinimalTokens.gray300,
          side: BorderSide(
            color: isEnabled ? MinimalTokens.primary : MinimalTokens.gray300,
            width: 1,
          ),
          padding: EdgeInsets.symmetric(horizontal: MinimalSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MinimalRadius.md),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: MinimalSpacing.sm),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: MinimalTokens.fontSizeBody,
                fontWeight: MinimalTokens.fontWeightMedium,
                color: isEnabled ? MinimalTokens.primary : MinimalTokens.gray300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 文本按钮样式
/// 用于页面中低优先级的操作，如"了解更多"、"跳过"等
class MinimalTextButton extends StatelessWidget {
  const MinimalTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: isEnabled
            ? (textColor ?? MinimalTokens.primary)
            : MinimalTokens.gray300,
        padding: EdgeInsets.symmetric(
          horizontal: MinimalSpacing.sm,
          vertical: MinimalSpacing.xs,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: MinimalTokens.fontSizeBody,
          fontWeight: MinimalTokens.fontWeightMedium,
        ),
      ),
    );
  }
}

/// 危险按钮样式
/// 用于破坏性操作，如"删除"、"退出登录"等
class MinimalDangerButton extends StatelessWidget {
  const MinimalDangerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.width,
    this.height = 44,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FilledButton(
        onPressed: isEnabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: MinimalTokens.error,
          disabledBackgroundColor: MinimalTokens.gray300,
          foregroundColor: MinimalTokens.white,
          padding: EdgeInsets.symmetric(horizontal: MinimalSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MinimalRadius.md),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: MinimalTokens.fontSizeBody,
            fontWeight: MinimalTokens.fontWeightMedium,
          ),
        ),
      ),
    );
  }
}
