/// Open IoT Platform - 统计卡片 Widget
/// 作者: 罗耀生
/// 版本: 1.0.0
///
/// 带渐变背景的统计卡片，用于显示关键数据指标

import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

/// 统计数据项
class StatItem {
  /// 显示的数值
  final String value;

  /// 标签
  final String label;

  const StatItem({
    required this.value,
    required this.label,
  });
}

/// 统计卡片样式
enum StatsCardStyle {
  /// 蓝紫渐变 (默认)
  bluePurple,
  /// 橙红渐变
  orangeRed,
  /// 绿青渐变
  greenCyan,
  /// 纯蓝色
  solidBlue,
}

/// 统计卡片
class StatsCard extends StatelessWidget {
  /// 统计数据项列表
  final List<StatItem> stats;

  /// 卡片样式
  final StatsCardStyle style;

  /// 卡片内边距
  final EdgeInsets padding;

  /// 卡片圆角
  final BorderRadius? borderRadius;

  const StatsCard({
    super.key,
    required this.stats,
    this.style = StatsCardStyle.bluePurple,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
  });

  /// 获取渐变背景
  Gradient get _gradient {
    switch (style) {
      case StatsCardStyle.bluePurple:
        return const LinearGradient(
          begin: Alignment(-1, -0.5),
          end: Alignment(1, 0.5),
          colors: [MinimalTokens.primary, MinimalTokens.secondary],
        );
      case StatsCardStyle.orangeRed:
        return const LinearGradient(
          begin: Alignment(-1, -0.5),
          end: Alignment(1, 0.5),
          colors: [Color(0xFFFF9500), Color(0xFFFF3B30)],
        );
      case StatsCardStyle.greenCyan:
        return const LinearGradient(
          begin: Alignment(-1, -0.5),
          end: Alignment(1, 0.5),
          colors: [Color(0xFF34C759), Color(0xFF30B0C7)],
        );
      case StatsCardStyle.solidBlue:
        return const LinearGradient(
          begin: Alignment(-1, -0.5),
          end: Alignment(1, 0.5),
          colors: [MinimalTokens.primary, MinimalTokens.primary],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(MinimalTokens.radiusLg),
      ),
      child: Column(
        children: [
          // 统计项行
          Row(
            children: stats.map((stat) => _StatItemWidget(stat: stat)).toList(),
          ),
        ],
      ),
    );
  }
}

/// 单个统计项 Widget
class _StatItemWidget extends StatelessWidget {
  final StatItem stat;

  const _StatItemWidget({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签
          Text(
            stat.label,
            style: TextStyle(
              fontSize: MinimalTokens.fontSizeCaption,
              color: MinimalTokens.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          // 数值
          Text(
            stat.value,
            style: TextStyle(
              fontSize: MinimalTokens.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: MinimalTokens.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// 紧凑型统计卡片 (用于个人中心)
class CompactStatsCard extends StatelessWidget {
  /// 统计数据项列表
  final List<StatItem> stats;

  /// 卡片内边距
  final EdgeInsets padding;

  const CompactStatsCard({
    super.key,
    required this.stats,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: _CompactStatItem(stat: stat),
        );
      }).toList(),
    );
  }
}

/// 紧凑型统计项 (半透明白色背景)
class _CompactStatItem extends StatelessWidget {
  final StatItem stat;

  const _CompactStatItem({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: MinimalTokens.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(MinimalTokens.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: MinimalTokens.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: TextStyle(
              fontSize: MinimalTokens.fontSizeCaption,
              color: MinimalTokens.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}
