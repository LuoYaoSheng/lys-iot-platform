/// 设备 API 服务
/// 作者: 罗耀生

import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/device.dart';
import '../models/api_result.dart';

class DeviceApi {
  final ApiClient _client = ApiClient();

  /// 获取设备列表
  /// [productKey] 产品标识（可选）
  /// [status] 设备状态（可选）
  /// [page] 页码，默认 1
  /// [size] 每页数量，默认 20
  Future<ApiResult<DeviceListResponse>> getDeviceList({
    String? productKey,
    int? status,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (productKey != null) {
        queryParams['productKey'] = productKey;
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _client.get(
        '/devices',
        queryParameters: queryParams,
      );

      return ApiResult<DeviceListResponse>.fromJson(
        response.data,
        (data) => data != null ? DeviceListResponse.fromJson(data) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 获取设备详情
  Future<ApiResult<Device>> getDevice(String deviceId) async {
    try {
      final response = await _client.get('/devices/$deviceId');

      return ApiResult<Device>.fromJson(
        response.data,
        (data) => data != null ? Device.fromJson(data) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 获取设备状态
  Future<ApiResult<DeviceStatusResponse>> getDeviceStatus(String deviceId) async {
    try {
      final response = await _client.get('/devices/$deviceId/status');

      return ApiResult<DeviceStatusResponse>.fromJson(
        response.data,
        (data) => data != null ? DeviceStatusResponse.fromJson(data) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 控制设备
  Future<ApiResult<Map<String, dynamic>>> controlDevice(
    String deviceId,
    ControlRequest request,
  ) async {
    try {
      final response = await _client.post(
        '/devices/$deviceId/control',
        data: request.toJson(),
      );

      return ApiResult<Map<String, dynamic>>.fromJson(response.data, null);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 删除设备
  Future<ApiResult<void>> deleteDevice(String deviceId) async {
    try {
      final response = await _client.delete('/devices/$deviceId');

      return ApiResult<void>.fromJson(response.data, null);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 设备激活（BLE配网后调用）
  /// 此接口由设备端调用，但APP也可以代为激活
  Future<ApiResult<Map<String, dynamic>>> activateDevice({
    required String productKey,
    required String deviceSN,
    String? firmwareVersion,
    String? chipModel,
  }) async {
    try {
      final response = await _client.post(
        '/devices/activate',
        data: {
          'productKey': productKey,
          'deviceSN': deviceSN,
          if (firmwareVersion != null) 'firmwareVersion': firmwareVersion,
          if (chipModel != null) 'chipModel': chipModel,
        },
      );

      return ApiResult<Map<String, dynamic>>.fromJson(response.data, null);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  ApiResult<T> _handleError<T>(DioException error) {
    int code = 0;
    String? message;

    if (error.response != null) {
      code = error.response!.statusCode ?? 0;
      final data = error.response!.data;
      if (data is Map) {
        message = data['message'] as String?;
      }
    }

    switch (code) {
      case 401:
        message ??= '未认证或登录已过期';
        break;
      case 403:
        message ??= '无权限访问';
        break;
      case 404:
        message ??= '设备不存在';
        break;
      default:
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          message = '网络连接超时';
        } else if (error.type == DioExceptionType.connectionError) {
          message = '网络连接失败';
        } else {
          message ??= '请求失败: $message';
        }
    }

    return ApiResult<T>(
      code: code,
      message: message,
    );
  }
}
