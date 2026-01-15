/// 启动页
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_tokens.dart';
import '../../core/app_router.dart';
import '../../widgets/app_icon.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // 等待AuthProvider初始化完成
    final authProvider = context.read<AuthProvider>();

    // 确保初始化完成
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // 检查登录状态
    if (authProvider.isAuthenticated) {
      AppRouter.goToMain(context);
    } else {
      AppRouter.goToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: AppIcon(AppIcons.bolt, size: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Open IoT',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3A3A3C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '智能设备配置工具',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 80),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
