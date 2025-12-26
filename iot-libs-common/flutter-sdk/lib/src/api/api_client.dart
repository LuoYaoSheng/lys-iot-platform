/// HTTP API 客户端
/// 作者: 罗耀生
/// 日期: 2025-12-14

import 'package:dio/dio.dart';
import '../utils/config.dart';
import '../utils/logger.dart';
import '../models/api_response.dart';

/// 401未认证回调函数类型
typedef OnUnauthorizedCallback = void Function();

class ApiClient {
  late final Dio _dio;
  final IoTConfig config;
  String? _token;
  OnUnauthorizedCallback? _onUnauthorized;

  ApiClient({required this.config}) {
    _dio = Dio(BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: Duration(seconds: config.connectTimeout),
      receiveTimeout: Duration(seconds: config.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        if (config.enableLogging) {
          IoTLogger.debug('\${options.method} \${options.uri}', 'API');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (config.enableLogging) {
          IoTLogger.debug('Response: \${response.statusCode}', 'API');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        IoTLogger.error('API Error: \${error.message}', 'API', error);

        // 检测401错误，触发回调
        if (error.response?.statusCode == 401) {
          IoTLogger.warning('检测到401未认证，触发回调', 'API');
          _onUnauthorized?.call();
        }

        return handler.next(error);
      },
    ));
  }

  /// 设置401未认证回调
  void setOnUnauthorized(OnUnauthorizedCallback? callback) {
    _onUnauthorized = callback;
  }

  /// 设置认证 Token
  void setToken(String? token) {
    _token = token;
  }

  /// 获取当前 Token
  String? get token => _token;

  /// 是否已登录
  bool get isAuthenticated => _token != null;

  /// GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// PUT 请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// DELETE 请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 处理错误
  ApiResponse<T> _handleError<T>(DioException e) {
    String message;
    int code;

    if (e.response != null) {
      try {
        final data = e.response!.data;
        code = data['code'] ?? e.response!.statusCode ?? 500;
        message = data['message'] ?? 'Unknown error';
      } catch (_) {
        code = e.response!.statusCode ?? 500;
        message = e.response!.statusMessage ?? 'Unknown error';
      }

      // 检测401错误
      if (e.response!.statusCode == 401) {
        IoTLogger.warning('401未认证：Token可能已过期', 'API');
      }
    } else {
      code = -1;
      message = e.message ?? 'Network error';
    }

    return ApiResponse<T>(
      code: code,
      message: message,
    );
  }
}
