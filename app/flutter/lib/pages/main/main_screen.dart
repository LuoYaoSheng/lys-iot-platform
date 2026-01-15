/// 主页（TabBar导航）
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import '../../widgets/app_icon.dart';
import '../../theme/app_tokens.dart';
import '../device/device_list_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DeviceListScreen(isNested: true),
    ProfileScreen(isNested: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF8E8E93),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: AppIcon(AppIcons.device, size: 24, color: Color(0xFF8E8E93)),
            activeIcon: AppIcon(AppIcons.device, size: 24, color: AppColors.primary),
            label: '设备',
          ),
          BottomNavigationBarItem(
            icon: AppIcon(AppIcons.person, size: 24, color: Color(0xFF8E8E93)),
            activeIcon: AppIcon(AppIcons.person, size: 24, color: AppColors.primary),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
