import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// 卡片类型
enum AppCardType {
  /// 默认卡片
  default_,
  /// 可点击卡片
  clickable,
  /// 边框卡片
  outlined,
  /// 抬升卡片
  elevated,
}

/// 统一卡片组件
class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardType type;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool isFullWidth;

  const AppCard({
    super.key,
    required this.child,
    this.type = AppCardType.default_,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderRadius,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? AppSpacing.paddingMD;
    final effectiveMargin = margin ?? AppSpacing.paddingSM;

    Color getBackgroundColor() {
      if (backgroundColor != null) return backgroundColor!;
      switch (type) {
        case AppCardType.default_:
        case AppCardType.outlined:
          return AppColors.bgPrimary;
        case AppCardType.clickable:
          return AppColors.bgPrimary;
        case AppCardType.elevated:
          return AppColors.bgPrimary;
      }
    }

    BoxBorder? getBorder() {
      switch (type) {
        case AppCardType.outlined:
          return Border.all(
            color: AppColors.borderPrimary,
            width: 1,
          );
        default:
          return null;
      }
    }

    List<BoxShadow>? getShadows() {
      switch (type) {
        case AppCardType.elevated:
          return AppShadows.md;
        case AppCardType.clickable:
          return AppShadows.sm;
        default:
          return null;
      }
    }

    Widget cardContent = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        border: getBorder(),
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.md),
        boxShadow: getShadows(),
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.md),
          splashColor: AppColors.primaryLight,
          highlightColor: AppColors.bgSecondary,
          child: cardContent,
        ),
      );
    }

    return Container(
      width: isFullWidth ? double.infinity : null,
      margin: effectiveMargin,
      child: cardContent,
    );
  }
}

/// 卡片列表项组件
class AppListItem extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? subtitles;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;

  const AppListItem({
    super.key,
    this.leading,
    this.title,
    this.subtitles,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.showDivider = true,
  });

  factory AppListItem.title({
    Key? key,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return AppListItem(
      key: key,
      title: Text(
        title,
        style: AppTextStyles.bodyMedium,
      ),
      trailing: trailing,
      onTap: onTap,
      showDivider: showDivider,
    );
  }

  factory AppListItem.withLeading({
    Key? key,
    required Widget leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return AppListItem(
      key: key,
      leading: leading,
      title: Text(
        title,
        style: AppTextStyles.bodyMedium,
      ),
      subtitles: subtitle != null
          ? [
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ]
          : null,
      trailing: trailing,
      onTap: onTap,
      showDivider: showDivider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    Widget content = Container(
      padding: effectivePadding,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) title!,
                if (subtitles != null && subtitles!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...subtitles!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap != null || onLongPress != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: AppColors.primaryLight,
          child: content,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderPrimary,
            indent: 16,
          ),
      ],
    );
  }
}
