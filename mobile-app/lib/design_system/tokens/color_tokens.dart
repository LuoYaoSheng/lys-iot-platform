/// Design Tokens - 设计令牌
/// 作者: 罗耀生
/// 版本: 3.0.0
/// 设计系统: Minimal UI - 简洁设计系统
///
/// 遵循 design-system/MINIMAL_UI.md 规范
///
/// 使用示例:
/// ```dart
/// import 'package:open_iot_app/design_system/design_tokens.dart';
///
/// Container(
///   color: MinimalTokens.primary,
///   padding: EdgeInsets.all(MinimalTokens.spacing16),
/// )
/// ```

library;

import 'package:flutter/material.dart';

// ==================== 设计令牌 ====================

/// ========== 简洁设计令牌 ==========
/// 遵循 MINIMAL_UI.md 规范的颜色、间距、圆角、字体
class MinimalTokens {
  MinimalTokens._();

  // ==================== 颜色 ====================

  /// 主色调 - iOS Blue #007AFF
  static const Color primary = Color(0xFF007AFF);

  /// 主色调浅色 - Hover #3395FF
  static const Color primaryLight = Color(0xFF3395FF);

  /// 主色调深色 - Pressed #0056CC
  static const Color primaryDark = Color(0xFF0056CC);

  /// 次要色 - Purple #5856D6
  static const Color secondary = Color(0xFF5856D6);

  /// 成功色 - Green #34C759
  static const Color success = Color(0xFF34C759);

  /// 警告色 - Orange #FF9500
  static const Color warning = Color(0xFFFF9500);

  /// 错误色 - Red #FF3B30
  static const Color error = Color(0xFFFF3B30);

  /// 信息色 - Blue #007AFF
  static const Color info = Color(0xFF007AFF);

  /// 纯白 #FFFFFF
  static const Color white = Color(0xFFFFFFFF);

  /// Gray-50 - 次背景 #F5F5F7
  static const Color gray50 = Color(0xFFF5F5F7);

  /// Gray-100 - 分割线 #E5E5EA
  static const Color gray100 = Color(0xFFE5E5EA);

  /// Gray-200 - 边框 #D1D1D6
  static const Color gray200 = Color(0xFFD1D1D6);

  /// Gray-300 - 禁用 #C7C7CC
  static const Color gray300 = Color(0xFFC7C7CC);

  /// Gray-500 - 次要文字 #8E8E93
  static const Color gray500 = Color(0xFF8E8E93);

  /// Gray-700 - 主要文字 #3A3A3C
  static const Color gray700 = Color(0xFF3A3A3C);

  /// Gray-900 - 强调文字 #000000
  static const Color gray900 = Color(0xFF000000);

  // ==================== 间距 ====================
  /// 基于 MINIMAL_UI.md 规范
  static const double spacing0 = 0;
  static const double spacing4 = 4;   // 小间距
  static const double spacing8 = 8;   // 元素间距
  static const double spacing12 = 12; // 卡片间距
  static const double spacing16 = 16; // 页面边距/卡片内边距
  static const double spacing20 = 20;
  static const double spacing24 = 24;

  // ==================== 圆角 ====================
  /// 基于 MINIMAL_UI.md 规范
  static const double radiusSm = 4;   // 小圆角
  static const double radiusMd = 8;   // 按钮/输入框圆角
  static const double radiusLg = 12;  // 卡片/对话框圆角
  static const double radiusXl = 16;  // 大卡片圆角

  // ==================== 字体大小 ====================
  /// 基于 MINIMAL_UI.md 规范
  static const double fontSizeLarge = 28;     // 大标题
  static const double fontSizeTitle = 20;     // 标题
  static const double fontSizeBody = 16;      // 正文
  static const double fontSizeBodySmall = 14; // 辅助
  static const double fontSizeCaption = 12;   // 标签

  // ==================== 字重 ====================
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;

  // ==================== 动画 ====================
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);

  /// 标准缓动曲线
  static const Curve curveStandard = Curves.easeInOut;
}

/// ========== 文本样式快捷方式 ==========
class MinimalTextStyles {
  MinimalTextStyles._();

  /// 大标题 (28px, SemiBold)
  static const TextStyle large = TextStyle(
    fontSize: MinimalTokens.fontSizeLarge,
    fontWeight: MinimalTokens.fontWeightSemiBold,
    color: MinimalTokens.gray900,
  );

  /// 标题 (20px, SemiBold)
  static const TextStyle title = TextStyle(
    fontSize: MinimalTokens.fontSizeTitle,
    fontWeight: MinimalTokens.fontWeightSemiBold,
    color: MinimalTokens.gray700,
  );

  /// 正文 (16px, Regular)
  static const TextStyle body = TextStyle(
    fontSize: MinimalTokens.fontSizeBody,
    fontWeight: MinimalTokens.fontWeightRegular,
    color: MinimalTokens.gray700,
  );

  /// 辅助文字 (14px, Regular)
  static const TextStyle bodySmall = TextStyle(
    fontSize: MinimalTokens.fontSizeBodySmall,
    fontWeight: MinimalTokens.fontWeightRegular,
    color: MinimalTokens.gray500,
  );

  /// 标签文字 (12px, Medium)
  static const TextStyle caption = TextStyle(
    fontSize: MinimalTokens.fontSizeCaption,
    fontWeight: MinimalTokens.fontWeightMedium,
    color: MinimalTokens.gray500,
  );
}

/// ========== 阴影快捷方式 ==========
class MinimalShadows {
  MinimalShadows._();

  /// 卡片阴影: 0 1px 3px rgba(0,0,0,0.04)
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  /// 悬浮阴影: 0 4px 12px rgba(0,0,0,0.08)
  static const List<BoxShadow> hover = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  /// 按钮阴影: 0 1px 2px rgba(0,0,0,0.1)
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];
}
