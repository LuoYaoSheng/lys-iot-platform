/// Layout Components - 布局组件
/// 作者: 罗耀生
/// 版本: 3.0.0
///
/// 包含：分隔线、分隔空间、列表项

library;

import 'package:flutter/material.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';

/// ========== 分隔线 ==========
class MinimalDivider extends StatelessWidget {
  const MinimalDivider({
    super.key,
    this.height = 1,
    this.color,
    this.thickness,
  });

  final double height;
  final Color? color;
  final double? thickness;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: color ?? MinimalTokens.gray100,
    );
  }
}

/// ========== 分隔空间 ==========
class MinimalSpacer extends StatelessWidget {
  const MinimalSpacer({super.key, this.size = MinimalSpacing.md});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: size);
  }
}

/// ========== 列表项 ==========
/// 标准列表项
class MinimalListTile extends StatelessWidget {
  const MinimalListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MinimalSpacing.lg,
              vertical: MinimalSpacing.md,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: MinimalSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: MinimalTokens.fontSizeBody,
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
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: MinimalSpacing.lg + 24 + MinimalSpacing.md),
            child: MinimalDivider(),
          ),
      ],
    );
  }
}

/// ========== 分组标题 ==========
class MinimalSectionHeader extends StatelessWidget {
  const MinimalSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.padding,
  });

  final String title;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? MinimalEdgeInsets.h16v8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: MinimalTokens.fontSizeBodySmall,
              fontWeight: MinimalTokens.fontWeightSemiBold,
              color: MinimalTokens.gray500,
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
