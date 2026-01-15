/// 注册页
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';
import '../../core/app_router.dart';
import '../../widgets/app_icon.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('注册'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3A3A3C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 邮箱
            _buildLabel('邮箱'),
            _buildInput(controller: _emailController, hint: '请输入邮箱'),
            const SizedBox(height: 16),

            // 密码
            _buildLabel('密码'),
            _buildInput(
              controller: _passwordController,
              hint: '请输入密码',
              obscureText: !_showPassword,
              suffix: GestureDetector(
                onTap: () => setState(() => _showPassword = !_showPassword),
                child: AppIcon(
                  _showPassword ? AppIcons.eyeOff : AppIcons.eye,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 确认密码
            _buildLabel('确认密码'),
            _buildInput(
              controller: _confirmController,
              hint: '请再次输入密码',
              obscureText: !_showPassword,
            ),
            const SizedBox(height: 16),

            // 提示
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  AppIcon(AppIcons.warning, size: 18, color: const Color(0xFFFF9500)),
                  const SizedBox(width: 8),
                  const Text(
                    '密码至少8位，包含字母和数字',
                    style: TextStyle(fontSize: 14, color: Color(0xFFFF9500)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 注册按钮
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('注册', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // 返回登录
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('已有账号？', style: TextStyle(color: Color(0xFF8E8E93))),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('返回登录', style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF3A3A3C)),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFC7C7CC)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffix != null
              ? Padding(padding: const EdgeInsets.only(right: 16), child: suffix)
              : null,
          suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('两次密码不一致')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('注册成功')),
    );
    Navigator.pop(context);
  }
}
