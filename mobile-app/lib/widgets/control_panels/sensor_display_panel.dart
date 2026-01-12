/// 传感器显示面板（只读模式）
/// 作者: 罗耀生
/// 日期: 2025-12-19
/// v0.2.0: 适用于controlMode=readonly的产品（传感器、仪表等）

import 'package:flutter/material.dart';
import 'control_panel_base.dart';
import '../../design_system/design_system.dart';

class SensorDisplayPanel extends ControlPanelBase {
  const SensorDisplayPanel({
    super.key,
    required super.device,
    required super.apiService,
  });

  @override
  State<SensorDisplayPanel> createState() => _SensorDisplayPanelState();
}

class _SensorDisplayPanelState extends ControlPanelState<SensorDisplayPanel> {
  Map<String, dynamic>? _sensorData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSensorData();
  }

  Future<void> _loadSensorData() async {
    setState(() {
      _isLoading = true;
    });

    final response = await widget.apiService.getDeviceStatus(widget.device.deviceId);

    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data != null) {
        _sensorData = response.data;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '传感器数据',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MinimalTokens.gray900,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadSensorData,
              color: MinimalTokens.gray700,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_sensorData == null || _sensorData!.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                '暂无数据',
                style: TextStyle(
                  color: MinimalTokens.gray700,
                ),
              ),
            ),
          )
        else
          _buildDataDisplay(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDataDisplay() {
    final entries = _sensorData!.entries.toList();

    return Column(
      children: entries.map((entry) {
        if (entry.key == 'deviceId' ||
            entry.key == 'deviceName' ||
            entry.key == 'online') {
          return const SizedBox.shrink(); // 跳过元数据字段
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MinimalTokens.gray100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatLabel(entry.key),
                style: TextStyle(
                  fontSize: 14,
                  color: MinimalTokens.gray700,
                ),
              ),
              Text(
                _formatValue(entry.value),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MinimalTokens.gray900,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatLabel(String key) {
    switch (key) {
      case 'temperature':
        return '温度';
      case 'humidity':
        return '湿度';
      case 'pressure':
        return '气压';
      case 'position':
        return '位置';
      case 'status':
        return '状态';
      default:
        return key;
    }
  }

  String _formatValue(dynamic value) {
    if (value is num) {
      return value.toString();
    } else if (value is String) {
      return value;
    } else {
      return value.toString();
    }
  }
}
