/// BLE 扫描页面
/// 作者: 罗耀生
/// 日期: 2025-12-13

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ble_service.dart';
import 'config_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final BleService _bleService = BleService();
  List<ScanResult> _devices = [];
  bool _isScanning = false;
  String? _error;
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndScan();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _bleService.stopScan();
    super.dispose();
  }

  Future<void> _checkPermissionsAndScan() async {
    // 逐个请求权限（MIUI需要）
    final bluetoothScan = await Permission.bluetoothScan.request();
    if (!bluetoothScan.isGranted) {
      setState(() {
        _error = '需要蓝牙扫描权限';
      });
      return;
    }

    final bluetoothConnect = await Permission.bluetoothConnect.request();
    if (!bluetoothConnect.isGranted) {
      setState(() {
        _error = '需要蓝牙连接权限';
      });
      return;
    }

    final location = await Permission.locationWhenInUse.request();
    if (!location.isGranted) {
      setState(() {
        _error = '需要位置权限才能扫描BLE设备';
      });
      return;
    }

    // 等待权限完全生效（MIUI需要）

    // 检查位置服务是否开启
    final locationService = await Permission.location.serviceStatus;
    if (!locationService.isEnabled) {
      setState(() {
        _error = '请在设置中开启位置服务（GPS）\nMIUI系统BLE扫描需要开启位置服务';
      });
      return;
    }
    // 等待权限完全生效（MIUI需要）
    await Future.delayed(const Duration(milliseconds: 800));


    _startScan();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _error = null;
      _devices = [];
    });

    _scanSubscription?.cancel();
    _scanSubscription = _bleService.scan(timeout: const Duration(seconds: 15)).listen(
      (results) {
        setState(() {
          _devices = results;
        });
      },
      onDone: () {
        setState(() {
          _isScanning = false;
        });
      },
      onError: (e) {
        setState(() {
          _isScanning = false;
          _error = e.toString();
        });
      },
    );

    // 15秒后自动停止
    Future.delayed(const Duration(seconds: 15), () {
      if (_isScanning && mounted) {
        _bleService.stopScan();
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  void _onDeviceTap(ScanResult result) {
    // 停止扫描
    _bleService.stopScan();
    _scanSubscription?.cancel();

    // 跳转到配网页面
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigPage(device: result.device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备配网'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startScan,
            ),
        ],
      ),
      body: Column(
        children: [
          // 提示信息
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '正在扫描 "IoT-Switch-" 前缀的设备...\n请确保设备处于配网模式（LED快闪）',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // 错误提示
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
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

          // 设备列表
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth_searching,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning ? '正在扫描...' : '未发现设备',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (!_isScanning) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _startScan,
                            icon: const Icon(Icons.refresh),
                            label: const Text('重新扫描'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final result = _devices[index];
                      final device = result.device;
                      final rssi = result.rssi;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Icons.bluetooth,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        title: Text(
                          device.platformName.isNotEmpty
                              ? device.platformName
                              : '未知设备',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text('信号强度: $rssi dBm'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _onDeviceTap(result),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
