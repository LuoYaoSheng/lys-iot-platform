/// Open IoT Platform - 移动端配置应用
/// 主入口文件
/// 作者: 罗耀生
/// 日期: 2026-01-13

import 'package:flutter/material.dart';
import 'core/app_router.dart';
import 'core/routes.dart';
import 'pages/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Config',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
