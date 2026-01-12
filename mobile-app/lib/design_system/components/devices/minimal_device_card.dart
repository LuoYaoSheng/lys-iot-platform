/// Minimal Device Components - 设备相关组件
/// 作者: 罗耀生
/// 版本: 3.0.0
///
/// 包含：
/// - DeviceCard: 设备卡片
/// - DeviceStatsCard: 设备统计卡片
/// - DeviceControlSheet: 设备控制面板底部弹窗

library;

import 'package:flutter/material.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';
import '../layout/minimal_layout.dart';

/// ========== 设备卡片 ==========
/// 遵循 design-system/docs/components.md DeviceCard 规范
/// 规格:
/// - 高度: 约72pt
/// - 圆角: 12pt
/// - 阴影: 无 (elevation: 0)
/// - 边框: 1px solid gray100
/// - 内边距: 16pt
class MinimalDeviceCard extends StatelessWidget {
  const MinimalDeviceCard({
    super.key,
    required this.name,
    required this.isOnline,
    this.statusText,
    this.infoItems = const [],
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
  });

  /// 设备名称
  final String name;

  /// 是否在线
  final bool isOnline;

  /// 状态文本（默认根据在线状态显示）
  final String? statusText;

  /// 附加信息（如位置、固件版本等）
  final List<String> infoItems;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 背景色
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final displayStatus = statusText ?? (isOnline ? '在线' : '离线');
    final statusColor = _getStatusColor();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: MinimalSpacing.sm),
        decoration: BoxDecoration(
          color: backgroundColor ?? MinimalTokens.white,
          borderRadius: MinimalBorderRadius.lg,
          border: Border.all(color: MinimalTokens.gray100, width: 1),
        ),
        padding: const EdgeInsets.all(MinimalSpacing.md),
        child: Column(
          children: [
            // Header: 状态点 + 名称 + 状态文本 + 更多图标
            Row(
              children: [
                // 状态点 8pt
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: MinimalSpacing.sm),
                // 设备名称 16pt Medium gray700
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: MinimalTokens.fontSizeBody,
                      color: MinimalTokens.gray700,
                      fontWeight: MinimalTokens.fontWeightMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 状态文本 14pt Regular
                Text(
                  displayStatus,
                  style: TextStyle(
                    fontSize: MinimalTokens.fontSizeBodySmall,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: MinimalSpacing.sm),
                // 更多图标
                Icon(
                  Icons.more_horiz,
                  size: 20,
                  color: MinimalTokens.gray300,
                ),
              ],
            ),
            const MinimalSpacer(size: MinimalSpacing.sm),
            // Footer: 附加信息 12pt Regular gray500
            if (infoItems.isNotEmpty)
              Row(
                children: [
                  for (int i = 0; i < infoItems.length; i++) ...[
                    Text(
                      infoItems[i],
                      style: TextStyle(
                        fontSize: MinimalTokens.fontSizeCaption,
                        color: MinimalTokens.gray500,
                      ),
                    ),
                    if (i < infoItems.length - 1)
                      const SizedBox(width: MinimalSpacing.md),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (isOnline) return MinimalTokens.success;
    return MinimalTokens.error;
  }
}

/// ========== 设备统计卡片 ==========
/// 遵循原型 tab-device.html 中的统计卡片样式
/// 渐变背景 + 设备数量统计
class MinimalDeviceStatsCard extends StatelessWidget {
  const MinimalDeviceStatsCard({
    super.key,
    required this.totalDevices,
    required this.onlineDevices,
    this.gradientStart,
    this.gradientEnd,
  });

  /// 设备总数
  final int totalDevices;

  /// 在线设备数
  final int onlineDevices;

  /// 渐变起始色（默认 primary）
  final Color? gradientStart;

  /// 渐变结束色（默认 secondary）
  final Color? gradientEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: MinimalSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientStart ?? MinimalTokens.primary,
            gradientEnd ?? MinimalTokens.secondary,
          ],
        ),
        borderRadius: MinimalBorderRadius.lg,
      ),
      padding: const EdgeInsets.all(MinimalSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '我的设备',
                style: TextStyle(
                  fontSize: MinimalTokens.fontSizeCaption,
                  color: MinimalTokens.white.withOpacity(0.8),
                ),
              ),
              const MinimalSpacer(size: MinimalSpacing.xs),
              Text(
                '$totalDevices 台',
                style: TextStyle(
                  fontSize: MinimalTokens.fontSizeLarge,
                  fontWeight: MinimalTokens.fontWeightSemiBold,
                  color: MinimalTokens.white,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '在线',
                style: TextStyle(
                  fontSize: MinimalTokens.fontSizeCaption,
                  color: MinimalTokens.white.withOpacity(0.8),
                ),
              ),
              const MinimalSpacer(size: MinimalSpacing.xs),
              Text(
                '$onlineDevices 台',
                style: TextStyle(
                  fontSize: MinimalTokens.fontSizeTitle,
                  fontWeight: MinimalTokens.fontWeightSemiBold,
                  color: MinimalTokens.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ========== 设备列表底部提示 ==========
class MinimalDeviceListHint extends StatelessWidget {
  const MinimalDeviceListHint({
    super.key,
    this.hint,
  });

  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MinimalSpacing.md),
      child: Text(
        hint ?? '长按设备卡片可删除',
        style: TextStyle(
          fontSize: MinimalTokens.fontSizeCaption,
          color: MinimalTokens.gray500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// ========== 设备控制面板底部弹窗 ==========
/// 用于显示设备控制面板的底部弹窗
class MinimalDeviceControlSheet extends StatefulWidget {
  const MinimalDeviceControlSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isOnline,
    required this.child,
    this.onClose,
  });

  /// 面板标题（设备名称）
  final String title;

  /// 设备图标
  final IconData icon;

  /// 图标颜色
  final Color iconColor;

  /// 设备在线状态
  final bool isOnline;

  /// 控制面板内容
  final Widget child;

  /// 关闭回调
  final VoidCallback? onClose;

  @override
  State<MinimalDeviceControlSheet> createState() =>
      _MinimalDeviceControlSheetState();
}

class _MinimalDeviceControlSheetState extends State<MinimalDeviceControlSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: MinimalTokens.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 拖动指示器
              _buildDragHandle(),
              // 设备标题
              _buildHeader(),
              // 控制面板内容
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(MinimalSpacing.md),
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 12),
        decoration: BoxDecoration(
          color: MinimalTokens.gray200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MinimalSpacing.xl),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: 32),
          ),
          const SizedBox(width: MinimalSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: MinimalTokens.fontSizeTitle,
                    fontWeight: MinimalTokens.fontWeightSemiBold,
                    color: MinimalTokens.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.isOnline
                            ? MinimalTokens.success
                            : MinimalTokens.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isOnline ? '在线' : '离线',
                      style: TextStyle(
                        fontSize: MinimalTokens.fontSizeBodySmall,
                        color: widget.isOnline
                            ? MinimalTokens.success
                            : MinimalTokens.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              widget.onClose?.call();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
