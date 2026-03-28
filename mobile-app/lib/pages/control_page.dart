// 设备控制页面
// 作者: 罗耀生
// 日期: 2025-12-13
// 更新: 2025-12-16 - 支持 toggle 和 pulse 两种模式

import 'package:flutter/material.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ControlPage extends StatefulWidget {
  final Device device;

  const ControlPage({super.key, required this.device});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  final ApiService _apiService = ApiService();
  bool _isControlling = false;
  String _currentPosition = 'middle';
  String _controlMode = 'toggle'; // toggle 或 pulse
  int _pulseDuration = 500; // pulse 模式的延迟时间（ms）

  @override
  void initState() {
    super.initState();
    _loadAuthAndStatus();
  }

  Future<void> _loadAuthAndStatus() async {
    // 加载认证信息和配置
    final prefs = await SharedPreferences.getInstance();

    // 加载自定义 API 地址（如果有）
    final customApiUrl = prefs.getString('custom_api_url');
    if (customApiUrl != null && customApiUrl.isNotEmpty) {
      _apiService.setBaseUrl(customApiUrl);
    }

    // 优先使用 Bearer Token
    final token = prefs.getString('iot_token');
    if (token != null && token.isNotEmpty) {
      _apiService.setBearerToken(token);
    } else {
      // 降级使用 API Key
      final apiKey = prefs.getString('api_key');
      final apiSecret = prefs.getString('api_secret');
      if (apiKey != null && apiSecret != null) {
        _apiService.setAPIKey(apiKey, apiSecret);
      }
    }

    // 加载设备状态
    await _loadDeviceStatus();
  }

  Future<void> _loadDeviceStatus() async {
    final response = await _apiService.getDeviceStatus(widget.device.deviceId);
    if (!mounted) return;
    if (response.isSuccess && response.data != null) {
      setState(() {
        _currentPosition = response.data!['position'] ?? 'middle';
      });
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  String get _statusText {
    switch (widget.device.status) {
      case DeviceStatus.online: return '在线';
      case DeviceStatus.offline: return '离线';
      case DeviceStatus.disabled: return '已禁用';
      case DeviceStatus.inactive: return '未激活';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name?.isNotEmpty == true ? widget.device.name! : '智能开关'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildModeSelector(),
            const SizedBox(height: 24),
            if (_controlMode == 'toggle') _buildToggleControl() else _buildPulseControl(),
            const SizedBox(height: 24),
            _buildDeviceInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final isOnline = widget.device.isOnline;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.power_settings_new, size: 48, color: isOnline ? Colors.green : Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(_statusText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: isOnline ? Colors.green : Colors.grey)),
            if (_controlMode == 'toggle') ...[
              const SizedBox(height: 8),
              Text('当前位置: ${_getPositionText(_currentPosition)}', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('控制模式', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'toggle',
                  label: Text('Toggle 模式'),
                  icon: Icon(Icons.toggle_on),
                ),
                ButtonSegment<String>(
                  value: 'pulse',
                  label: Text('Pulse 模式'),
                  icon: Icon(Icons.touch_app),
                ),
              ],
              selected: {_controlMode},
              onSelectionChanged: (selection) {
                setState(() {
                  _controlMode = selection.first;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              _controlMode == 'toggle' ? '开关灯场景' : '开电脑场景',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleControl() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('位置控制', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPositionButton('上', 'up', Icons.arrow_upward, Colors.blue),
                _buildPositionButton('中', 'middle', Icons.remove, Colors.orange),
                _buildPositionButton('下', 'down', Icons.arrow_downward, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseControl() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('脉冲控制', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('延迟时间:'),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _pulseDuration.toDouble(),
                    min: 100,
                    max: 2000,
                    divisions: 19,
                    label: '${_pulseDuration}ms',
                    onChanged: (value) { setState(() { _pulseDuration = value.toInt(); }); },
                  ),
                ),
                Text('${_pulseDuration}ms'),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: widget.device.isOnline && !_isControlling ? _triggerPulse : null,
                icon: const Icon(Icons.touch_app),
                label: const Text('触发'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: widget.device.isOnline && !_isControlling ? Colors.purple : Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionButton(String label, String position, IconData icon, Color color) {
    final isActive = _currentPosition == position;
    return Column(
      children: [
        ElevatedButton(
          onPressed: widget.device.isOnline && !_isControlling ? () => _togglePosition(position) : null,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: widget.device.isOnline && !_isControlling ? color : Colors.grey,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildDeviceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('设备信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Divider(),
            _buildInfoRow('设备ID', widget.device.deviceId),
            _buildInfoRow('设备SN', widget.device.deviceSN),
            _buildInfoRow('产品类型', widget.device.productKey),
            if (widget.device.createdAt != null) _buildInfoRow('创建时间', widget.device.createdAt.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  String _getPositionText(String position) {
    switch (position) {
      case 'up': return '上';
      case 'down': return '下';
      case 'middle': return '中';
      default: return '中';
    }
  }

  Future<void> _togglePosition(String position) async {
    setState(() { _isControlling = true; });
    final response = await _apiService.controlDevice(
      widget.device.deviceId,
      action: 'toggle',
      position: position,
    );
    setState(() { _isControlling = false; });
    if (response.isSuccess) {
      setState(() { _currentPosition = position; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已切换到${_getPositionText(position)}位置'), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('控制失败: ${response.message}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _triggerPulse() async {
    setState(() { _isControlling = true; });
    final response = await _apiService.controlDevice(
      widget.device.deviceId,
      action: 'pulse',
      duration: _pulseDuration,
    );
    setState(() { _isControlling = false; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.isSuccess ? '脉冲已触发' : '触发失败: ${response.message}'),
          backgroundColor: response.isSuccess ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
