/// Border Radius Tokens - 圆角设计令牌
/// 作者: 罗耀生
/// 版本: 3.0.0
///
/// 遵循 MINIMAL_UI.md 规范

library;

import 'package:flutter/widgets.dart';

/// ========== 圆角设计令牌 ==========
class MinimalRadius {
  MinimalRadius._();

  /// 小圆角 - 4px
  static const double sm = 4;

  /// 中圆角（按钮/输入框）- 8px
  static const double md = 8;

  /// 大圆角（卡片/对话框）- 12px
  static const double lg = 12;

  /// 超大圆角 - 16px
  static const double xl = 16;

  /// 完全圆角
  static const double full = 9999;
}

/// ========== BorderRadius 快捷方式 ==========
class MinimalBorderRadius {
  MinimalBorderRadius._();

  /// 全方向 4px
  static const BorderRadius sm = BorderRadius.all(Radius.circular(MinimalRadius.sm));

  /// 全方向 8px
  static const BorderRadius md = BorderRadius.all(Radius.circular(MinimalRadius.md));

  /// 全方向 12px
  static const BorderRadius lg = BorderRadius.all(Radius.circular(MinimalRadius.lg));

  /// 全方向 16px
  static const BorderRadius xl = BorderRadius.all(Radius.circular(MinimalRadius.xl));

  /// 垂直方向 12px（用于底部面板）
  static const BorderRadius verticalLg = BorderRadius.vertical(
    top: Radius.circular(MinimalRadius.lg),
    bottom: Radius.circular(MinimalRadius.lg),
  );

  /// 垂直方向顶部 12px（用于底部面板）
  static const BorderRadius topLg = BorderRadius.vertical(
    top: Radius.circular(MinimalRadius.lg),
  );
}
