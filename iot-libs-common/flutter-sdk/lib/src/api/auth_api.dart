/// 认证 API
/// 作者: 罗耀生
/// 日期: 2025-12-14

import 'api_client.dart';
import '../models/api_response.dart';
import '../models/user.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  /// 用户登录
  Future<ApiResponse<LoginResponse>> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post<LoginResponse>(
      '/api/v1/users/login',
      data: {
        'email': username,
        'password': password,
      },
      fromJson: (data) => LoginResponse.fromJson(data),
    );

    // 登录成功后保存 token
    if (response.isSuccess && response.data != null) {
      _client.setToken(response.data!.token);
    }

    return response;
  }

  /// 用户注册
  Future<ApiResponse<User>> register({
    required String name,
    required String password,
    required String email,
    String? phone,
  }) async {
    return await _client.post<User>(
      '/api/v1/users/register',
      data: {
        'name': name,
        'password': password,
        'email': email,
        if (phone != null) 'phone': phone,
      },
      fromJson: (data) => User.fromJson(data),
    );
  }

  /// 获取当前用户信息
  Future<ApiResponse<User>> getCurrentUser() async {
    return await _client.get<User>(
      '/api/v1/users/me',
      fromJson: (data) => User.fromJson(data),
    );
  }

  /// 更新用户信息
  Future<ApiResponse<User>> updateProfile({
    String? nickname,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    return await _client.put<User>(
      '/api/v1/users/me',
      data: {
        if (nickname != null) 'nickname': nickname,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
      },
      fromJson: (data) => User.fromJson(data),
    );
  }

  /// 修改密码
  Future<ApiResponse<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await _client.put<void>(
      '/api/v1/user/password',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// 退出登录
  void logout() {
    _client.setToken(null);
  }

  /// 是否已登录
  bool get isLoggedIn => _client.isAuthenticated;
}
