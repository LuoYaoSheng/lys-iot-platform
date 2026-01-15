/// 登录页
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_tokens.dart';
import '../../core/app_router.dart';
import '../../widgets/app_icon.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  String _serverUrl = 'http://117.50.216.173:48080';

  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadServerUrl() async {
    final client = ApiClient();
    setState(() {
      _serverUrl = client.baseUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 主内容
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: AppIcon(AppIcons.bolt, size: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Open IoT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3A3A3C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '欢迎回来，请登录',
                    style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                  ),
                  const SizedBox(height: 40),

                  // 邮箱输入
                  _buildInput(
                    controller: _emailController,
                    hint: '邮箱',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // 密码输入
                  _buildInput(
                    controller: _passwordController,
                    hint: '密码',
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
                  const SizedBox(height: 8),

                  // 忘记密码
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => AppRouter.goToForgotPassword(context),
                      child: const Text('忘记密码？', style: TextStyle(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 登录按钮
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('登录', style: TextStyle(fontSize: 16)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 注册链接
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('还没有账号？', style: TextStyle(color: Color(0xFF8E8E93))),
                      TextButton(
                        onPressed: () => AppRouter.goToRegister(context),
                        child: const Text('立即注册', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 右上角设置按钮
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: _showServerConfig,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: AppIcon(AppIcons.settings, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServerConfig() {
    final controller = TextEditingController(text: _serverUrl);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E5EA), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text('服务器配置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              const Align(alignment: Alignment.centerLeft, child: Text('API 服务器地址', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)))),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final client = ApiClient();
                    await client.setBaseUrl(controller.text);
                    setState(() => _serverUrl = controller.text);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('保存配置', style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFC7C7CC)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: suffix,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
        ),
      ),
    );
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入邮箱和密码')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(email: email, password: password);

    if (!mounted) return;

    if (success) {
      AppRouter.goToMain(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? '登录失败')),
      );
      auth.clearError();
    }
  }
}
