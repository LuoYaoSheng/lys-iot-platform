// Toggle 开关控制面板（三位置开关）
// 作者: 罗耀生
// 日期: 2025-12-19
// v0.2.0: 适用于controlMode=toggle的产品

import 'package:flutter/material.dart';
import 'control_panel_base.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '位置控制',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          '当前位置: ${_getPositionText(_currentPosition)}',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPositionButton('上', 'up', Icons.arrow_upward, Colors.blue),
            _buildPositionButton('中', 'middle', Icons.remove, Colors.orange),
            _buildPositionButton('下', 'down', Icons.arrow_downward, Colors.green),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPositionButton(String label, String position, IconData icon, Color color) {
    final isActive = _currentPosition == position;
    final isEnabled = widget.device.isOnline && !isControlling;

    return Column(
      children: [
        ElevatedButton(
          onPressed: isEnabled ? () => _togglePosition(position) : null,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: isEnabled ? color : Colors.grey,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? color : Colors.grey.shade700,
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
}
