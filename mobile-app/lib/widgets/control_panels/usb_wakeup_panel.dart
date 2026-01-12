/// USB唤醒设备控制面板
/// 作者: 罗耀生
/// 版本: 3.0.0
/// 遵循 design-system/docs/components.md UsbWakeupPanel 规范
///
/// 规格:
/// - 唤醒按钮: 160x160pt
/// - 圆角: radiusXl (16pt)
/// - 图标: 48pt
/// - 按下效果: 缩放 0.95

import 'package:flutter/material.dart';
import 'control_panel_base.dart';
import '../../design_system/design_system.dart';

class UsbWakeupPanel extends ControlPanelBase {
  const UsbWakeupPanel({
    super.key,
    required super.device,
    required super.apiService,
  });

  @override
  State<UsbWakeupPanel> createState() => _UsbWakeupPanelState();
}

class _UsbWakeupPanelState extends ControlPanelState<UsbWakeupPanel> {
  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.device.isOnline && !isControlling;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MinimalSpacer(size: MinimalSpacing.xl),

        // 大圆按钮 (160x160pt)
        GestureDetector(
          onTapDown: isEnabled ? (_) => _onTapDown() : null,
          onTapUp: isEnabled ? (_) => _onTapUp() : null,
          onTapCancel: _onTapCancel,
          onTap: isEnabled ? _triggerWakeup : null,
          child: _WakeupButton(
            isEnabled: isEnabled,
            isControlling: isControlling,
          ),
        ),

        const MinimalSpacer(size: MinimalSpacing.lg),

        // 说明文字
        Text(
          '点击按钮唤醒电脑',
          style: TextStyle(
            fontSize: MinimalTokens.fontSizeBody,
            color: MinimalTokens.gray700,
          ),
        ),

        const MinimalSpacer(size: MinimalSpacing.xl),

        // 设备信息卡片
        _buildDeviceInfoCard(),
      ],
    );
  }

  /// 设备信息卡片
  Widget _buildDeviceInfoCard() {
    return Container(
      padding: MinimalEdgeInsets.md,
      decoration: BoxDecoration(
        color: MinimalTokens.white,
        borderRadius: MinimalBorderRadius.lg,
        border: Border.all(color: MinimalTokens.gray100),
      ),
      child: Column(
        children: [
          _buildInfoRow('设备名称', widget.device.name ?? 'USB唤醒设备'),
          const Divider(height: 1, color: MinimalTokens.gray100),
          _buildInfoRow('设备 ID', widget.device.deviceId),
          const Divider(height: 1, color: MinimalTokens.gray100),
          _buildInfoRow('产品类型', widget.device.product?.name ?? 'USB Wakeup'),
          const Divider(height: 1, color: MinimalTokens.gray100),
          _buildInfoRow('固件版本', '1.0.0'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MinimalSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: MinimalTokens.fontSizeBodySmall,
              color: MinimalTokens.gray500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: MinimalTokens.fontSizeBodySmall,
              color: MinimalTokens.gray700,
            ),
          ),
        ],
      ),
    );
  }

  void _onTapDown() {
    setState(() {}); // 触发重建以显示按下状态
  }

  void _onTapUp() {
    setState(() {});
  }

  void _onTapCancel() {
    setState(() {});
  }

  Future<void> _triggerWakeup() async {
    setControlling(true);
    final response = await widget.apiService.controlDevice(
      widget.device.deviceId,
      action: 'trigger',
    );
    setControlling(false);

    if (response.isSuccess) {
      showSuccess('唤醒信号已发送');
    } else {
      showError('发送失败: ${response.message}');
    }
  }
}

/// ========== 唤醒按钮组件 ==========
/// 规格: 160x160pt
class _WakeupButton extends StatelessWidget {
  final bool isEnabled;
  final bool isControlling;

  const _WakeupButton({
    required this.isEnabled,
    required this.isControlling,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: isEnabled ? MinimalTokens.primary : MinimalTokens.gray200,
        borderRadius: MinimalBorderRadius.xl,
        // 禁用时无阴影
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: MinimalTokens.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标 48pt
          Icon(
            isControlling ? Icons.hourglass_empty : Icons.bolt,
            size: 48,
            color: isEnabled ? MinimalTokens.white : MinimalTokens.gray300,
          ),
          const MinimalSpacer(size: MinimalSpacing.sm),
          // 文字
          Text(
            isControlling ? '发送中...' : '唤醒',
            style: TextStyle(
              fontSize: MinimalTokens.fontSizeTitle,
              fontWeight: MinimalTokens.fontWeightSemiBold,
              color: isEnabled ? MinimalTokens.white : MinimalTokens.gray300,
            ),
          ),
        ],
      ),
    );
  }
}
