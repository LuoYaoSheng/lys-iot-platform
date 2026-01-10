/// USB唤醒设备控制面板
/// 作者: 罗耀生
/// 日期: 2026-01-09
/// 适用于 uiTemplate=wakeup 或 controlMode=trigger 的产品

import 'package:flutter/material.dart';
import 'control_panel_base.dart';

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'USB唤醒控制',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          '通过USB HID信号唤醒电脑',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        // 触发按钮
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: ElevatedButton(
              onPressed: isEnabled ? _triggerWakeup : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: isEnabled ? const Color(0xFF6C63FF) : Colors.grey,
                shape: const CircleBorder(),
                elevation: isEnabled ? 8 : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isControlling ? Icons.hourglass_empty : Icons.keyboard,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isControlling ? '发送中...' : '点击唤醒',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 设备信息
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '使用说明',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '确保设备已插入电脑USB端口，点击按钮将发送唤醒信号',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
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
