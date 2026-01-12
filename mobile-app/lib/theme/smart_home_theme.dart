/// Open IoT Platform - 智能家居主题配置
/// 作者: 罗耀生
/// 版本: 2.0.0
/// 智能家居风格 - 温暖科技 + 场景化设计

import 'package:flutter/material.dart';

/// ========== 智能家居设计令牌 ==========
class SmartHomeTokens {
  // ========== 主色调 - 温暖科技 ==========
  static const Color primary = Color(0xFF6366F1);      // Indigo 500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark = Color(0xFF4F46E5);  // Indigo 600
  static const Color primaryContainer = Color(0xFFE0E7FF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // 强调色 - 温暖橙
  static const Color accent = Color(0xFFF59E0B);       // Amber 500
  static const Color accentLight = Color(0xFFFCD34D);  // Amber 400
  static const Color accentContainer = Color(0xFFFEF3C7);

  // 语义色
  static const Color success = Color(0xFF10B981);      // Emerald 500
  static const Color successLight = Color(0xFFD1FAE5); // Emerald 100
  static const Color warning = Color(0xFFF59E0B);      // Amber 500
  static const Color warningLight = Color(0xFFFEF3C7); // Amber 100
  static const Color error = Color(0xFFEF4444);        // Red 500
  static const Color errorLight = Color(0xFFFEE2E2);   // Red 100
  static const Color info = Color(0xFF06B6D4);         // Cyan 500

  // 背景渐变
  static const Color backgroundStart = Color(0xFFF8F9FC);
  static const Color backgroundEnd = Color(0xFFF0F2F8);

  // 中性色
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);

  // ========== 房间/场景色 ==========
  static const Color roomLiving = Color(0xFF6366F1);  // 客厅 - Indigo
  static const Color roomBedroom = Color(0xFF8B5CF6); // 卧室 - Purple
  static const Color roomKitchen = Color(0xFFF59E0B); // 厨房 - Amber
  static const Color roomBathroom = Color(0xFF06B6D4);// 浴室 - Cyan
  static const Color roomStudy = Color(0xFF10B981);   // 书房 - Emerald
  static const Color roomOther = Color(0xFF64748B);   // 其他 - Slate

  // ========== 间距 ==========
  static const double spacing0 = 0;
  static const double spacing2 = 4;
  static const double spacing4 = 8;
  static const double spacing6 = 12;
  static const double spacing8 = 16;
  static const double spacing10 = 20;
  static const double spacing12 = 24;
  static const double spacing16 = 32;
  static const double spacing20 = 40;

  // ========== 圆角 ==========
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radius2xl = 24;
  static const double radius3xl = 32;

  // ========== 字体 ==========
  static const double fontSizeDisplay = 36;
  static const double fontSizeHeadline = 28;
  static const double fontSizeTitle = 20;
  static const double fontSizeBody = 16;
  static const double fontSizeBodySmall = 14;
  static const double fontSizeCaption = 12;

  // ========== 动画 ==========
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 350);
  static const Curve curveEase = Curves.easeInOut;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseIn = Curves.easeIn;
}

/// ========== 智能家居渐变 ==========
class SmartHomeGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F9FC), Color(0xFFF0F2F8)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient coolGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
  );
}

