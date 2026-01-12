/// Navigation Components - FAB 浮动操作按钮
/// 作者: 罗耀生
/// 版本: 3.0.0
///
/// 遵循 design-system/prototype/pages/mobile-styles.css 规范
///
/// 规格:
/// - 尺寸: 56×56pt
/// - 圆角: 16pt
/// - 背景: 主色
/// - 图标大小: 28pt
/// - 阴影: elevation 3

library;

import 'package:flutter/material.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/radius_tokens.dart';

/// ========== FAB 浮动操作按钮 ==========
/// 遵循原型 tab-device.html FAB 规范
class MinimalFab extends StatelessWidget {
  const MinimalFab({
    super.key,
    required this.onPressed,
    this.icon,
    this.label,
    this.background,
    this.foreground,
    this.withTabbar = false,
  });

  /// 点击回调
  final VoidCallback onPressed;

  /// 图标（默认为 + 号）
  final IconData? icon;

  /// 文字标签（可选）
  final String? label;

  /// 背景色（默认主色）
  final Color? background;

  /// 前景色（默认白色）
  final Color? foreground;

  /// 是否适配 TabBar (调整 bottom 位置)
  final bool withTabbar;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: withTabbar ? 80 : 24, // TabBar高度60 + 间距20
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: background ?? MinimalTokens.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (label != null) {
      // 带文字的 FAB
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 24,
              color: foreground ?? MinimalTokens.white,
            ),
          if (icon != null && label != null) const SizedBox(width: 8),
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: MinimalTokens.fontWeightMedium,
              color: foreground ?? MinimalTokens.white,
            ),
          ),
        ],
      );
    }

    // 纯图标 FAB
    return Text(
      icon == null ? '+' : '',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w300,
        color: foreground ?? MinimalTokens.white,
        height: 1.0,
      ),
    );
  }
}
