/// 个人中心页
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_icon.dart';
import '../../theme/app_tokens.dart';
import '../../core/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/device_provider.dart';

class ProfileScreen extends StatelessWidget {
  final bool isNested;

  const ProfileScreen({super.key, this.isNested = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [
          // 渐变头部
          Consumer2<AuthProvider, DeviceProvider>(
            builder: (context, auth, deviceProvider, child) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // 头像
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Center(
                            child: Text(
                              auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          auth.displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.user?.email ?? 'user@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 统计
                        Row(
                          children: [
                            _buildStatItem('${deviceProvider.total}', '设备总数'),
                            const SizedBox(width: 12),
                            _buildStatItem('${deviceProvider.onlineCount}', '在线设备', isGreen: true),
                            const SizedBox(width: 12),
                            _buildStatItem('1.0', '版本'),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // 菜单列表
          Expanded(
            child: Consumer<DeviceProvider>(
              builder: (context, deviceProvider, child) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 设备管理
                    _buildMenuCard(
                      context,
                      items: [
                        _MenuItem(
                          iconName: AppIcons.device,
                          title: '设备管理',
                          trailing: '${deviceProvider.total} 台',
                          onTap: () => AppRouter.goToDeviceList(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 设置
                    _buildMenuCard(
                      context,
                      items: [
                        _MenuItem(
                          iconName: AppIcons.settings,
                          title: '设置',
                          onTap: () => AppRouter.goToSettings(context),
                        ),
                        _MenuItem(
                          iconName: AppIcons.info,
                          title: '关于',
                          trailing: 'v1.0.0',
                          onTap: () => AppRouter.goToAbout(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 退出登录
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _logout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('退出登录', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {bool isGreen = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isGreen ? const Color(0xFF34C759) : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required List<_MenuItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: AppIcon(item.iconName, size: 24, color: const Color(0xFF3A3A3C)),
                title: Text(item.title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.trailing != null)
                      Text(
                        item.trailing!,
                        style: const TextStyle(color: Color(0xFF8E8E93)),
                      ),
                    const SizedBox(width: 4),
                    const AppIcon(AppIcons.chevronRight, size: 20, color: Color(0xFFC7C7CC)),
                  ],
                ),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final auth = context.read<AuthProvider>();
              auth.logout();
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

class _MenuItem {
  final String iconName;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  _MenuItem({
    required this.iconName,
    required this.title,
    this.trailing,
    this.onTap,
  });
}
