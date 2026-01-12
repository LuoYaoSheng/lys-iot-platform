/// 设置页面
/// 作者: 罗耀生
/// 版本: 3.0.0
/// 使用 Design System 组件

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system/design_system.dart';
import '../config/app_config.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currentApiUrl = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  Future<void> _loadCurrentConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customApiUrl = prefs.getString('custom_api_url');

      if (mounted) {
        setState(() {
          _currentApiUrl = customApiUrl ?? IoTConfig.fromEnvironment().apiBaseUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentApiUrl = IoTConfig.fromEnvironment().apiBaseUrl;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await IoTSdk.instance.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = IoTSdk.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 用户信息卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: MinimalTokens.primary),
                      const SizedBox(width: 8),
                      const Text(
                        '账号信息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('用户名', user?.username ?? '未登录'),
                  _buildInfoRow('邮箱', user?.email ?? '-'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 服务器配置卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dns, color: MinimalTokens.primary),
                      const SizedBox(width: 8),
                      const Text(
                        '服务器配置',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('API 服务器', _currentApiUrl.isNotEmpty ? _currentApiUrl : '加载中...'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: MinimalTokens.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: MinimalTokens.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: MinimalTokens.primary, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '服务器地址在登录页面统一配置，\n配网时会自动使用该地址。',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // 返回到个人中心页
                        // TODO: 可以在这里跳转到登录页修改服务器配置
                      },
                      icon: const Icon(Icons.help_outline),
                      label: const Text('如何修改服务器地址？'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 关于卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: MinimalTokens.primary),
                      const SizedBox(width: 8),
                      const Text(
                        '关于',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('应用名称', AppConfig.appName),
                  _buildInfoRow('版本', AppConfig.appVersion),
                  _buildInfoRow('作者', AppConfig.author),
                  _buildCopiableRow('邮箱', AppConfig.email),
                  _buildCopiableRow('官网', AppConfig.website),
                  _buildCopiableRow('项目官网', AppConfig.projectWebsite),
                  _buildCopiableRow('Git 地址', AppConfig.gitUrl),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 退出登录按钮
          FilledButton.icon(
            onPressed: _logout,
            style: FilledButton.styleFrom(
              backgroundColor: MinimalTokens.error,
              foregroundColor: MinimalTokens.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('退出登录'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: MinimalTokens.gray700)),
          Text(value),
        ],
      ),
    );
  }

  /// 可复制的信息行（点击复制）
  Widget _buildCopiableRow(String label, String value) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已复制'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: MinimalTokens.gray700)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: MinimalTokens.primary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '点击复制',
                    style: TextStyle(
                      fontSize: 10,
                      color: MinimalTokens.gray300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
