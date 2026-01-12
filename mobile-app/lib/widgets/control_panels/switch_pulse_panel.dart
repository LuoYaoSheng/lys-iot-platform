/// Pulse 脉冲控制面板（触发式开关）
/// 作者: 罗耀生
/// 版本: 3.1.0
/// 适用于controlMode=pulse的产品
/// v3.1.0: 添加底部状态显示和设备信息卡片

import 'package:flutter/material.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import 'control_panel_base.dart';
import '../../design_system/design_system.dart';

class SwitchPulsePanel extends ControlPanelBase {
  const SwitchPulsePanel({
    super.key,
    required super.device,
    required super.apiService,
  });

  @override
  State<SwitchPulsePanel> createState() => _SwitchPulsePanelState();
}

class _SwitchPulsePanelState extends ControlPanelState<SwitchPulsePanel> {
  int _pulseDuration = 500;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _lastUpdateTime = DateTime.now();
  }
  Widget build(BuildContext context) {
    final isEnabled = widget.device.isOnline && !isControlling;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '脉冲控制',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MinimalTokens.gray900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '适用于开机、触发等场景',
          style: TextStyle(
            fontSize: 14,
            color: MinimalTokens.gray700,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text('延迟时间:', style: TextStyle(fontSize: 14, color: MinimalTokens.gray700)),
            const SizedBox(width: 16),
            Expanded(
              child: Slider(
                value: _pulseDuration.toDouble(),
                min: 100,
                max: 2000,
                divisions: 19,
                activeColor: MinimalTokens.primary,
                label: '${_pulseDuration}ms',
                onChanged: (value) {
                  setState(() {
                    _pulseDuration = value.toInt();
                  });
                },
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                '${_pulseDuration}ms',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: MinimalTokens.gray700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: isEnabled ? _triggerPulse : null,
            icon: const Icon(Icons.touch_app, size: 24),
            label: const Text('触发', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              foregroundColor: MinimalTokens.white,
              backgroundColor: isEnabled ? MinimalTokens.secondary : MinimalTokens.gray300,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildStatusSection(),
        const SizedBox(height: 16),
        _buildDeviceInfoCard(),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.device.isOnline ? MinimalTokens.success : MinimalTokens.error,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.device.isOnline ? '在线' : '离线',
            style: TextStyle(
              fontSize: 12,
              color: MinimalTokens.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '最后更新: \${_getLastUpdateText()}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDeviceInfoCard() {
    final deviceName = _getDeviceDisplayName();
    final productName = _getProductName();
    final firmwareVersion = '1.0.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              Text(value, style: TextStyle(fontSize: 14, color: Colors.grey.shade800)),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: Colors.grey.shade200),
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
    if (diff.inSeconds < 60) return '\${diff.inSeconds}秒前';
    if (diff.inMinutes < 60) return '\${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '\${diff.inHours}小时前';
    return '\${diff.inDays}天前';
  }

  Future<void> _triggerPulse() async {
    setControlling(true);
    final response = await widget.apiService.controlDevice(
      widget.device.deviceId,
      action: 'pulse',
      duration: _pulseDuration,
    );
    setControlling(false);

    if (response.isSuccess) {
      setState(() {
        _lastUpdateTime = DateTime.now();
      });
      showSuccess('脉冲已触发');
    } else {
      showError('触发失败: ${response.message}');
    }
  }
}
