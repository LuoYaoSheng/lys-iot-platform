/// API 服务 - 与后端通信
/// 作者: 罗耀生
/// 日期: 2025-12-13
/// 更新: 2025-12-15 - 使用 SDK 统一配置

import 'dart:convert';
import 'dart:io';
import 'package:iot_platform_sdk/iot_platform_sdk.dart' show IoTConfig;
import '../models/device.dart';

/// API 配置
class ApiConfig {
  // 使用 SDK 的配置，通过构建时参数控制
  // flutter run --dart-define=ENV=development  (本地调试)
  // flutter run --dart-define=ENV=natapp       (真机调试，默认)
  static String get baseUrl => IoTConfig.fromEnvironment().apiBaseUrl;
  static const Duration timeout = Duration(seconds: 10);
}

/// API 响应
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  bool get isSuccess => code == 200;
}

/// API 服务
class ApiService {
  final HttpClient _client = HttpClient();
  String _baseUrl = ApiConfig.baseUrl;

  // 认证信息（优先使用 Bearer Token）
  String? _bearerToken;
  String? _apiKey;
  String? _apiSecret;

  /// 设置 API 地址
  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  /// 设置 Bearer Token（JWT认证，优先级最高）
  void setBearerToken(String? token) {
    _bearerToken = token;
  }

  /// 设置 API Key（备用认证方式）
  void setAPIKey(String apiKey, String apiSecret) {
    _apiKey = apiKey;
    _apiSecret = apiSecret;
  }

  /// 获取当前 API 地址
  String get baseUrl => _baseUrl;

  /// 为请求添加认证头（优先使用 Bearer Token）
  void _addAuthHeaders(HttpClientRequest request) {
    // 优先使用 Bearer Token
    if (_bearerToken != null && _bearerToken!.isNotEmpty) {
      request.headers.set('Authorization', 'Bearer $_bearerToken');
    }
    // 降级使用 API Key
    else if (_apiKey != null && _apiSecret != null) {
      request.headers.set('X-API-Key', _apiKey!);
      request.headers.set('X-API-Secret', _apiSecret!);
    }
  }

  /// 获取设备列表
  Future<ApiResponse<List<Device>>> getDevices({
    String? productKey,
    int? status,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      if (productKey != null) params['productKey'] = productKey;
      if (status != null) params['status'] = status.toString();

      final uri = Uri.parse('$_baseUrl/api/v1/devices').replace(queryParameters: params);
      final request = await _client.getUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      _addAuthHeaders(request);

      final response = await request.close().timeout(ApiConfig.timeout);
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body);

      if (json['code'] == 200 && json['data'] != null) {
        final devices = (json['data']['list'] as List)
            .map((e) => Device.fromJson(e))
            .toList();
        return ApiResponse(code: 200, message: 'success', data: devices);
      }

      return ApiResponse(
        code: json['code'] ?? 500,
        message: json['message'] ?? 'Unknown error',
      );
    } catch (e) {
      return ApiResponse(code: 500, message: e.toString());
    }
  }

  /// 获取设备详情
  Future<ApiResponse<Device>> getDevice(String deviceId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/devices/$deviceId');
      final request = await _client.getUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      _addAuthHeaders(request);

      final response = await request.close().timeout(ApiConfig.timeout);
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body);

      if (json['code'] == 200 && json['data'] != null) {
        return ApiResponse(
          code: 200,
          message: 'success',
          data: Device.fromJson(json['data']),
        );
      }

      return ApiResponse(
        code: json['code'] ?? 500,
        message: json['message'] ?? 'Unknown error',
      );
    } catch (e) {
      return ApiResponse(code: 500, message: e.toString());
    }
  }

  /// 控制设备
  Future<ApiResponse<void>> controlDevice(
    String deviceId, {
    // 新协议
    String? action,    // toggle 或 pulse
    String? position,  // toggle 模式：up/middle/down
    int? duration,     // pulse 模式：延迟时间（ms）
    // 兼容旧协议
    bool? switchState,
    int? angle,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/devices/$deviceId/control');
      final request = await _client.postUrl(uri);
      request.headers.set('Content-Type', 'application/json');
      _addAuthHeaders(request);

      final body = <String, dynamic>{};

      // 新协议优先
      if (action != null) {
        body['action'] = action;
        if (position != null) body['position'] = position;
        if (duration != null) body['duration'] = duration;
      } else {
        // 兼容旧协议
        if (switchState != null) body['switch'] = switchState;
        if (angle != null) body['angle'] = angle;
      }

      request.write(jsonEncode(body));

      final response = await request.close().timeout(ApiConfig.timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      final json = jsonDecode(responseBody);

      return ApiResponse(
        code: json['code'] ?? 500,
        message: json['message'] ?? 'Unknown error',
      );
    } catch (e) {
      return ApiResponse(code: 500, message: e.toString());
    }
  }

  /// 获取设备状态
  Future<ApiResponse<Map<String, dynamic>>> getDeviceStatus(String deviceId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/devices/$deviceId/status');
      final request = await _client.getUrl(uri);
      _addAuthHeaders(request);

      final response = await request.close().timeout(ApiConfig.timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      final json = jsonDecode(responseBody);

      if (json['code'] == 200) {
        return ApiResponse(
          code: json['code'],
          message: json['message'] ?? 'Success',
          data: json['data'] as Map<String, dynamic>,
        );
      } else {
        return ApiResponse(
          code: json['code'] ?? 500,
          message: json['message'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      return ApiResponse(code: 500, message: e.toString());
    }
  }

  /// 释放资源
  void dispose() {
    _client.close();
  }
}
