/// Open IoT Platform - 简洁主题配置
/// 作者: 罗耀生
/// 版本: 3.0.0
/// 设计风格: 简洁、单色、专业
///
/// 此文件统一使用 design_system 中的设计令牌

import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

/// ========== 简洁亮色主题 ==========
/// 基于 Design System Tokens 构建的完整 Flutter 主题
class MinimalLightTheme {
  static ThemeData get data {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ========== 颜色方案 ==========
      colorScheme: ColorScheme.light(
        primary: MinimalTokens.primary,
        onPrimary: MinimalTokens.white,
        primaryContainer: MinimalTokens.gray50,
        secondary: MinimalTokens.secondary,
        error: MinimalTokens.error,
        onError: MinimalTokens.white,
        surface: MinimalTokens.white,
        onSurface: MinimalTokens.gray700,
        outline: MinimalTokens.gray200,
      ),

      // ========== 背景 ==========
      scaffoldBackgroundColor: MinimalTokens.gray50,

      // ========== AppBar ==========
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: MinimalTokens.white,
        foregroundColor: MinimalTokens.gray700,
        titleTextStyle: TextStyle(
          fontSize: MinimalTokens.fontSizeTitle,
          fontWeight: MinimalTokens.fontWeightSemiBold,
          color: MinimalTokens.gray700,
        ),
        iconTheme: IconThemeData(
          color: MinimalTokens.gray700,
          size: 24,
        ),
      ),

      // ========== 卡片 ==========
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: MinimalBorderRadius.lg,
        ),
        color: MinimalTokens.white,
        margin: const EdgeInsets.all(MinimalTokens.spacing4),
      ),

      // ========== 按钮 ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: MinimalTokens.spacing24,
            vertical: MinimalTokens.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MinimalTokens.radiusMd),
          ),
          textStyle: TextStyle(
            fontSize: MinimalTokens.fontSizeBody,
            fontWeight: MinimalTokens.fontWeightMedium,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MinimalTokens.primary,
          foregroundColor: MinimalTokens.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: MinimalTokens.spacing24,
            vertical: MinimalTokens.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MinimalTokens.radiusMd),
          ),
          textStyle: TextStyle(
            fontSize: MinimalTokens.fontSizeBody,
            fontWeight: MinimalTokens.fontWeightMedium,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MinimalTokens.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: MinimalTokens.spacing12,
            vertical: MinimalTokens.spacing8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MinimalTokens.radiusMd),
          ),
          textStyle: TextStyle(
            fontSize: MinimalTokens.fontSizeBody,
            fontWeight: MinimalTokens.fontWeightMedium,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: MinimalTokens.spacing24,
            vertical: MinimalTokens.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MinimalTokens.radiusMd),
          ),
          side: BorderSide(color: MinimalTokens.primary, width: 1),
          textStyle: TextStyle(
            fontSize: MinimalTokens.fontSizeBody,
            fontWeight: MinimalTokens.fontWeightMedium,
          ),
        ),
      ),

      // ========== 开关 ==========
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MinimalTokens.white;
          }
          return MinimalTokens.gray300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MinimalTokens.primary;
          }
          return MinimalTokens.gray300;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      // ========== 输入框 ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MinimalTokens.gray50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MinimalTokens.spacing16,
          vertical: MinimalTokens.spacing12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MinimalTokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MinimalTokens.radiusMd),
          borderSide: BorderSide(color: MinimalTokens.gray200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MinimalTokens.radiusMd),
          borderSide: BorderSide(color: MinimalTokens.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MinimalTokens.radiusMd),
          borderSide: BorderSide(color: MinimalTokens.error, width: 1),
        ),
        hintStyle: TextStyle(
          color: MinimalTokens.gray500,
          fontSize: MinimalTokens.fontSizeBody,
        ),
      ),

      // ========== 底部导航栏 ==========
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: MinimalTokens.white,
        selectedItemColor: MinimalTokens.primary,
        unselectedItemColor: MinimalTokens.gray500,
        selectedLabelStyle: TextStyle(
          fontSize: MinimalTokens.fontSizeCaption,
          fontWeight: MinimalTokens.fontWeightMedium,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: MinimalTokens.fontSizeCaption,
          fontWeight: MinimalTokens.fontWeightRegular,
        ),
        type: BottomNavigationBarType.fixed,
      ),

      // ========== 分割线 ==========
      dividerTheme: DividerThemeData(
        color: MinimalTokens.gray100,
        thickness: 1,
        space: 1,
      ),

      // ========== 对话框 ==========
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MinimalTokens.radiusLg),
        ),
        elevation: 0,
        backgroundColor: MinimalTokens.white,
      ),

      // ========== Snackbar ==========
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MinimalTokens.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: MinimalTokens.gray700,
      ),

      // ========== 文本主题 ==========
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: MinimalTokens.fontSizeLarge,
          fontWeight: MinimalTokens.fontWeightSemiBold,
          color: MinimalTokens.gray900,
        ),
        headlineMedium: TextStyle(
          fontSize: MinimalTokens.fontSizeTitle,
          fontWeight: MinimalTokens.fontWeightSemiBold,
          color: MinimalTokens.gray700,
        ),
        titleLarge: TextStyle(
          fontSize: MinimalTokens.fontSizeTitle,
          fontWeight: MinimalTokens.fontWeightSemiBold,
          color: MinimalTokens.gray700,
        ),
        titleMedium: TextStyle(
          fontSize: MinimalTokens.fontSizeBody,
          fontWeight: MinimalTokens.fontWeightMedium,
          color: MinimalTokens.gray700,
        ),
        bodyLarge: TextStyle(
          fontSize: MinimalTokens.fontSizeBody,
          fontWeight: MinimalTokens.fontWeightRegular,
          color: MinimalTokens.gray700,
        ),
        bodyMedium: TextStyle(
          fontSize: MinimalTokens.fontSizeBodySmall,
          fontWeight: MinimalTokens.fontWeightRegular,
          color: MinimalTokens.gray500,
        ),
        bodySmall: TextStyle(
          fontSize: MinimalTokens.fontSizeCaption,
          fontWeight: MinimalTokens.fontWeightRegular,
          color: MinimalTokens.gray500,
        ),
        labelLarge: TextStyle(
          fontSize: MinimalTokens.fontSizeBodySmall,
          fontWeight: MinimalTokens.fontWeightMedium,
          color: MinimalTokens.gray700,
        ),
      ),
    );
  }
}
