// WiFi 配网页面
// 作者: 罗耀生
// 日期: 2025-12-13

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ble_service.dart';

class ConfigPage extends StatefulWidget {
  final BluetoothDevice device;

  const ConfigPage({super.key, required this.device});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final BleService _bleService = BleService();
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _apiUrlController = TextEditingController();

  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isSending = false;
  bool _passwordVisible = false;
  String? _error;
  String _status = 'READY';

  StreamSubscription? _statusSubscription;
  String? _configuredDeviceId;

  @override
  void initState() {
    super.initState();
    _loadCurrentWifi();
    _loadApiUrl();
    _connectDevice();
  }

  @override
  void dispose() {
    // 立即取消订阅，防止回调在 dispose 后触发
    _statusSubscription?.cancel();
    _statusSubscription = null;

    // 断开 BLE 连接
    _bleService.disconnect();

    // 释放文本控制器
    _ssidController.dispose();
    _passwordController.dispose();
    _apiUrlController.dispose();

    super.dispose();
  }

  Future<void> _loadCurrentWifi() async {
    try {
      final info = NetworkInfo();
      final ssid = await info.getWifiName();

      if (!mounted) return; // 检查 widget 是否已销毁

      if (ssid != null) {
        final cleanSsid = ssid.replaceAll('"', '');
        _ssidController.text = cleanSsid;
      }
    } catch (e) {
      debugPrint('Failed to get WiFi name: $e');
    }
  }

  Future<void> _loadApiUrl() async {
    try {
      // 从 SharedPreferences 读取用户配置的 API 地址
      final prefs = await SharedPreferences.getInstance();
      final customApiUrl = prefs.getString('custom_api_url');

      if (!mounted) return;

      // 使用用户配置的地址，如果没有则使用默认地址
      _apiUrlController.text = customApiUrl ?? IoTConfig.fromEnvironment().apiBaseUrl;
    } catch (e) {
      debugPrint('Failed to load API URL: $e');
      // 加载失败时使用默认值
      _apiUrlController.text = IoTConfig.fromEnvironment().apiBaseUrl;
    }
  }

  Future<void> _connectDevice() async {
    setState(() {
      _isConnecting = true;
      _error = null;
      _status = 'CONNECTING';
    });

    final success = await _bleService.connect(widget.device);

    if (!mounted) return; // 检查 widget 是否已销毁

    if (!success) {
      setState(() {
        _isConnecting = false;
        _error = 'CONNECT_FAILED';
      });
      return;
    }

    _statusSubscription = _bleService.statusStream.listen((notification) {
      if (!mounted) return; // 检查 widget 是否已销毁

      setState(() {
        switch (notification.status) {
          case 'received':
            _status = 'CONFIG_SENT';
            break;
          case 'connecting':
            _status = 'WIFI_CONNECTING';
            break;
          case 'wifi_connected':
            _status = 'WIFI_CONNECTED';
            break;
          case 'activated':
            _status = 'SUCCESS';
            _configuredDeviceId = notification.deviceId;
            break;
          case 'error':
            _error = notification.message ?? 'FAILED';
            _status = 'ERROR';
            break;
        }
      });

      // 在 setState 之后单独调用 showDialog，并再次检查 mounted
      if (notification.status == 'activated' && mounted) {
        _showSuccessDialog();
      }
    });

    if (!mounted) return; // 检查 widget 是否已销毁

    setState(() {
      _isConnecting = false;
      _isConnected = true;
      _status = 'CONNECTED';
    });
  }

  Future<void> _sendConfig() async {
    final ssid = _ssidController.text.trim();
    final password = _passwordController.text;
    final apiUrl = _apiUrlController.text.trim();

    if (ssid.isEmpty) {
      setState(() {
        _error = 'SSID_EMPTY';
      });
      return;
    }

    // API URL 已经从设置中加载，确保格式正确
    if (apiUrl.isNotEmpty) {
      final uri = Uri.tryParse(apiUrl);
      if (uri == null || !uri.isAbsolute) {
        setState(() {
          _error = 'INVALID_URL - Please check server settings in login page';
        });
        return;
      }
    }

    setState(() {
      _isSending = true;
      _error = null;
      _status = 'SENDING';
    });

    final success = await _bleService.sendWifiConfig(
      ssid,
      password,
      apiUrl: apiUrl.isNotEmpty ? apiUrl : null,
    );

    if (!mounted) return; // 检查 widget 是否已销毁

    if (!success) {
      setState(() {
        _isSending = false;
        _error = 'SEND_FAILED';
      });
      return;
    }

    if (mounted) {
      setState(() {
        _status = 'CONFIG_SENT_WAITING';
      });
    }
  }

  void _showSuccessDialog() {
    if (!mounted) return; // 检查 widget 是否已销毁

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text('Success'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Device configured successfully'),
            if (_configuredDeviceId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Device ID: $_configuredDeviceId',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 使用 popUntil 更安全，避免连续 pop 导致的状态问题
              Navigator.of(context).popUntil((route) {
                // 返回到第一个路由（通常是主页）
                return route.isFirst;
              });
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.platformName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _isConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_searching,
                      size: 48,
                      color: _isConnected ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (_isConnecting || _isSending) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            if (_isConnected) ...[
              TextField(
                controller: _ssidController,
                decoration: const InputDecoration(
                  labelText: 'WiFi SSID',
                  prefixIcon: Icon(Icons.wifi),
                  border: OutlineInputBorder(),
                ),
                enabled: !_isSending,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'WiFi Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                enabled: !_isSending,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _apiUrlController,
                decoration: const InputDecoration(
                  labelText: 'Server API URL',
                  hintText: 'http://192.168.31.78:48080',
                  prefixIcon: Icon(Icons.cloud),
                  border: OutlineInputBorder(),
                  helperText: 'From login page settings (read-only)',
                  filled: true,
                ),
                enabled: false, // 只读，从设置中读取
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSending ? null : _sendConfig,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_isSending ? 'Configuring...' : 'Start Config'),
              ),
            ],
            if (!_isConnecting && !_isConnected && _error != null)
              ElevatedButton.icon(
                onPressed: _connectDevice,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
