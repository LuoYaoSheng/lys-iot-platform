/// 登录页面 - 简洁风格
/// 作者: 罗耀生
/// 日期: 2025-12-15
/// 更新: 2025-01-11 - 应用简洁设计风格
/// 更新: 2025-01-12 - 使用品牌 Logo 和 Bottom Sheet 配置

import 'package:flutter/material.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'register_page.dart';
import '../main.dart';
import '../design_system/design_system.dart';
import '../widgets/brand_logo.dart';
import 'home_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String _currentServerUrl = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentServer();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentServer() async {
    final prefs = await SharedPreferences.getInstance();
    final customUrl = prefs.getString('custom_api_url');
    final defaultUrl = IoTConfig.fromEnvironment().apiBaseUrl;

    if (mounted) {
      setState(() {
        _currentServerUrl = customUrl ?? defaultUrl;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sdk = IoTSdk.instance;
      final success = await sdk.login(
        username: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        setState(() {
          _errorMessage = '邮箱或密码错误';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '登录失败: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showServerConfigDialog() async {
    if (!mounted) return;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ServerConfigBottomSheet(
        currentUrl: _currentServerUrl,
      ),
    );

    if (!mounted) return;

    if (result != null && result.isNotEmpty) {
      // 更新显示的服务器地址
      await _loadCurrentServer();

      // 显示重启确认对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('配置已保存'),
          content: const Text('应用即将重启以应用新配置...'),
          actions: [
            FilledButton(
              onPressed: () => exit(0),
              child: const Text('立即重启'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalTokens.white,
      appBar: AppBar(
        backgroundColor: MinimalTokens.white,
        elevation: 0,
        actions: [
          // 服务器配置按钮（小图标+文字）
          TextButton.icon(
            onPressed: _showServerConfigDialog,
            icon: const Icon(Icons.settings_rounded, size: 18),
            label: const Text('配置', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: MinimalTokens.gray700,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // 品牌 Logo
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: MinimalTokens.white,
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 标题
                const Text(
                  '智开',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: MinimalTokens.gray900,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  '欢迎回来，请登录',
                  style: TextStyle(
                    fontSize: 14,
                    color: MinimalTokens.gray500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // 错误提示
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: MinimalTokens.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: MinimalTokens.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: MinimalTokens.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: MinimalTokens.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

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

                const SizedBox(height: 16),

                // 密码输入
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: '请输入密码',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_outlined,
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
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // 忘记密码 + 服务器地址
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('忘记密码？'),
                    ),
                    Text(
                      _currentServerUrl.isNotEmpty ? _currentServerUrl : '加载中...',
                      style: TextStyle(
                        fontSize: 12,
                        color: MinimalTokens.gray500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 登录按钮
                FilledButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('登录'),
                ),

                const SizedBox(height: 16),

                // 注册链接
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '还没有账号？',
                      style: TextStyle(
                        color: MinimalTokens.gray500,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: const Text('立即注册'),
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

/// 服务器配置 Bottom Sheet
class _ServerConfigBottomSheet extends StatefulWidget {
  final String currentUrl;

  const _ServerConfigBottomSheet({required this.currentUrl});

  @override
  State<_ServerConfigBottomSheet> createState() => _ServerConfigBottomSheetState();
}

class _ServerConfigBottomSheetState extends State<_ServerConfigBottomSheet> {
  late final TextEditingController _apiUrlController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiUrlController = TextEditingController(text: widget.currentUrl);
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    final apiUrl = _apiUrlController.text.trim();
    if (apiUrl.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_api_url', apiUrl);

      try {
        final uri = Uri.parse(apiUrl);
        await prefs.setString('custom_mqtt_host', uri.host);
        await prefs.setInt('custom_mqtt_port', 42883);
      } catch (e) {
        await prefs.remove('custom_mqtt_host');
        await prefs.remove('custom_mqtt_port');
      }

      if (mounted) {
        Navigator.pop(context, apiUrl);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: MinimalTokens.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: MinimalTokens.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动指示器
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: MinimalTokens.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 标题
          Stack(
            children: [
              Center(
                child: Text(
                  '服务器配置',
                  style: TextStyle(
                    fontSize: MinimalTokens.fontSizeTitle,
                    fontWeight: FontWeight.w600,
                    color: MinimalTokens.gray900,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: MinimalTokens.gray500),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // API 服务器地址输入
          TextField(
            controller: _apiUrlController,
            decoration: const InputDecoration(
              labelText: 'API 服务器地址',
              hintText: 'http://192.168.1.100:48080',
              helperText: '请输入服务器地址，如 http://192.168.1.100:48080',
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 24),

          // 保存按钮
          FilledButton(
            onPressed: _isLoading ? null : _saveConfig,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
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
                : const Text('保存配置'),
          ),
        ],
      ),
    );
  }
}
