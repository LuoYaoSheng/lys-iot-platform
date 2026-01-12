/// 注册页面
/// 作者: 罗耀生
/// 版本: 3.0.0
/// 使用 Design System 组件

import 'package:flutter/material.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import '../design_system/design_system.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sdk = IoTSdk.instance;
      final result = await sdk.auth.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        // 注册成功，显示提示并返回登录页
        MinimalToast.showSuccess(context, '注册成功！请登录');
        Navigator.pop(context);
      } else {
        String errorMsg = result.message;
        // 友好化错误消息
        if (errorMsg.contains('email_exists')) {
          errorMsg = '该邮箱已被注册';
        } else if (errorMsg.contains('weak_password')) {
          errorMsg = '密码强度不够，需要包含大小写字母、数字和特殊字符';
        }
        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '注册失败: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalTokens.white,
      appBar: AppBar(
        backgroundColor: MinimalTokens.white,
        elevation: 0,
        title: const Text('注册账号'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: MinimalEdgeInsets.xxl,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 标题
                Text(
                  '创建新账号',
                  style: TextStyle(
                    fontSize: MinimalTokens.fontSizeTitle,
                    fontWeight: MinimalTokens.fontWeightSemiBold,
                    color: MinimalTokens.gray900,
                  ),
                ),
                const MinimalSpacer(size: MinimalSpacing.sm),
                Text(
                  '请填写以下信息完成注册',
                  style: TextStyle(
                    fontSize: MinimalTokens.fontSizeBodySmall,
                    color: MinimalTokens.gray500,
                  ),
                ),
                const MinimalSpacer(size: MinimalSpacing.xl),

                // 错误提示
                if (_errorMessage != null)
                  Container(
                    padding: MinimalEdgeInsets.md,
                    margin: const EdgeInsets.only(bottom: MinimalSpacing.md),
                    decoration: BoxDecoration(
                      color: MinimalTokens.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MinimalTokens.radiusMd),
                      border: Border.all(color: MinimalTokens.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: MinimalTokens.error, size: 20),
                        const SizedBox(width: MinimalSpacing.sm),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: MinimalTokens.error),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 用户名输入
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    hintText: '请输入用户名',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入用户名';
                    }
                    if (value.length < 2) {
                      return '用户名至少2个字符';
                    }
                    return null;
                  },
                ),
                const MinimalSpacer(size: MinimalSpacing.md),

                // 邮箱输入
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    hintText: '请输入邮箱地址',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入邮箱';
                    }
                    if (!value.contains('@')) {
                      return '请输入有效的邮箱地址';
                    }
                    return null;
                  },
                ),
                const MinimalSpacer(size: MinimalSpacing.md),

                // 密码输入
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: '需包含大小写字母、数字和特殊字符',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 8) {
                      return '密码至少8个字符';
                    }
                    return null;
                  },
                ),
                const MinimalSpacer(size: MinimalSpacing.md),

                // 确认密码
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: '确认密码',
                    hintText: '请再次输入密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请确认密码';
                    }
                    if (value != _passwordController.text) {
                      return '两次输入的密码不一致';
                    }
                    return null;
                  },
                ),
                const MinimalSpacer(size: MinimalSpacing.md),

                // 密码要求提示
                Container(
                  padding: MinimalEdgeInsets.md,
                  decoration: BoxDecoration(
                    color: MinimalTokens.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(MinimalTokens.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: MinimalTokens.primary),
                          const SizedBox(width: MinimalSpacing.sm),
                          Text(
                            '密码要求',
                            style: TextStyle(
                              fontWeight: MinimalTokens.fontWeightMedium,
                              color: MinimalTokens.primary,
                            ),
                          ),
                        ],
                      ),
                      const MinimalSpacer(size: MinimalSpacing.sm),
                      Text(
                        '• 至少8个字符\n• 包含大写字母\n• 包含小写字母\n• 包含数字\n• 包含特殊字符 (!@#\$%^&*)',
                        style: TextStyle(
                          fontSize: MinimalTokens.fontSizeCaption,
                          color: MinimalTokens.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const MinimalSpacer(size: MinimalSpacing.xl),

                // 注册按钮
                FilledButton(
                  onPressed: _isLoading ? null : _register,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: MinimalSpacing.md),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('注 册', style: TextStyle(fontSize: 16)),
                ),
                const MinimalSpacer(size: MinimalSpacing.md),

                // 返回登录
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '已有账号？',
                      style: TextStyle(
                        color: MinimalTokens.gray500,
                        fontSize: MinimalTokens.fontSizeBody,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('返回登录'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
