import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// 按钮类型
enum AppButtonType {
  /// 主要按钮
  primary,
  /// 次要按钮
  secondary,
  /// 文字按钮
  text,
  /// 危险按钮
  danger,
  /// 图标按钮
  icon,
}

/// 按钮尺寸
enum AppButtonSize {
  /// 小号 (40px)
  small,
  /// 中号 (48px)
  medium,
  /// 大号 (56px)
  large,
}

/// 统一按钮组件
class AppButton extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final bool isDisabled;

  const AppButton({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isDisabled = false,
  });

  /// 获取按钮高度
  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.medium:
        return 48;
      case AppButtonSize.large:
        return 56;
    }
  }

  /// 获取水平内边距
  double get _horizontalPadding {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  /// 获取字体样式
  TextStyle get _textStyle {
    switch (size) {
      case AppButtonSize.small:
        return AppTextStyles.labelLarge.copyWith(fontSize: 13);
      case AppButtonSize.medium:
        return AppTextStyles.labelLarge;
      case AppButtonSize.large:
        return AppTextStyles.titleSmall;
    }
  }

  /// 获取图标尺寸
  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }

  /// 获取背景色
  Color _getBackgroundColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled) || isDisabled) {
      return AppColors.bgDisabled;
    }

    switch (type) {
      case AppButtonType.primary:
        if (states.contains(MaterialState.pressed)) {
          return AppColors.primaryActive;
        } else if (states.contains(MaterialState.hovered)) {
          return AppColors.primaryHover;
        }
        return AppColors.primary;
      case AppButtonType.secondary:
        if (states.contains(MaterialState.pressed)) {
          return AppColors.bgTertiary;
        }
        return AppColors.bgSecondary;
      case AppButtonType.danger:
        if (states.contains(MaterialState.pressed)) {
          return const Color(0xFFD62828);
        } else if (states.contains(MaterialState.hovered)) {
          return const Color(0xFFE63946);
        }
        return AppColors.error;
      case AppButtonType.text:
      case AppButtonType.icon:
        return Colors.transparent;
    }
  }

  /// 获取前景色
  Color _getForegroundColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled) || isDisabled) {
      return AppColors.textDisabled;
    }

    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.danger:
        return Colors.white;
      case AppButtonType.secondary:
        return AppColors.textPrimary;
      case AppButtonType.text:
        if (states.contains(MaterialState.pressed)) {
          return AppColors.textTertiary;
        }
        return AppColors.textSecondary;
      case AppButtonType.icon:
        return AppColors.textSecondary;
    }
  }

  /// 获取边框色
  BorderSide? _getBorderSide(Set<MaterialState> states) {
    if (type == AppButtonType.secondary) {
      return BorderSide(
        color: states.contains(MaterialState.disabled) || isDisabled
            ? AppColors.borderPrimary
            : AppColors.borderSecondary,
        width: 1,
      );
    }
    return null;
  }

  /// 图标按钮辅助构造函数
  factory AppButton.icon(
    IconData icon, {
    VoidCallback? onPressed,
    Color? color,
  }) {
    return AppButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onPressed,
      type: AppButtonType.icon,
    );
  }

  /// 文字按钮辅助构造函数
  factory AppButton.text(
    String text, {
    VoidCallback? onPressed,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isDisabled ? null : onPressed;
    final showLoading = isLoading && effectiveOnPressed != null;

    Widget? child;

    if (type == AppButtonType.icon && icon != null) {
      child = SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: icon,
      );
    } else {
      final children = <Widget>[];

      if (showLoading) {
        children.add(
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getForegroundColor(<MaterialState>{}),
              ),
            ),
          ),
        );
      } else if (icon != null) {
        children.add(
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: Icon(
              (icon! is Icon)
                  ? (icon! as Icon).icon
                  : Icons.circle, // fallback
              size: _iconSize,
              color: _getForegroundColor(<MaterialState>{}),
            ),
          ),
        );
      }

      if (text != null) {
        if (children.isNotEmpty) {
          children.add(const SizedBox(width: 8));
        }
        children.add(
          Text(
            text!,
            style: _textStyle.copyWith(
              color: _getForegroundColor(<MaterialState>{}),
            ),
          ),
        );
      }

      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _height,
      child: TextButton(
        onPressed: showLoading ? null : effectiveOnPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(_getBackgroundColor),
          foregroundColor: MaterialStateProperty.resolveWith(_getForegroundColor),
          side: MaterialStateProperty.resolveWith(_getBorderSide),
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(horizontal: _horizontalPadding),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: AppRadius.borderRadiusMD,
            ),
          ),
          elevation: MaterialStateProperty.all(0),
          overlayColor: MaterialStateProperty.all(
            type == AppButtonType.text
                ? AppColors.bgSecondary.withOpacity(0.5)
                : null,
          ),
        ),
        child: child,
      ),
    );
  }
}
