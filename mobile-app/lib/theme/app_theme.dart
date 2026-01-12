/// Open IoT Platform - 统一主题配置
/// 作者: 罗耀生
/// 版本: 1.0.0
/// 基于 Design System 规范

import 'package:flutter/material.dart';

/// ========== 设计令牌 ==========
class AppTokens {
  // ========== 颜色 ==========
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryContainer = Color(0xFFE0E7FF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // 语义色
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // 中性色
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  static const Color white = Color(0xFFFFFFFF);

  // 设备状态色
  static const Color statusOnline = Color(0xFF10B981);
  static const Color statusOffline = Color(0xFF9CA3AF);
  static const Color statusConnecting = Color(0xFFF59E0B);
  static const Color statusError = Color(0xFFEF4444);

  // ========== 间距 ==========
  static const double spacing0 = 0;
  static const double spacing1 = 4;
  static const double spacing2 = 8;
  static const double spacing3 = 12;
  static const double spacing4 = 16;
  static const double spacing5 = 20;
  static const double spacing6 = 24;
  static const double spacing8 = 32;
  static const double spacing10 = 40;
  static const double spacing12 = 48;
  static const double spacing16 = 64;

  // ========== 圆角 ==========
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radius2xl = 24;

  // ========== 字体大小 ==========
  static const double fontSizeDisplayLarge = 57;
  static const double fontSizeDisplayMedium = 45;
  static const double fontSizeHeadlineLarge = 32;
  static const double fontSizeHeadlineMedium = 28;
  static const double fontSizeHeadlineSmall = 24;
  static const double fontSizeTitleLarge = 22;
  static const double fontSizeTitleMedium = 18;
  static const double fontSizeBodyLarge = 17;
  static const double fontSizeBodyMedium = 16;
  static const double fontSizeBodySmall = 14;
  static const double fontSizeLabelLarge = 14;
  static const double fontSizeLabelMedium = 12;
  static const double fontSizeLabelSmall = 11;

  // ========== 动画时长 ==========
  static const int durationFast = 150;
  static const int durationNormal = 250;
  static const int durationSlow = 350;
  static const int durationSlower = 500;
}

/// ========== 阴影定义 ==========
class AppShadows {
  static List<BoxShadow> get elevation0 => [];
  static List<BoxShadow> get elevation1 => [
        BoxShadow(
          color: const Color(0x0A000000),
          offset: const Offset(0, 1),
          blurRadius: 2,
        ),
      ];
  static List<BoxShadow> get elevation2 => [
        BoxShadow(
          color: const Color(0x0A000000),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];
  static List<BoxShadow> get elevation3 => [
        BoxShadow(
          color: const Color(0x10000000),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
      ];
  static List<BoxShadow> get elevation4 => [
        BoxShadow(
          color: const Color(0x14000000),
          offset: const Offset(0, 8),
          blurRadius: 16,
        ),
      ];
  static List<BoxShadow> get elevation5 => [
        BoxShadow(
          color: const Color(0x1A000000),
          offset: const Offset(0, 12),
          blurRadius: 24,
        ),
      ];
}

/// ========== 缓动曲线 ==========
class AppEasing {
  static const Curve standard = Cubic(0.4, 0.0, 0.2, 1);
  static const Curve emphasized = Cubic(0.0, 0.0, 0.2, 1);
  static const Curve decelerated = Cubic(0.0, 0.0, 0.2, 1);
  static const Curve accelerated = Cubic(0.4, 0.0, 1, 1);
}

/// ========== 亮色主题 ==========
class AppLightTheme {
  static ThemeData get data {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ========== 颜色方案 ==========
      colorScheme: ColorScheme.light(
        primary: AppTokens.primary,
        onPrimary: AppTokens.onPrimary,
        primaryContainer: AppTokens.primaryContainer,
        secondary: AppTokens.info,
        error: AppTokens.error,
        onError: AppTokens.white,
        surface: AppTokens.white,
        onSurface: AppTokens.gray900,
        errorContainer: AppTokens.errorLight,
      ),

      // ========== AppBar 主题 ==========
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppTokens.white,
        foregroundColor: AppTokens.gray900,
        titleTextStyle: TextStyle(
          fontSize: AppTokens.fontSizeHeadlineSmall,
          fontWeight: FontWeight.w600,
          color: AppTokens.gray900,
        ),
        iconTheme: IconThemeData(color: AppTokens.gray700),
      ),

      // ========== 卡片主题 ==========
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        ),
        color: AppTokens.white,
        margin: const EdgeInsets.all(AppTokens.spacing2),
      ),

