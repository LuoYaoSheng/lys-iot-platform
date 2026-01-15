/// 路由导航器
/// 作者: 罗耀生
/// 日期: 2026-01-13

import 'package:flutter/material.dart';
import 'routes.dart';
import '../pages/splash/splash_screen.dart';
import '../pages/main/main_screen.dart';
import '../pages/auth/login_screen.dart';
import '../pages/auth/register_screen.dart';
import '../pages/auth/forgot_password_screen.dart';
import '../pages/device/device_list_screen.dart';
import '../pages/device/scan_screen.dart';
import '../pages/device/config_screen.dart';
import '../pages/device/device_control_screen.dart';
import '../pages/settings/settings_screen.dart';
import '../pages/settings/about_screen.dart';

/// 路由管理器
class AppRouter {
  /// 生成路由
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.main:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case AppRoutes.deviceList:
        return MaterialPageRoute(builder: (_) => const DeviceListScreen());

      case AppRoutes.scan:
        return MaterialPageRoute(builder: (_) => const ScanScreen());


      case AppRoutes.config:
        return MaterialPageRoute(builder: (_) => const ConfigScreen());





      case AppRoutes.control:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DeviceControlScreen(
            deviceId: args?['deviceId'] ?? '',
          ),
        );

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('未找到路由: ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// 导航到登录页（清除历史）
  static void goToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  /// 导航到主页（清除历史）
  static void goToMain(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.main,
      (route) => false,
    );
  }

  /// 导航到设备列表（清除历史）- 重定向到主页
  static void goToDeviceList(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.main,
      (route) => false,
    );
  }

  /// 导航到注册页
  static void goToRegister(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.register);
  }

  /// 导航到忘记密码页
  static void goToForgotPassword(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
  }

  /// 导航到扫码页
  static void goToScan(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.scan);
  }

  /// 导航到配置页
  static void goToConfig(BuildContext context, Map<String, dynamic>? deviceInfo) {
    Navigator.of(context).pushNamed(
      AppRoutes.config,
      arguments: deviceInfo,
    );
  }

  /// 导航到控制页
  static void goToControl(BuildContext context, String deviceId) {
    Navigator.of(context).pushNamed(
      AppRoutes.control,
      arguments: {'deviceId': deviceId},
    );
  }

  /// 导航到设置页
  static void goToSettings(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.settings);
  }

  /// 导航到关于页
  static void goToAbout(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.about);
  }

  /// 返回上一页
  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.of(context).pop(result);
  }
}