/// ========== 智能家居阴影 ==========
class SmartHomeShadows {
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0x146366F1).withOpacity(0.08),
          offset: const Offset(0, 8),
          blurRadius: 30,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadowHover => [
        BoxShadow(
          color: const Color(0x146366F1).withOpacity(0.15),
          offset: const Offset(0, 12),
          blurRadius: 40,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: const Color(0x146366F1).withOpacity(0.3),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get buttonShadowPressed => [
        BoxShadow(
          color: const Color(0x146366F1).withOpacity(0.1),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];
}

/// ========== 智能家居亮色主题 ==========
class SmartHomeLightTheme {
  static ThemeData get data {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ========== 颜色方案 ==========
      colorScheme: ColorScheme.light(
        primary: SmartHomeTokens.primary,
        onPrimary: SmartHomeTokens.onPrimary,
        primaryContainer: SmartHomeTokens.primaryContainer,
        secondary: SmartHomeTokens.accent,
        error: SmartHomeTokens.error,
        onError: SmartHomeTokens.white,
        surface: SmartHomeTokens.white,
        onSurface: SmartHomeTokens.gray800,
        outline: SmartHomeTokens.gray200,
      ),

      // ========== 背景渐变 ==========
      scaffoldBackgroundColor: SmartHomeTokens.gray50,

      // ========== AppBar ==========
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: SmartHomeTokens.gray800,
        titleTextStyle: TextStyle(
          fontSize: SmartHomeTokens.fontSizeHeadline,
          fontWeight: FontWeight.w600,
          color: SmartHomeTokens.gray800,
        ),
        iconTheme: IconThemeData(
          color: SmartHomeTokens.gray700,
          size: 24,
        ),
      ),

      // ========== 卡片 ==========
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SmartHomeTokens.radiusXl),
        ),
        color: SmartHomeTokens.white,
        margin: const EdgeInsets.all(SmartHomeTokens.spacing4),
      ),

      // ========== 设备卡片 (自定义) ==========
      // 通过 widget 参数控制

      // ========== 按钮主题 ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: SmartHomeTokens.spacing12,
            vertical: SmartHomeTokens.spacing6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SmartHomeTokens.radiusLg),
          ),
          textStyle: TextStyle(
            fontSize: SmartHomeTokens.fontSizeBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SmartHomeTokens.primary,
          foregroundColor: SmartHomeTokens.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: SmartHomeTokens.spacing12,
            vertical: SmartHomeTokens.spacing6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SmartHomeTokens.radiusLg),
          ),
          textStyle: TextStyle(
            fontSize: SmartHomeTokens.fontSizeBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: SmartHomeTokens.spacing8,
            vertical: SmartHomeTokens.spacing4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SmartHomeTokens.radiusMd),
          ),
          textStyle: TextStyle(
            fontSize: SmartHomeTokens.fontSizeBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========== 开关 ==========
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SmartHomeTokens.white;
          }
          return SmartHomeTokens.gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SmartHomeTokens.primary;
          }
          return SmartHomeTokens.gray300;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      // ========== 滑块 ==========
      sliderTheme: SliderThemeData(
        activeTrackColor: SmartHomeTokens.primary,
        inactiveTrackColor: SmartHomeTokens.gray200,
        thumbColor: SmartHomeTokens.primary,
        overlayColor: SmartHomeTokens.primary.withOpacity(0.1),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
        ),
      ),

      // ========== 输入框 ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SmartHomeTokens.gray50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SmartHomeTokens.spacing8,
          vertical: SmartHomeTokens.spacing6,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SmartHomeTokens.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SmartHomeTokens.radiusLg),
          borderSide: BorderSide(color: SmartHomeTokens.gray200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SmartHomeTokens.radiusLg),
          borderSide: BorderSide(color: SmartHomeTokens.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SmartHomeTokens.radiusLg),
          borderSide: BorderSide(color: SmartHomeTokens.error, width: 1),
        ),
        hintStyle: TextStyle(
          color: SmartHomeTokens.gray400,
          fontSize: SmartHomeTokens.fontSizeBody,
        ),
      ),

      // ========== 底部导航栏 ==========
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: SmartHomeTokens.white,
        selectedItemColor: SmartHomeTokens.primary,
        unselectedItemColor: SmartHomeTokens.gray400,
        selectedLabelStyle: TextStyle(
          fontSize: SmartHomeTokens.fontSizeCaption,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: SmartHomeTokens.fontSizeCaption,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
      ),

      // ========== 分割线 ==========
      dividerTheme: DividerThemeData(
        color: SmartHomeTokens.gray200,
        thickness: 1,
        space: 1,
      ),

      // ========== 对话框 ==========
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SmartHomeTokens.radius2xl),
        ),
        elevation: 0,
        backgroundColor: SmartHomeTokens.white,
      ),

      // ========== Snackbar ==========
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SmartHomeTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // ========== 文本主题 ==========
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: SmartHomeTokens.fontSizeDisplay,
          fontWeight: FontWeight.w600,
          color: SmartHomeTokens.gray900,
        ),
        headlineLarge: TextStyle(
          fontSize: SmartHomeTokens.fontSizeHeadline,
          fontWeight: FontWeight.w600,
          color: SmartHomeTokens.gray900,
        ),
        headlineMedium: TextStyle(
          fontSize: SmartHomeTokens.fontSizeTitle,
          fontWeight: FontWeight.w600,
          color: SmartHomeTokens.gray900,
        ),
        titleLarge: TextStyle(
          fontSize: SmartHomeTokens.fontSizeTitle,
          fontWeight: FontWeight.w600,
          color: SmartHomeTokens.gray800,
        ),
        titleMedium: TextStyle(
          fontSize: SmartHomeTokens.fontSizeBody,
          fontWeight: FontWeight.w500,
          color: SmartHomeTokens.gray800,
        ),
        bodyLarge: TextStyle(
          fontSize: SmartHomeTokens.fontSizeBody,
          fontWeight: FontWeight.w400,
          color: SmartHomeTokens.gray700,
        ),
        bodyMedium: TextStyle(
          fontSize: SmartHomeTokens.fontSizeBodySmall,
          fontWeight: FontWeight.w400,
          color: SmartHomeTokens.gray600,
        ),
        bodySmall: TextStyle(
          fontSize: SmartHomeTokens.fontSizeCaption,
          fontWeight: FontWeight.w400,
          color: SmartHomeTokens.gray500,
        ),
        labelLarge: TextStyle(
          fontSize: SmartHomeTokens.fontSizeBodySmall,
          fontWeight: FontWeight.w600,
          color: SmartHomeTokens.gray700,
        ),
        labelMedium: TextStyle(
          fontSize: SmartHomeTokens.fontSizeCaption,
          fontWeight: FontWeight.w500,
          color: SmartHomeTokens.gray500,
        ),
      ),
    );
  }
}

