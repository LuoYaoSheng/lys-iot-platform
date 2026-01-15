/// 认证状态管理
/// 作者: 罗耀生

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_api.dart';

class AuthProvider with ChangeNotifier {
  final AuthApi _api = AuthApi();

  User? _user;
  String? _token;
  String? _refreshToken;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 用户名显示
  String get displayName => _user?.name ?? _user?.email?.split('@')[0] ?? '用户';

  /// 初始化 - 从本地恢复登录状态
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _refreshToken = prefs.getString('refresh_token');

    final userId = prefs.getString('user_id');
    final userName = prefs.getString('user_name');
    final userEmail = prefs.getString('user_email');

    if (userId != null && _token != null) {
      _user = User(
        userId: userId,
        username: userName ?? userEmail ?? '',
        email: userEmail ?? '',
      );
      notifyListeners();

      // 尝试获取最新用户信息
      try {
        await refreshUserInfo();
      } catch (_) {
        // 静默失败，使用缓存的用户信息
      }
    }
  }

  /// 用户登录
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      final result = await _api.login(request);

      if (result.isSuccess && result.data != null) {
        _user = result.data!.user;
        _token = result.data!.token;
        _refreshToken = result.data!.refreshToken;
        await _saveAuthInfo();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.message ?? '登录失败';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '登录失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 用户注册
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        name: name,
      );
      final result = await _api.register(request);

      if (result.isSuccess) {
        // 注册成功，如果有token则自动登录
        if (result.data?.token != null) {
          _token = result.data!.token;
          _user = User(
            userId: result.data!.userId,
            username: result.data!.username,
            email: result.data!.email,
          );
          await _saveAuthInfo();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.message ?? '注册失败';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '注册失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _token = null;
    _refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');

    notifyListeners();
  }

  /// 刷新用户信息
  Future<void> refreshUserInfo() async {
    if (_token == null) return;

    try {
      final result = await _api.getMe();
      if (result.isSuccess && result.data != null) {
        _user = result.data!;
        await _saveAuthInfo();
        notifyListeners();
      }
    } catch (_) {
      // 静默失败
    }
  }

  /// 刷新Token
  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final result = await _api.refreshToken(_refreshToken!);
      if (result.isSuccess && result.data != null) {
        _token = result.data!.token;
        _refreshToken = result.data!.refreshToken;
        await _saveAuthInfo();
        return true;
      }
    } catch (_) {
      // Token刷新失败，需要重新登录
      await logout();
    }
    return false;
  }

  /// 保存认证信息到本地
  Future<void> _saveAuthInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString('auth_token', _token!);
    }
    if (_refreshToken != null) {
      await prefs.setString('refresh_token', _refreshToken!);
    }
    if (_user != null) {
      await prefs.setString('user_id', _user!.userId);
      await prefs.setString('user_name', _user!.username);
      await prefs.setString('user_email', _user!.email);
    }
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
