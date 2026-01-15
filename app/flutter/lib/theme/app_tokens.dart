/// Design Tokens for Open IoT Platform
/// 统一的设计令牌，确保跨组件视觉一致性
library;

import 'package:flutter/material.dart';

/// 颜色令牌
class AppColors {
  AppColors._();

  // 主色
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryHover = Color(0xFF0051D5);
  static const Color primaryActive = Color(0xFF003999);
  static const Color primaryLight = Color(0xFFE6F2FF);

  // 次要色
  static const Color secondary = Color(0xFF5856D6);
  static const Color secondaryHover = Color(0xFF4242B3);
  static const Color secondaryActive = Color(0xFF2E2E80);

  // 中性色
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFCCCCCC);

  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF5F5F7);
  static const Color bgTertiary = Color(0xFFEFEFF4);
  static const Color bgDisabled = Color(0xFFF9F9F9);

  static const Color borderPrimary = Color(0xFFE5E5EA);
  static const Color borderSecondary = Color(0xFFC5C5C7);
  static const Color borderFocus = Color(0xFF007AFF);

  // 状态色
  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFFE8F8ED);
  static const Color warning = Color(0xFFFF9500);
  static const Color warningLight = Color(0xFFFFF3E6);
  static const Color error = Color(0xFFFF3B30);
  static const Color errorLight = Color(0xFFFFE6E6);
  static const Color info = Color(0xFF5AC8FA);
  static const Color infoLight = Color(0xFFE6F7FF);

  // 透明度
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  static const Color divider = Color(0x1A000000);
}

/// 字体令牌
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
}

/// 间距令牌
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // 内边距
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // 水平内边距
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);

  // 垂直内边距
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);

  // 间距
  static const SizedBox gapXS = SizedBox(width: xs, height: xs);
  static const SizedBox gapSM = SizedBox(width: sm, height: sm);
  static const SizedBox gapMD = SizedBox(width: md, height: md);
  static const SizedBox gapLG = SizedBox(width: lg, height: lg);
  static const SizedBox gapXL = SizedBox(width: xl, height: xl);
}

/// 圆角令牌
class AppRadius {
  AppRadius._();

  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;

  static BorderRadius borderRadiusSM = BorderRadius.circular(sm);
  static BorderRadius borderRadiusMD = BorderRadius.circular(md);
  static BorderRadius borderRadiusLG = BorderRadius.circular(lg);
  static BorderRadius borderRadiusXL = BorderRadius.circular(xl);
  static BorderRadius borderRadiusXXL = BorderRadius.circular(xxl);
  static BorderRadius borderRadiusFull = BorderRadius.circular(full);
}

/// 阴影令牌
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];
}

/// 动画令牌
class AppDuration {
  AppDuration._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration slower = Duration(milliseconds: 500);
}

/// 动画曲线
class AppCurves {
  AppCurves._();

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceIn = Curves.bounceIn;
}

/// Z-index 层级
class AppZIndex {
  AppZIndex._();

  static const int base = 0;
  static const int dropdown = 100;
  static const int sticky = 200;
  static const int fixed = 300;
  static const int modalBackdrop = 400;
  static const int modal = 500;
  static const int popover = 600;
  static const int tooltip = 700;
}

/// 通用断点
class AppBreakpoints {
  AppBreakpoints._();

  static const double sm = 576;
  static const double md = 768;
  static const double lg = 992;
  static const double xl = 1200;
}
