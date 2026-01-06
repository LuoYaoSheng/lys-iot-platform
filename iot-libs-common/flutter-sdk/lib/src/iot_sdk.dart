/// IoT SDK 主入口
/// 作者: 罗耀生
/// 日期: 2025-12-14
/// 更新: 2025-12-19 - 支持用户信息持久化
///
/// 使用示例:
/// ```dart
/// // 初始化 SDK
/// final sdk = IoTSdk(config: IoTConfig.development());
///
/// // 用户登录
/// final loginResult = await sdk.auth.login(
///   username: 'user',
///   password: 'pass',
/// );
///
/// // 获取设备列表
/// final devices = await sdk.device.getDeviceList();
///
/// // 连接设备 MQTT
/// await sdk.connectDevice(device);
/// sdk.mqtt?.reportProperty({'temperature': 25.5});
/// ```

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_client.dart';
import 'api/auth_api.dart';
import 'api/device_api.dart';
import 'api/project_api.dart';
import 'mqtt/mqtt_client.dart';
import 'models/device.dart';
import 'models/user.dart';
import 'utils/config.dart';
import 'utils/logger.dart';

class IoTSdk {
  static IoTSdk? _instance;

  final IoTConfig config;
  late final ApiClient _apiClient;
  late final AuthApi _authApi;
  late final DeviceApi _deviceApi;
  late final ProjectApi _projectApi;

  IoTMqttClient? _mqttClient;
  User? _currentUser;
  Device? _currentDevice;

  IoTSdk._internal({required this.config}) {
    _apiClient = ApiClient(config: config);
    _authApi = AuthApi(_apiClient);
    _deviceApi = DeviceApi(_apiClient);
    _projectApi = ProjectApi(_apiClient);

    IoTLogger.setEnabled(config.enableLogging);
  }

  /// 获取 SDK 实例 (单例模式)
  factory IoTSdk({required IoTConfig config}) {
    _instance ??= IoTSdk._internal(config: config);
    return _instance!;
  }

  /// 获取已初始化的实例
  static IoTSdk get instance {
    if (_instance == null) {
      throw StateError('IoTSdk 未初始化，请先调用 IoTSdk(config: ...) 初始化');
    }
    return _instance!;
  }

  /// 认证 API
  AuthApi get auth => _authApi;

  /// 设备 API
  DeviceApi get device => _deviceApi;

  /// 项目 API
  ProjectApi get project => _projectApi;

  /// MQTT 客户端
  IoTMqttClient? get mqtt => _mqttClient;

  /// 当前登录用户
  User? get currentUser => _currentUser;

  /// 当前连接的设备
  Device? get currentDevice => _currentDevice;

  /// 是否已登录

  /// 设置401未认证回调（用于自动跳转登录页）
  void setOnUnauthorized(void Function()? callback) {
    _apiClient.setOnUnauthorized(callback);
  }
  bool get isLoggedIn => _authApi.isLoggedIn;

  /// 初始化 SDK (从本地存储恢复会话)
  Future<bool> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('iot_token');
      final userJson = prefs.getString('iot_user');

      // 恢复用户信息
      if (userJson != null && userJson.isNotEmpty) {
        try {
          final userData = jsonDecode(userJson) as Map<String, dynamic>;
          _currentUser = User.fromJson(userData);
          IoTLogger.info('用户信息已恢复: ${_currentUser!.username}', 'SDK');
        } catch (e) {
          IoTLogger.warning('恢复用户信息失败: $e', 'SDK');
        }
      }

      // 恢复 token
      if (token != null && token.isNotEmpty) {
        _apiClient.setToken(token);

        // 验证 token 是否有效（临时禁用401回调，避免验证失败时触发跳转）
        final savedCallback = _apiClient.onUnauthorized;
        _apiClient.setOnUnauthorized(null);

        try {
          final response = await _authApi.getCurrentUser();
          _apiClient.setOnUnauthorized(savedCallback); // 恢复回调

          if (response.isSuccess) {
            IoTLogger.info('Token验证成功，跳过登录', 'SDK');
            return true;
          }
        } catch (e) {
          _apiClient.setOnUnauthorized(savedCallback); // 恢复回调
          IoTLogger.warning('Token验证失败: $e', 'SDK');
        }

        // Token 无效，清除
        _apiClient.setToken(null);
        await prefs.remove('iot_token');
        IoTLogger.warning('Token已过期，需要重新登录', 'SDK');
        return false;
      }

      return false;
    } catch (e) {
      IoTLogger.error('初始化失败: $e', 'SDK');
      return false;
    }
  }

  /// 用户登录
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final result = await _authApi.login(
      username: username,
      password: password,
    );

    if (result.isSuccess && result.data != null) {
      _currentUser = result.data!.user;

      // 保存 token 和用户信息到本地
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('iot_token', result.data!.token);
      await prefs.setString('iot_user', jsonEncode(_currentUser!.toJson()));

      IoTLogger.info('登录成功: ${_currentUser!.username}', 'SDK');
      return true;
    }

    IoTLogger.warning('登录失败: ${result.message}', 'SDK');
    return false;
  }

  /// 退出登录
  Future<void> logout() async {
    _authApi.logout();

    // 断开 MQTT
    disconnectDevice();

    // 只清除 token，保留用户信息供下次登录显示
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('iot_token');

    IoTLogger.info('已退出登录', 'SDK');
  }

  /// 连接设备 MQTT
  Future<bool> connectDevice(Device device) async {
    // 先断开之前的连接
    disconnectDevice();

    _currentDevice = device;
    _mqttClient = IoTMqttClient(
      config: config,
      device: device,
    );

    final connected = await _mqttClient!.connect();
    if (connected) {
      IoTLogger.info('设备 MQTT 已连接: ${device.deviceId}', 'SDK');
    }

    return connected;
  }

  /// 断开设备 MQTT
  void disconnectDevice() {
    _mqttClient?.dispose();
    _mqttClient = null;
    _currentDevice = null;
  }

  /// 释放 SDK 资源
  void dispose() {
    disconnectDevice();
    _instance = null;
  }
}
