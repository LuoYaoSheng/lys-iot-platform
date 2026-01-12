/// Minimal Card - 卡片组件
/// 作者: 罗耀生
/// 版本: 3.0.0
///
/// 遵循 MINIMAL_UI.md 规范:
/// - 内边距: 16px
/// - 圆角: 12px
/// - 阴影: 0 1px 3px rgba(0,0,0,0.04)

library;

import 'package:flutter/material.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';

/// 标准卡片
/// 用于包裹一组相关的内容
class MinimalCard extends StatelessWidget {
  const MinimalCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      margin: margin ?? const EdgeInsets.only(bottom: MinimalSpacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor ?? MinimalTokens.white,
        borderRadius: borderRadius ?? MinimalBorderRadius.lg,
        boxShadow: MinimalShadows.card,
      ),
      child: Padding(
        padding: padding ?? MinimalEdgeInsets.md,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? MinimalBorderRadius.lg,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// 卡片标题组件
class MinimalCardHeader extends StatelessWidget {
  const MinimalCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: MinimalTokens.primary),
          const SizedBox(width: MinimalSpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: MinimalTokens.fontSizeBody,
                  fontWeight: MinimalTokens.fontWeightSemiBold,
                  color: MinimalTokens.gray700,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: MinimalTokens.fontSizeBodySmall,
                    color: MinimalTokens.gray500,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// 卡片底部操作区
class MinimalCardActions extends StatelessWidget {
  const MinimalCardActions({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.end,
  });

  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: children
          .map((child) => Padding(
                padding: const EdgeInsets.only(left: MinimalSpacing.sm),
                child: child,
              ))
          .toList(),
    );
  }
}
