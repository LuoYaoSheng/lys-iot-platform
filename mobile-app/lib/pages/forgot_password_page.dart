/// 忘记密码页面
/// 作者: 罗耀生
/// 版本: 1.0.0
///
/// 流程：输入邮箱 -> 获取重置令牌 -> 输入令牌和新密码 -> 完成重置

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../design_system/design_system.dart';
import '../widgets/brand_logo.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final PageController _pageController = PageController();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _resetToken;
  String _currentServerUrl = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentServer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentServer() async {
    final prefs = await SharedPreferences.getInstance();
    final customUrl = prefs.getString('custom_api_url');
    final defaultUrl = 'http://192.168.1.100:48080'; // 默认地址

    if (mounted) {
      setState(() {
        _currentServerUrl = customUrl ?? defaultUrl;
      });
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalTokens.white,
      appBar: AppBar(
        backgroundColor: MinimalTokens.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final currentPage = _pageController.page ?? 0;
            if (currentPage > 0) {
              _goToPage(0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _EmailStep(
              emailController: _emailController,
              onContinue: (token) {
                setState(() => _resetToken = token);
                _goToPage(1);
              },
              serverUrl: _currentServerUrl,
            ),
            _ResetStep(
              tokenController: _tokenController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              resetToken: _resetToken,
              onSuccess: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              serverUrl: _currentServerUrl,
            ),
          ],
        ),
      ),
    );
  }
}

/// 步骤1：输入邮箱
class _EmailStep extends StatefulWidget {
  final TextEditingController emailController;
  final Function(String token) onContinue;
  final String serverUrl;

  const _EmailStep({
    required this.emailController,
    required this.onContinue,
    required this.serverUrl,
  });

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _requestReset() async {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _makeRequest();

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody);
        String? token;

        // 开发模式直接返回令牌
        if (data['data'] != null && data['data']['token'] != null) {
          token = data['data']['token'];
        }

        // 显示成功对话框
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => _TokenDialog(token: token),
          );

          if (token != null) {
            widget.onContinue(token);
          }
        }
      } else {
        setState(() {
          _errorMessage = '请求失败，请稍后重试';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '网络错误: $e';
      });
    }
  }

  Future<HttpClientResponse> _makeRequest() async {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;

    final request = await client.postUrl(
      Uri.parse('${widget.serverUrl}/api/v1/users/password/reset/request'),
    );

    request.headers.contentType = ContentType.json;
    request.write(json.encode({
      'email': widget.emailController.text.trim(),
    }));

    return await request.close();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Logo
            const BrandLogo(size: 64),

            const SizedBox(height: 16),

            Text(
              '忘记密码',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: MinimalTokens.gray900,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              '请输入您的注册邮箱',
              style: TextStyle(
                fontSize: 14,
                color: MinimalTokens.gray500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // 错误提示
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: MinimalTokens.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MinimalTokens.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: MinimalTokens.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: MinimalTokens.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // 邮箱输入
            TextFormField(
              controller: widget.emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: '邮箱',
                hintText: '请输入注册邮箱',
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
              onFieldSubmitted: (_) => _requestReset(),
            ),

            const SizedBox(height: 24),

            // 发送按钮
            FilledButton(
              onPressed: _isLoading ? null : _requestReset,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('发送重置令牌'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 令牌对话框
class _TokenDialog extends StatelessWidget {
  final String? token;

  const _TokenDialog({this.token});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('重置令牌已生成'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('请使用以下令牌重置密码：'),
          const SizedBox(height: 12),
          if (token != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MinimalTokens.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                token!,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MinimalTokens.primary,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            '令牌有效期为1小时',
            style: TextStyle(
              fontSize: 12,
              color: MinimalTokens.gray500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('确定'),
        ),
      ],
    );
  }
}

/// 步骤2：输入令牌和新密码
class _ResetStep extends StatefulWidget {
  final TextEditingController tokenController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? resetToken;
  final VoidCallback onSuccess;
  final String serverUrl;

  const _ResetStep({
    required this.tokenController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.resetToken,
    required this.onSuccess,
    required this.serverUrl,
  });

  @override
  State<_ResetStep> createState() => _ResetStepState();
}

class _ResetStepState extends State<_ResetStep> {
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.resetToken != null) {
      widget.tokenController.text = widget.resetToken!;
    }
  }

  Future<void> _resetPassword() async {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _makeRequest();

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('密码重置成功，请登录'),
              backgroundColor: MinimalTokens.success,
            ),
          );
          widget.onSuccess();
        }
      } else {
        final body = await response.transform(utf8.decoder).join();
        setState(() {
          _errorMessage = _parseError(body);
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '网络错误: $e';
      });
    }
  }

  Future<HttpClientResponse> _makeRequest() async {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;

    final request = await client.postUrl(
      Uri.parse('${widget.serverUrl}/api/v1/users/password/reset/confirm'),
    );

    request.headers.contentType = ContentType.json;
    request.write(json.encode({
      'token': widget.tokenController.text.trim(),
      'password': widget.passwordController.text,
    }));

    return await request.close();
  }

  String _parseError(String body) {
    try {
      final data = json.decode(body);
      return data['message'] ?? '重置失败';
    } catch (_) {
      return '重置失败，请检查令牌是否正确';
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // 图标
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: MinimalTokens.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_reset, color: MinimalTokens.primary, size: 32),
            ),

            const SizedBox(height: 16),

            Text(
              '重置密码',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: MinimalTokens.gray900,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              '请输入重置令牌和新密码',
              style: TextStyle(
                fontSize: 14,
                color: MinimalTokens.gray500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // 错误提示
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: MinimalTokens.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: MinimalTokens.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: MinimalTokens.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: MinimalTokens.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // 令牌输入
            TextFormField(
              controller: widget.tokenController,
              decoration: const InputDecoration(
                labelText: '重置令牌',
                hintText: '请输入重置令牌',
                prefixIcon: Icon(Icons.vpn_key_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入重置令牌';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 新密码
            TextFormField(
              controller: widget.passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: '新密码',
                hintText: '至少8位，包含大小写字母和数字',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入新密码';
                }
                if (value.length < 8) {
                  return '密码至少8位';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 确认密码
            TextFormField(
              controller: widget.confirmPasswordController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: '确认密码',
                hintText: '请再次输入新密码',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请确认密码';
                }
                if (value != widget.passwordController.text) {
                  return '两次输入的密码不一致';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // 重置按钮
            FilledButton(
              onPressed: _isLoading ? null : _resetPassword,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('重置密码'),
            ),
          ],
        ),
      ),
    );
  }
}