      // ========== 按钮主题 ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacing6,
            vertical: AppTokens.spacing3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeTitleMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppTokens.primary,
          foregroundColor: AppTokens.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacing6,
            vertical: AppTokens.spacing3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeTitleMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacing4,
            vertical: AppTokens.spacing2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          textStyle: TextStyle(
            fontSize: AppTokens.fontSizeBodyMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========== 输入框主题 ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.gray50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacing4,
          vertical: AppTokens.spacing3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide(color: AppTokens.gray200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide(color: AppTokens.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide(color: AppTokens.error, width: 1),
        ),
        hintStyle: TextStyle(
          color: AppTokens.gray400,
          fontSize: AppTokens.fontSizeBodyMedium,
        ),
      ),

      // ========== 底部导航栏主题 ==========
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: AppTokens.white,
        selectedItemColor: AppTokens.primary,
        unselectedItemColor: AppTokens.gray400,
        selectedLabelStyle: TextStyle(
          fontSize: AppTokens.fontSizeLabelMedium,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppTokens.fontSizeLabelMedium,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
      ),

      // ========== 分割线主题 ==========
      dividerTheme: DividerThemeData(
        color: AppTokens.gray200,
        thickness: 1,
        space: 1,
      ),

      // ========== 对话框主题 ==========
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius2xl),
        ),
        elevation: 4,
      ),

      // ========== Snackbar 主题 ==========
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ========== 文本主题 ==========
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: AppTokens.fontSizeDisplayLarge,
          fontWeight: FontWeight.w400,
          color: AppTokens.gray900,
        ),
        displayMedium: TextStyle(
          fontSize: AppTokens.fontSizeDisplayMedium,
          fontWeight: FontWeight.w400,
          color: AppTokens.gray900,
        ),
        headlineLarge: TextStyle(
          fontSize: AppTokens.fontSizeHeadlineLarge,
          fontWeight: FontWeight.w600,
          color: AppTokens.gray900,
        ),
        headlineMedium: TextStyle(
          fontSize: AppTokens.fontSizeHeadlineMedium,
          fontWeight: FontWeight.w600,
          color: AppTokens.gray900,
        ),
        headlineSmall: TextStyle(
          fontSize: AppTokens.fontSizeHeadlineSmall,
          fontWeight: FontWeight.w600,
          color: AppTokens.gray900,
        ),
        titleLarge: TextStyle(
          fontSize: AppTokens.fontSizeTitleLarge,
          fontWeight: FontWeight.w600,
          color: AppTokens.gray900,
        ),
        titleMedium: TextStyle(
          fontSize: AppTokens.fontSizeTitleMedium,
          fontWeight: FontWeight.w500,
          color: AppTokens.gray900,
        ),
        bodyLarge: TextStyle(
          fontSize: AppTokens.fontSizeBodyLarge,
          fontWeight: FontWeight.w400,
          color: AppTokens.gray700,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTokens.fontSizeBodyMedium,
          fontWeight: FontWeight.w400,
          color: AppTokens.gray700,
        ),
        bodySmall: TextStyle(
          fontSize: AppTokens.fontSizeBodySmall,
          fontWeight: FontWeight.w400,
          color: AppTokens.gray500,
        ),
        labelLarge: TextStyle(
          fontSize: AppTokens.fontSizeLabelLarge,
          fontWeight: FontWeight.w600,
          color: AppTokens.gray700,
        ),
        labelMedium: TextStyle(
          fontSize: AppTokens.fontSizeLabelMedium,
          fontWeight: FontWeight.w500,
          color: AppTokens.gray500,
        ),
        labelSmall: TextStyle(
          fontSize: AppTokens.fontSizeLabelSmall,
          fontWeight: FontWeight.w500,
          color: AppTokens.gray500,
        ),
      ),
    );
  }
}

/// ========== 暗色主题 ==========
class AppDarkTheme {
  static ThemeData get data {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        primary: AppTokens.primaryLight,
        onPrimary: AppTokens.gray900,
        primaryContainer: AppTokens.gray800,
        secondary: AppTokens.info,
        error: AppTokens.error,
        onError: AppTokens.white,
        surface: AppTokens.gray800,
        onSurface: AppTokens.gray100,
      ),

      // 其他配置继承自亮色主题，只需覆盖颜色
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        ),
        color: AppTokens.gray800,
      ),
    );
  }
}
