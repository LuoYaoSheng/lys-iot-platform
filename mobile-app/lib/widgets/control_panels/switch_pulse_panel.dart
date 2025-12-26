/// Pulse 脉冲控制面板（触发式开关）
/// 作者: 罗耀生
/// 日期: 2025-12-19
/// v0.2.0: 适用于controlMode=pulse的产品

import 'package:flutter/material.dart';
import 'control_panel_base.dart';

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
  int _pulseDuration = 500; // 默认500ms

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.device.isOnline && !isControlling;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '脉冲控制',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          '适用于开机、触发等场景',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text('延迟时间:', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 16),
            Expanded(
              child: Slider(
                value: _pulseDuration.toDouble(),
                min: 100,
                max: 2000,
                divisions: 19,
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
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
              foregroundColor: Colors.white,
              backgroundColor: isEnabled ? Colors.purple : Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
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
      showSuccess('脉冲已触发');
    } else {
      showError('触发失败: ${response.message}');
    }
  }
}
