/// 认证 API 服务
/// 作者: 罗耀生

import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/user.dart';
import '../models/api_result.dart';

class AuthApi {
  final ApiClient _client = ApiClient();

  /// 用户注册
  Future<ApiResult<RegisterResponse>> register(RegisterRequest request) async {
    try {
      final response = await _client.post(
        '/users/register',
        data: request.toJson(),
      );

      final result = ApiResult<RegisterResponse>.fromJson(
        response.data,
        (data) => data != null ? RegisterResponse.fromJson(data) : null,
      );

      // 注册成功后保存 token
      if (result.isSuccess && result.data?.token != null) {
        await _client.setToken(result.data!.token);
      }

      return result;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 用户登录
  Future<ApiResult<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await _client.post(
        '/users/login',
        data: request.toJson(),
      );

      final result = ApiResult<LoginResponse>.fromJson(
        response.data,
        (data) => data != null ? LoginResponse.fromJson(data) : null,
      );

      // 登录成功后保存 token
      if (result.isSuccess && result.data?.token != null) {
        await _client.setToken(result.data!.token);
      }

      return result;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 刷新 Token
  Future<ApiResult<LoginResponse>> refreshToken(String refreshToken) async {
    try {
      final response = await _client.post(
        '/users/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      final result = ApiResult<LoginResponse>.fromJson(
        response.data,
        (data) => data != null ? LoginResponse.fromJson(data) : null,
      );

      // 刷新成功后保存新 token
      if (result.isSuccess && result.data?.token != null) {
        await _client.setToken(result.data!.token);
      }

      return result;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 获取当前用户信息
  Future<ApiResult<User>> getMe() async {
    try {
      final response = await _client.get('/users/me');

      return ApiResult<User>.fromJson(
        response.data,
        (data) => data != null ? User.fromJson(data) : null,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 退出登录
  Future<void> logout() async {
    await _client.clearAuth();
  }

  /// 请求密码重置
  Future<ApiResult<Map<String, dynamic>>> requestPasswordReset(String email) async {
    try {
      final response = await _client.post(
        '/users/password/reset/request',
        data: {'email': email},
      );

      return ApiResult<Map<String, dynamic>>.fromJson(response.data, null);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// 确认密码重置
  Future<ApiResult<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _client.post(
        '/users/password/reset/confirm',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      return ApiResult<void>.fromJson(response.data, null);
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
        message ??= '资源不存在';
        break;
      case 409:
        message ??= '资源冲突';
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

/// 注册响应
class RegisterResponse {
  final String userId;
  final String username;
  final String email;
  final String? token;

  RegisterResponse({
    required this.userId,
    required this.username,
    required this.email,
    this.token,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      token: json['token'] as String?,
    );
  }
}
