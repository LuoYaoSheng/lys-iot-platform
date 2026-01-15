/// 位置显示器组件
/// 作者: 罗耀生
/// 日期: 2026-01-14
/// 用途: 舵机位置可视化显示，带轨道和滑动指示器

import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// 舵机位置枚举
enum ServoPosition {
  up('up', '上'),
  middle('middle', '中'),
  down('down', '下');

  final String value;
  final String label;

  const ServoPosition(this.value, this.label);

  static ServoPosition fromValue(String value) {
    return ServoPosition.values.firstWhere(
      (p) => p.value == value,
      orElse: () => ServoPosition.middle,
    );
  }
}

class AppPositionDisplay extends StatelessWidget {
  final ServoPosition position;

  const AppPositionDisplay({
    super.key,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusLG,
      ),
      child: Stack(
        children: [
          // 轨道
          Positioned(
            left: 30,
            right: 30,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // 指示器
          _buildIndicator(),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    switch (position) {
      case ServoPosition.up:
        return Positioned(
          left: 10,
          top: 0,
          bottom: 0,
          child: _IndicatorDot(),
        );
      case ServoPosition.down:
        return Positioned(
          right: 10,
          top: 0,
          bottom: 0,
          child: _IndicatorDot(),
        );
      case ServoPosition.middle:
        return Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(child: _IndicatorDot()),
        );
    }
  }
}

class _IndicatorDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