/// ========== 智能家居暗色主题 ==========
class SmartHomeDarkTheme {
  static ThemeData get data {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        primary: SmartHomeTokens.primaryLight,
        onPrimary: SmartHomeTokens.gray900,
        primaryContainer: SmartHomeTokens.gray800,
        secondary: SmartHomeTokens.accent,
        error: SmartHomeTokens.error,
        onError: SmartHomeTokens.white,
        surface: SmartHomeTokens.gray800,
        onSurface: SmartHomeTokens.gray100,
      ),

      scaffoldBackgroundColor: SmartHomeTokens.gray900,

      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SmartHomeTokens.radiusXl),
        ),
        color: SmartHomeTokens.gray800,
      ),

      // 其他配置继承亮色主题，只覆盖颜色
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: SmartHomeTokens.gray800,
        selectedItemColor: SmartHomeTokens.primaryLight,
        unselectedItemColor: SmartHomeTokens.gray500,
      ),
    );
  }
}

/// ========== 智能家居设备卡片样式 ==========
class SmartHomeCardStyles {
  // 设备卡片装饰
  static BoxDecoration deviceCardDecoration = BoxDecoration(
    color: SmartHomeTokens.white,
    borderRadius: BorderRadius.circular(SmartHomeTokens.radiusXl),
    boxShadow: SmartHomeShadows.cardShadow,
  );

  // 设备卡片装饰（悬停）
  static BoxDecoration deviceCardDecorationHover = BoxDecoration(
    color: SmartHomeTokens.white,
    borderRadius: BorderRadius.circular(SmartHomeTokens.radiusXl),
    boxShadow: SmartHomeShadows.cardShadowHover,
  );

  // 图标容器装饰
  static BoxDecoration iconContainer(String roomType) {
    Color backgroundColor;
    switch (roomType) {
      case 'living':
        backgroundColor = SmartHomeTokens.roomLiving;
        break;
      case 'bedroom':
        backgroundColor = SmartHomeTokens.roomBedroom;
        break;
      case 'kitchen':
        backgroundColor = SmartHomeTokens.roomKitchen;
        break;
      case 'bathroom':
        backgroundColor = SmartHomeTokens.roomBathroom;
        break;
      case 'study':
        backgroundColor = SmartHomeTokens.roomStudy;
        break;
      default:
        backgroundColor = SmartHomeTokens.roomOther;
    }

    return BoxDecoration(
      color: backgroundColor.withOpacity(0.15),
      borderRadius: BorderRadius.circular(SmartHomeTokens.radiusMd),
    );
  }

  // 场景卡片装饰
  static BoxDecoration sceneCardDecoration(Color gradientColor) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          gradientColor.withOpacity(0.8),
          gradientColor,
        ],
      ),
      borderRadius: BorderRadius.circular(SmartHomeTokens.radiusXl),
      boxShadow: [
        BoxShadow(
          color: gradientColor.withOpacity(0.3),
          offset: const Offset(0, 8),
          blurRadius: 20,
        ),
      ],
    );
  }
}
