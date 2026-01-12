/// Toggle 开关控制面板（三位置开关）
/// 作者: 罗耀生
/// 版本: 4.0.0
/// 适用于controlMode=toggle的产品
/// 完全遵循 design-system/prototype/pages/device-control-servo.html 设计

import 'package:flutter/material.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import 'control_panel_base.dart';
import '../../design_system/design_system.dart';

class SwitchTogglePanel extends ControlPanelBase {
  const SwitchTogglePanel({
    super.key,
    required super.device,
    required super.apiService,
  });

  @override
  State<SwitchTogglePanel> createState() => _SwitchTogglePanelState();
}

class _SwitchTogglePanelState extends ControlPanelState<SwitchTogglePanel> {
  String _currentPosition = 'middle';
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _loadDeviceStatus();
    _lastUpdateTime = DateTime.now();
  }

  Future<void> _loadDeviceStatus() async {
    final response = await widget.apiService.getDeviceStatus(widget.device.deviceId);
    if (response.isSuccess && response.data != null) {
      setState(() {
        _currentPosition = response.data!['position'] ?? 'middle';
        _lastUpdateTime = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.device.isOnline && !isControlling;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 位置标签
        Text(
          '当前位置: ${_getPositionText(_currentPosition)}',
          style: TextStyle(
            fontSize: MinimalTokens.fontSizeBody,
            color: MinimalTokens.gray700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // 位置显示区域
        _buildPositionDisplay(),
        const SizedBox(height: 20),

        // 位置按钮
        _buildPositionButtons(isEnabled),
        const SizedBox(height: 24),

        // 底部状态显示
        _buildStatusSection(),
        const SizedBox(height: 24),

        // 设备信息卡片
        _buildDeviceInfoCard(),
      ],
    );
  }

  /// 位置显示区域 - 原型设计的 track + indicator
  Widget _buildPositionDisplay() {
    return SizedBox(
      width: 120,
      height: 100,
      child: Stack(
        children: [
          // Track
          Positioned(
            left: 40,
            top: 0,
            bottom: 0,
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                color: MinimalTokens.gray100,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Indicator
          AnimatedPositioned(
            left: 48,
            top: _getIndicatorTop(),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: MinimalTokens.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getIndicatorTop() {
    switch (_currentPosition) {
      case 'up':
        return 8;
      case 'down':
        return 56;
      default:
        return 32;
    }
  }

  /// 位置按钮 - 完全匹配原型设计
  Widget _buildPositionButtons(bool isEnabled) {
    return Row(
      children: [
        Expanded(
          child: _PositionButton(
            label: '上',
            position: 'up',
            isActive: _currentPosition == 'up',
            isEnabled: isEnabled,
            onTap: () => _togglePosition('up'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PositionButton(
            label: '中',
            position: 'middle',
            isActive: _currentPosition == 'middle',
            isEnabled: isEnabled,
            onTap: () => _togglePosition('middle'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PositionButton(
            label: '下',
            position: 'down',
            isActive: _currentPosition == 'down',
            isEnabled: isEnabled,
            onTap: () => _togglePosition('down'),
          ),
        ),
      ],
    );
  }

  /// 底部状态显示
  Widget _buildStatusSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: widget.device.isOnline
                ? const Color(0xFF34C759).withOpacity(0.1)
                : const Color(0xFFFF3B30).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.device.isOnline ? '在线' : '离线',
            style: TextStyle(
              fontSize: MinimalTokens.fontSizeCaption,
              color: widget.device.isOnline ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '最后更新: ${_getLastUpdateText()}',
          style: TextStyle(
            fontSize: MinimalTokens.fontSizeCaption,
            color: MinimalTokens.gray500,
          ),
        ),
      ],
    );
  }

  /// 设备信息卡片
  Widget _buildDeviceInfoCard() {
    final deviceName = _getDeviceDisplayName();
    final productName = _getProductName();
    final firmwareVersion = '1.0.0';

    return Container(
      decoration: BoxDecoration(
        color: MinimalTokens.white,
        borderRadius: MinimalBorderRadius.lg,
      ),
      child: Column(
        children: [
          _buildInfoRow('设备名称', deviceName, true),
          _buildInfoRow('设备 ID', widget.device.deviceId, true),
          _buildInfoRow('产品类型', productName, true),
          _buildInfoRow('固件版本', firmwareVersion, false),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool showDivider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: MinimalTokens.gray100,
          ),
      ],
    );
  }

  String _getDeviceDisplayName() {
    if (widget.device.name != null && widget.device.name!.isNotEmpty) {
      return widget.device.name!;
    }
    if (widget.device.product?.name != null) {
      return widget.device.product!.name;
    }
    return '智能设备';
  }

  String _getProductName() {
    if (widget.device.product?.name != null) {
      return widget.device.product!.name;
    }
    return '未知设备';
  }

  String _getLastUpdateText() {
    if (_lastUpdateTime == null) return '刚刚';
    final now = DateTime.now();
    final diff = now.difference(_lastUpdateTime!);
    if (diff.inSeconds < 60) return '${diff.inSeconds}秒前';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }

  String _getPositionText(String position) {
    switch (position) {
      case 'up':
        return '上';
      case 'down':
        return '下';
      case 'middle':
        return '中';
      default:
        return '中';
    }
  }

  Future<void> _togglePosition(String position) async {
    setControlling(true);
    final response = await widget.apiService.controlDevice(
      widget.device.deviceId,
      action: 'toggle',
      position: position,
    );
    setControlling(false);

    if (response.isSuccess) {
      setState(() {
        _currentPosition = position;
        _lastUpdateTime = DateTime.now();
      });
      showSuccess('已切换到${_getPositionText(position)}位置');
    } else {
      showError('控制失败: ${response.message}');
    }
  }
}

/// 位置按钮 - 匹配原型设计
class _PositionButton extends StatefulWidget {
  final String label;
  final String position;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback onTap;

  const _PositionButton({
    required this.label,
    required this.position,
    required this.isActive,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  State<_PositionButton> createState() => _PositionButtonState();
}

class _PositionButtonState extends State<_PositionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: widget.isEnabled
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 48,
        decoration: BoxDecoration(
          color: widget.isActive
              ? MinimalTokens.primary
              : _isPressed
                  ? MinimalTokens.gray50
                  : MinimalTokens.white,
          border: Border.all(
            color: widget.isActive ? MinimalTokens.primary : MinimalTokens.gray200,
            width: 1,
          ),
          borderRadius: MinimalBorderRadius.md,
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: MinimalTokens.fontSizeBody,
              color: widget.isActive ? MinimalTokens.white : MinimalTokens.gray700,
            ),
          ),
        ),
      ),
    );
  }
}
