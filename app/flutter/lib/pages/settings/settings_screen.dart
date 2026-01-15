/// 设置页
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import '../../widgets/app_icon.dart';
import '../../theme/app_tokens.dart';
import '../../core/app_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _serverUrl = 'http://192.168.1.100:48080';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3A3A3C),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 用户信息
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Center(child: Text('U', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white))),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('用户', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text('user@example.com', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 服务器配置
          const Text('服务器配置', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: const Text('API 服务器'),
              subtitle: Text(_serverUrl, style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
              trailing: const AppIcon(AppIcons.chevronRight, size: 20, color: Color(0xFFC7C7CC)),
              onTap: _showServerSettings,
            ),
          ),
          const SizedBox(height: 24),

          // 其他
          const Text('其他', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: const Text('关于'),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('v1.0.0', style: TextStyle(color: Color(0xFF8E8E93))),
                  SizedBox(width: 4),
                  AppIcon(AppIcons.chevronRight, size: 20, color: Color(0xFFC7C7CC)),
                ],
              ),
              onTap: () => AppRouter.goToAbout(context),
            ),
          ),
          const SizedBox(height: 32),

          // 退出登录
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('退出登录', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showServerSettings() {
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
                  onPressed: () {
                    setState(() => _serverUrl = controller.text);
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

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppRouter.goToLogin(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
