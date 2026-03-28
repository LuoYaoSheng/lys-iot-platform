// BLE 配网服务
// 作者: 罗耀生
// 日期: 2025-12-13

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// BLE 配网 UUID 常量
class BleUuids {
  static const String serviceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';
  static const String wifiCharUuid = '0000ffe1-0000-1000-8000-00805f9b34fb';
  static const String statusCharUuid = '0000ffe2-0000-1000-8000-00805f9b34fb';
  static const List<String> devicePrefixes = ['IoT-Switch-', 'IoT-Wakeup-'];
}

// 配网状态通知
class ConfigStatusNotification {
  final String status;
  final String? message;
  final String? ip;
  final String? deviceId;

  ConfigStatusNotification({
    required this.status,
    this.message,
    this.ip,
    this.deviceId,
  });

  factory ConfigStatusNotification.fromJson(Map<String, dynamic> json) {
    return ConfigStatusNotification(
      status: json['status'] ?? '',
      message: json['message'],
      ip: json['ip'],
      deviceId: json['deviceId'],
    );
  }
}

// BLE 配网服务
class BleService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _wifiChar;
  BluetoothCharacteristic? _statusChar;
  StreamSubscription? _statusSubscription;

  final _statusController = StreamController<ConfigStatusNotification>.broadcast();
  Stream<ConfigStatusNotification> get statusStream => _statusController.stream;

  // 检查蓝牙是否可用
  Future<bool> isAvailable() async {
    return await FlutterBluePlus.isSupported;
  }

  // 检查蓝牙是否开启
  Future<bool> isOn() async {
    return await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
  }

  // 扫描设备
  Stream<List<ScanResult>> scan({Duration timeout = const Duration(seconds: 10)}) {
    // 开始扫描
    FlutterBluePlus.startScan(
      timeout: timeout,
    );

    return FlutterBluePlus.scanResults.map((results) {
      // 过滤出当前支持的 IoT 设备前缀
      return results.where((r) {
        final name = r.device.platformName;
        return BleUuids.devicePrefixes.any(name.startsWith);
      }).toList();
    });
  }

  // 停止扫描
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // 连接设备
  Future<bool> connect(BluetoothDevice device) async {
    try {
      debugPrint('BLE: Connecting...');
      await device.connect(timeout: const Duration(seconds: 30));
      _connectedDevice = device;
      debugPrint('BLE: Connected!');

      // 发现服务
      final services = await device.discoverServices();
      debugPrint('BLE: Found services');

      // 查找配网服务
      debugPrint('BLE: Searching for service: ${BleUuids.serviceUuid.toLowerCase()}');
      for (final service in services) {
        final serviceUuid = service.uuid.toString().toLowerCase();
        debugPrint('BLE: Found service UUID: $serviceUuid');

        if (serviceUuid.contains('ffe0') || serviceUuid == BleUuids.serviceUuid.toLowerCase()) {
          debugPrint('BLE: Found config service (matched)');
          debugPrint('BLE: Looking for WiFi char: ${BleUuids.wifiCharUuid.toLowerCase()}');
          debugPrint('BLE: Looking for Status char: ${BleUuids.statusCharUuid.toLowerCase()}');

          for (final char in service.characteristics) {
            final charUuid = char.uuid.toString().toLowerCase();
            debugPrint('BLE: Found characteristic UUID: $charUuid');

            if (charUuid.contains('ffe1') || charUuid == BleUuids.wifiCharUuid.toLowerCase()) {
              _wifiChar = char;
              debugPrint('BLE: Found WiFi char (matched)');
            } else if (charUuid.contains('ffe2') || charUuid == BleUuids.statusCharUuid.toLowerCase()) {
              _statusChar = char;
              debugPrint('BLE: Found Status char (matched)');
            }
          }
        }
      }

      if (_wifiChar == null || _statusChar == null) {
        debugPrint('BLE: ERROR - Chars not found');
        await disconnect();
        return false;
      }

      // 订阅状态通知
      await _statusChar!.setNotifyValue(true);
      _statusSubscription = _statusChar!.lastValueStream.listen((value) {
        if (value.isNotEmpty) {
          try {
            final json = jsonDecode(utf8.decode(value));
            final notification = ConfigStatusNotification.fromJson(json);
            _statusController.add(notification);
          } catch (e) {
            debugPrint('BLE: Failed to parse status: $e');
          }
        }
      });

      return true;
    } catch (e) {
      debugPrint('BLE: Connect failed: $e');
      return false;
    }
  }

  // 断开连接
  Future<void> disconnect() async {
    _statusSubscription?.cancel();
    _statusSubscription = null;

    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        debugPrint('BLE: Disconnect error: $e');
      }
      _connectedDevice = null;
    }

    _wifiChar = null;
    _statusChar = null;
  }

  // 发送 WiFi 配置（含 API 地址）
  Future<bool> sendWifiConfig(String ssid, String password, {String? apiUrl}) async {
    if (_wifiChar == null) {
      return false;
    }

    try {
      final configMap = <String, String>{
        'ssid': ssid,
        'password': password,
      };

      // 如果提供了 API 地址，则包含在配置中
      if (apiUrl != null && apiUrl.isNotEmpty) {
        configMap['apiUrl'] = apiUrl;
      }

      final config = jsonEncode(configMap);
      debugPrint('BLE: Sending config: $config');

      await _wifiChar!.write(
        utf8.encode(config),
        withoutResponse: false,
        timeout: 10,  // 10秒超时
      );
      debugPrint('BLE: Config sent successfully');
      return true;
    } catch (e) {
      debugPrint('BLE: Send WiFi config failed: $e');
      return false;
    }
  }

  // 是否已连接
  bool get isConnected => _connectedDevice != null;

  // 释放资源
  void dispose() {
    _statusSubscription?.cancel();
    _statusController.close();
  }
}
