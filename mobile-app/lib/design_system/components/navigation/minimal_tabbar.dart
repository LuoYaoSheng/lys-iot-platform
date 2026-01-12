/// Navigation Components - 导航组件
/// 作者: 罗耀生
/// 版本: 3.0.0
///
/// 包含：TabBar 底部导航栏
/// 遵循 design-system/prototype/pages/mobile-styles.css 规范
///
/// 规格:
/// - 高度: 60pt
/// - 背景: 白色
/// - 顶部边框: 1px solid gray100
/// - 图标大小: 24pt
/// - 标签字号: 10pt

library;

import 'package:flutter/material.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';

/// ========== TabBar 底部导航栏 ==========
/// 遵循原型 tab-device.html TabBar 规范
class MinimalTabBar extends StatelessWidget {
  const MinimalTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
  });

  /// Tab 列表
  final List<MinimalTabItem> tabs;

  /// 当前选中索引
  final int currentIndex;

  /// Tab 点击回调
  final ValueChanged<int>? onTap;

  /// 背景色（默认白色）
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor ?? MinimalTokens.white,
        border: Border(
          top: BorderSide(color: MinimalTokens.gray100, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == currentIndex;

          return Expanded(
            child: _TabBarItem(
              icon: tab.icon,
              label: tab.label,
              isSelected: isSelected,
              onTap: () => onTap?.call(index),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// ========== Tab 项数据 ==========
class MinimalTabItem {
  const MinimalTabItem({
    required this.icon,
    required this.label,
  });

  /// 图标
  final IconData icon;

  /// 标签文字
  final String label;
}

/// ========== Tab 项组件 ==========
class _TabBarItem extends StatelessWidget {
  const _TabBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标 24pt
          Icon(
            icon,
            size: 24,
            color: isSelected
                ? MinimalTokens.primary
                : MinimalTokens.gray300,
          ),
          const SizedBox(height: 4),
          // 标签 10pt
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? MinimalTokens.primary
                  : MinimalTokens.gray300,
              fontWeight: isSelected
                  ? MinimalTokens.fontWeightMedium
                  : MinimalTokens.fontWeightRegular,
            ),
          ),
        ],
      ),
    );
  }
}
