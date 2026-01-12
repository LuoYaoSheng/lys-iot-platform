/// Spacing Tokens - 间距设计令牌
/// 作者: 罗耀生
/// 版本: 3.0.0
///
/// 遵循 MINIMAL_UI.md 规范

library;

import 'package:flutter/widgets.dart';

/// ========== 间距设计令牌 ==========
class MinimalSpacing {
  MinimalSpacing._();

  /// 无间距
  static const double zero = 0;

  /// 小间距 - 4px
  static const double xs = 4;

  /// 元素间距 - 8px
  static const double sm = 8;

  /// 卡片间距 - 12px
  static const double md = 12;

  /// 页面边距/卡片内边距 - 16px
  static const double lg = 16;

  /// 中等间距 - 20px
  static const double xl = 20;

  /// 大间距 - 24px
  static const double xxl = 24;
}

/// ========== EdgeInsets 快捷方式 ==========
class MinimalEdgeInsets {
  MinimalEdgeInsets._();

  /// 全方向 4px
  static const EdgeInsets xs = EdgeInsets.all(MinimalSpacing.xs);

  /// 全方向 8px
  static const EdgeInsets sm = EdgeInsets.all(MinimalSpacing.sm);

  /// 全方向 12px
  static const EdgeInsets md = EdgeInsets.all(MinimalSpacing.md);

  /// 全方向 16px
  static const EdgeInsets lg = EdgeInsets.all(MinimalSpacing.lg);

  /// 全方向 20px
  static const EdgeInsets xl = EdgeInsets.all(MinimalSpacing.xl);

  /// 全方向 24px
  static const EdgeInsets xxl = EdgeInsets.all(MinimalSpacing.xxl);

  /// 水平 16px
  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: MinimalSpacing.lg);

  /// 垂直 16px
  static const EdgeInsets v16 = EdgeInsets.symmetric(vertical: MinimalSpacing.lg);

  /// 水平 16px, 垂直 8px
  static const EdgeInsets h16v8 = EdgeInsets.symmetric(
    horizontal: MinimalSpacing.lg,
    vertical: MinimalSpacing.sm,
  );

  /// 水平 24px, 垂直 12px
  static const EdgeInsets h24v12 = EdgeInsets.symmetric(
    horizontal: MinimalSpacing.xxl,
    vertical: MinimalSpacing.md,
  );
}

/// ========== SizedBox 快捷方式 ==========
class MinimalSizedBox {
  MinimalSizedBox._();

  /// 高度 4px
  static const SizedBox height4 = SizedBox(height: MinimalSpacing.xs);

  /// 高度 8px
  static const SizedBox height8 = SizedBox(height: MinimalSpacing.sm);

  /// 高度 12px
  static const SizedBox height12 = SizedBox(height: MinimalSpacing.md);

  /// 高度 16px
  static const SizedBox height16 = SizedBox(height: MinimalSpacing.lg);

  /// 高度 20px
  static const SizedBox height20 = SizedBox(height: MinimalSpacing.xl);

  /// 高度 24px
  static const SizedBox height24 = SizedBox(height: MinimalSpacing.xxl);

  /// 宽度 4px
  static const SizedBox width4 = SizedBox(width: MinimalSpacing.xs);

  /// 宽度 8px
  static const SizedBox width8 = SizedBox(width: MinimalSpacing.sm);

  /// 宽度 12px
  static const SizedBox width12 = SizedBox(width: MinimalSpacing.md);

  /// 宽度 16px
  static const SizedBox width16 = SizedBox(width: MinimalSpacing.lg);
}
