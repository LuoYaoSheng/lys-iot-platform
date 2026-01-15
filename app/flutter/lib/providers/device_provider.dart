/// 设备状态管理
/// 作者: 罗耀生

import 'package:flutter/foundation.dart';
import '../models/device.dart';
import '../services/device_api.dart';

class DeviceProvider with ChangeNotifier {
  final DeviceApi _api = DeviceApi();

  List<Device> _devices = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _total = 0;
  int _currentPage = 1;
  int _pageSize = 20;

  // Getters
  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  int get total => _total;
  bool get hasMore => _devices.length < _total;

  /// 获取在线设备数量
  int get onlineCount => _devices.where((d) => d.isOnline).length;

  /// 加载设备列表
  Future<bool> loadDevices({bool refresh = true}) async {
    if (refresh) {
      _isLoading = true;
      _currentPage = 1;
    } else {
      _isLoadingMore = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.getDeviceList(
        page: _currentPage,
        size: _pageSize,
      );

      if (result.isSuccess && result.data != null) {
        if (refresh) {
          _devices = result.data!.list;
        } else {
          _devices.addAll(result.data!.list);
        }
        _total = result.data!.total;
        _currentPage++;

        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.message ?? '加载设备列表失败';
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '加载设备列表失败: $e';
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
      return false;
    }
  }

  /// 加载更多设备
  Future<bool> loadMore() async {
    if (!hasMore || _isLoadingMore) return false;
    return loadDevices(refresh: false);
  }

  /// 刷新设备列表
  Future<bool> refresh() async {
    return loadDevices(refresh: true);
  }

  /// 获取设备详情
  Future<Device?> getDevice(String deviceId) async {
    try {
      final result = await _api.getDevice(deviceId);
      if (result.isSuccess && result.data != null) {
        // 更新本地列表中的设备
        final index = _devices.indexWhere((d) => d.deviceId == deviceId);
        if (index >= 0) {
          _devices[index] = result.data!;
          notifyListeners();
        }
        return result.data!;
      }
    } catch (_) {
      // 静默失败
    }
    return null;
  }

  /// 获取设备状态
  Future<DeviceStatusResponse?> getDeviceStatus(String deviceId) async {
    try {
      final result = await _api.getDeviceStatus(deviceId);
      if (result.isSuccess && result.data != null) {
        return result.data!;
      }
    } catch (_) {
      // 静默失败
    }
    return null;
  }

  /// 控制设备 - 位置切换
  Future<bool> togglePosition(String deviceId, String position) async {
    try {
      final request = ControlRequest.toggle(position);
      final result = await _api.controlDevice(deviceId, request);

      if (result.isSuccess) {
        // 更新本地设备状态
        final index = _devices.indexWhere((d) => d.deviceId == deviceId);
        if (index >= 0) {
          final device = _devices[index];
          _devices[index] = device.copyWith(location: position);
          notifyListeners();
        }
        return true;
      } else {
        _errorMessage = result.message ?? '控制设备失败';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '控制设备失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 控制设备 - 脉冲触发
  Future<bool> triggerPulse(String deviceId, int duration) async {
    try {
      final request = ControlRequest.pulse(duration);
      final result = await _api.controlDevice(deviceId, request);

      if (result.isSuccess) {
        return true;
      } else {
        _errorMessage = result.message ?? '控制设备失败';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '控制设备失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 控制设备 - 唤醒
  Future<bool> triggerWakeup(String deviceId) async {
    try {
      final request = ControlRequest.trigger();
      final result = await _api.controlDevice(deviceId, request);

      if (result.isSuccess) {
        return true;
      } else {
        _errorMessage = result.message ?? '控制设备失败';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '控制设备失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 删除设备
  Future<bool> deleteDevice(String deviceId) async {
    try {
      final result = await _api.deleteDevice(deviceId);

      if (result.isSuccess) {
        _devices.removeWhere((d) => d.deviceId == deviceId);
        _total = _total > 0 ? _total - 1 : 0;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.message ?? '删除设备失败';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '删除设备失败: $e';
      notifyListeners();
      return false;
    }
  }

  /// 添加本地设备（配网成功后调用）
  void addDevice(Device device) {
    _devices.insert(0, device);
    _total++;
    notifyListeners();
  }

  /// 更新本地设备状态
  void updateDeviceStatus(String deviceId, DeviceStatusCode status) {
    final index = _devices.indexWhere((d) => d.deviceId == deviceId);
    if (index >= 0) {
      _devices[index] = _devices[index].copyWith(status: status);
      notifyListeners();
    }
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
