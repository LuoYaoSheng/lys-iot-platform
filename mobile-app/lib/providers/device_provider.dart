/// 设备状态管理
/// 作者: 罗耀生
/// 日期: 2025-12-13
/// 更新: 2025-12-15 - 使用 SDK API 进行认证

import 'package:flutter/foundation.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import '../models/device.dart' show BleDevice, ConfigStatus, ConfigStatusExtension;
import '../services/ble_service.dart';

/// 设备状态管理 Provider
class DeviceProvider extends ChangeNotifier {
  final BleService _bleService = BleService();

  // 设备列表 (使用 SDK 的 Device 模型)
  List<Device> _devices = [];
  List<Device> get devices => _devices;

  // 加载状态
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 错误信息
  String? _error;
  String? get error => _error;

  // 配网状态
  ConfigStatus _configStatus = ConfigStatus.idle;
  ConfigStatus get configStatus => _configStatus;

  String? _configError;
  String? get configError => _configError;

  String? _configuredDeviceId;
  String? get configuredDeviceId => _configuredDeviceId;

  /// 获取 BLE 服务
  BleService get bleService => _bleService;

  /// 设置 API 地址 (保留接口兼容性，但实际由 SDK 管理)
  void setApiBaseUrl(String url) {
    // SDK 的 API 地址在初始化时已设置
  }

  /// 加载设备列表 (使用 SDK API，带认证)
  Future<void> loadDevices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await IoTSdk.instance.device.getDeviceList();

      if (response.isSuccess && response.data != null) {
        _devices = response.data!.list;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 控制设备开关
  Future<bool> controlSwitch(String deviceId, bool state) async {
    try {
      final response = await IoTSdk.instance.device.setProperty(
        deviceId: deviceId,
        propertyId: 'switch',
        value: state,
      );
      if (!response.isSuccess) {
        _error = response.message;
        notifyListeners();
      }
      return response.isSuccess;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 控制舵机角度
  Future<bool> controlAngle(String deviceId, int angle) async {
    try {
      final response = await IoTSdk.instance.device.setProperty(
        deviceId: deviceId,
        propertyId: 'angle',
        value: angle,
      );
      if (!response.isSuccess) {
        _error = response.message;
        notifyListeners();
      }
      return response.isSuccess;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 更新配网状态
  void _updateConfigStatus(ConfigStatus status, {String? error, String? deviceId}) {
    _configStatus = status;
    _configError = error;
    if (deviceId != null) {
      _configuredDeviceId = deviceId;
    }
    notifyListeners();
  }

  /// 重置配网状态
  void resetConfigStatus() {
    _configStatus = ConfigStatus.idle;
    _configError = null;
    _configuredDeviceId = null;
    notifyListeners();
  }

  /// 开始 BLE 配网
  Future<bool> startBleConfig(
    String deviceAddress,
    String ssid,
    String password, {
    String? apiUrl,
  }) async {
    resetConfigStatus();

    // 1. 连接设备
    _updateConfigStatus(ConfigStatus.connecting);

    // 获取设备引用（通过扫描结果或缓存）
    // 这里简化处理，实际需要从扫描结果中获取

    // 2. 监听状态通知
    _bleService.statusStream.listen((notification) {
      switch (notification.status) {
        case 'received':
          _updateConfigStatus(ConfigStatus.waitingWifi);
          break;
        case 'connecting':
          _updateConfigStatus(ConfigStatus.waitingWifi);
          break;
        case 'wifi_connected':
          _updateConfigStatus(ConfigStatus.activating);
          break;
        case 'activated':
          _updateConfigStatus(
            ConfigStatus.activated,
            deviceId: notification.deviceId,
          );
          // 配网成功后刷新设备列表
          loadDevices();
          break;
        case 'error':
          _updateConfigStatus(
            ConfigStatus.error,
            error: notification.message ?? '配网失败',
          );
          break;
      }
    });

    // 3. 发送 WiFi 配置
    _updateConfigStatus(ConfigStatus.sendingConfig);
    final success = await _bleService.sendWifiConfig(ssid, password, apiUrl: apiUrl);

    if (!success) {
      _updateConfigStatus(ConfigStatus.error, error: '发送WiFi配置失败');
      return false;
    }

    return true;
  }

  /// 释放资源
  @override
  void dispose() {
    _bleService.dispose();
    super.dispose();
  }

  /// 删除设备
  Future<bool> deleteDevice(String deviceId) async {
    try {
      final response = await IoTSdk.instance.device.deleteDevice(deviceId);
      if (response.isSuccess) {
        _devices.removeWhere((d) => d.deviceId == deviceId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Delete device error: $e');
      return false;
    }
  }
}
