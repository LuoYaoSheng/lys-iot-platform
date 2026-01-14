/// 注册页
/// 作者: 罗耀生
/// 日期: 2026-01-13

import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/app_toast.dart';
import '../../core/routes.dart';
import '../../core/app_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          AppIcons.arrowBack,
          onPressed: () => AppRouter.goBack(context),
        ),
        title: const Text('注册'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingXL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '创建新账号',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '请填写注册信息',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppInput(
                controller: _emailController,
                label: '邮箱',
                hint: '请输入邮箱',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.md),
              AppInput(
                controller: _passwordController,
                label: '密码',
                hint: '请输入密码',
                obscureText: true,
              ),
              const SizedBox(height: AppSpacing.md),
              AppInput(
                controller: _confirmPasswordController,
                label: '确认密码',
                hint: '请再次输入密码',
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleRegister(),
              ),
              const SizedBox(height: AppSpacing.md),

              // 黄色提示badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: AppRadius.borderRadiusMD,
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '密码至少 8 位，包含字母和数字',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: '注 册',
                type: AppButtonType.primary,
                isLoading: _isLoading,
                isFullWidth: true,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => AppRouter.goToLogin(context),
                  child: const Text('返回登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    // 验证密码
    if (_passwordController.text != _confirmPasswordController.text) {
      AppToast.error(context, '两次密码不一致');
      return;
    }

    if (_passwordController.text.length < 8) {
      AppToast.error(context, '密码至少需要 8 位');
      return;
    }

    setState(() => _isLoading = true);

    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);
    AppToast.success(context, '注册成功');
    AppRouter.goToLogin(context);
  }
}
