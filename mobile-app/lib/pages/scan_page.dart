/// BLE 扫描页面
/// 作者: 罗耀生
/// 版本: 3.0.0
/// 使用 Design System 组件

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../design_system/design_system.dart';
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

    // 检查蓝牙是否开启
    final btState = await FlutterBluePlus.adapterState.first;
    if (btState != BluetoothAdapterState.on) {
      if (!mounted) return;
      setState(() {
        _error = '请开启蓝牙后重试';
      });
      // 弹窗提示
      _showBluetoothDialog();
      return;
    }

    _startScan();
  }

  void _showBluetoothDialog() {
    MinimalDialog.showInfo(
      context: context,
      title: '蓝牙未开启',
      message: '扫描设备需要开启蓝牙，请在系统设置中开启蓝牙后重试。',
      confirmText: '我知道了',
    );
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
        backgroundColor: MinimalTokens.white,
        elevation: 0,
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
            padding: MinimalEdgeInsets.md,
            color: MinimalTokens.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: MinimalTokens.primary),
                const SizedBox(width: MinimalSpacing.md),
                Expanded(
                  child: Text(
                    '正在扫描 "IoT-Switch-" 前缀的设备...\n请确保设备处于配网模式（LED快闪）',
                    style: TextStyle(
                      color: MinimalTokens.primary,
                      fontSize: MinimalTokens.fontSizeCaption,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 错误提示
          if (_error != null)
            Container(
              padding: MinimalEdgeInsets.md,
              color: MinimalTokens.error.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: MinimalTokens.error),
                  const SizedBox(width: MinimalSpacing.md),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: MinimalTokens.error),
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
                          color: MinimalTokens.gray300,
                        ),
                        const MinimalSpacer(size: MinimalSpacing.md),
                        Text(
                          _isScanning ? '正在扫描...' : '未发现设备',
                          style: TextStyle(
                            fontSize: MinimalTokens.fontSizeBody,
                            color: MinimalTokens.gray500,
                          ),
                        ),
                        if (!_isScanning) ...[
                          const MinimalSpacer(size: MinimalSpacing.md),
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
                          backgroundColor: MinimalTokens.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.bluetooth,
                            color: MinimalTokens.primary,
                          ),
                        ),
                        title: Text(
                          device.platformName.isNotEmpty
                              ? device.platformName
                              : '未知设备',
                          style: TextStyle(
                            fontWeight: MinimalTokens.fontWeightMedium,
                            color: MinimalTokens.gray700,
                          ),
                        ),
                        subtitle: Text(
                          '信号强度: $rssi dBm',
                          style: TextStyle(
                            color: MinimalTokens.gray500,
                            fontSize: MinimalTokens.fontSizeCaption,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: MinimalTokens.gray300,
                        ),
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
