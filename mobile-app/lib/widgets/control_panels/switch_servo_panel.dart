/// 混合控制面板（位置控制 + 脉冲触发）
/// 作者: 罗耀生
/// 日期: 2026-01-06
/// 适用于舵机开关设备，同时支持位置控制和脉冲触发

import 'package:flutter/material.dart';
import 'control_panel_base.dart';

class SwitchServoPanel extends ControlPanelBase {
  const SwitchServoPanel({
    super.key,
    required super.device,
    required super.apiService,
  });

  @override
  State<SwitchServoPanel> createState() => _SwitchServoPanelState();
}

class _SwitchServoPanelState extends ControlPanelState<SwitchServoPanel> {
  String _currentPosition = 'middle';
  int _pulseDuration = 500; // 默认500ms

  @override
  void initState() {
    super.initState();
    _loadDeviceStatus();
  }

  Future<void> _loadDeviceStatus() async {
    final response = await widget.apiService.getDeviceStatus(widget.device.deviceId);
    if (response.isSuccess && response.data != null) {
      setState(() {
        _currentPosition = response.data!['position'] ?? 'middle';
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
        // 位置控制区域
        _buildPositionControlSection(isEnabled),
        const SizedBox(height: 32),
        // 脉冲触发区域
        _buildPulseTriggerSection(isEnabled),
        const SizedBox(height: 16),
      ],
    );
  }

  /// 位置控制区域
  Widget _buildPositionControlSection(bool isEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.control_camera, color: Colors.blue.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              '位置控制',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '当前位置: ${_getPositionText(_currentPosition)}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPositionButton('上', 'up', Icons.arrow_upward, Colors.blue, isEnabled),
            _buildPositionButton('中', 'middle', Icons.remove, Colors.orange, isEnabled),
            _buildPositionButton('下', 'down', Icons.arrow_downward, Colors.green, isEnabled),
          ],
        ),
      ],
    );
  }

  /// 脉冲触发区域
  Widget _buildPulseTriggerSection(bool isEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.touch_app, color: Colors.purple.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              '脉冲触发',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '适用于开机、触发等场景',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
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
              width: 60,
              child: Text(
                '${_pulseDuration}ms',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: isEnabled ? _triggerPulse : null,
            icon: const Icon(Icons.bolt, size: 20),
            label: const Text('触发'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: isEnabled ? Colors.purple : Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionButton(String label, String position, IconData icon, Color color, bool isEnabled) {
    final isActive = _currentPosition == position;

    return Column(
      children: [
        ElevatedButton(
          onPressed: isEnabled ? () => _togglePosition(position) : null,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: isEnabled ? color : Colors.grey,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? color : Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
      ],
    );
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
      });
      showSuccess('已切换到${_getPositionText(position)}位置');
    } else {
      showError('控制失败: ${response.message}');
    }
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
