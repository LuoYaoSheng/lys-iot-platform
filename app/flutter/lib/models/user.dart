/// 用户相关模型
/// 作者: 罗耀生

class User {
  final String userId;
  final String username;
  final String email;
  final String? name;
  final DateTime? createdAt;

  User({
    required this.userId,
    required this.username,
    required this.email,
    this.name,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? json['email'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class LoginResponse {
  final User user;
  final String token;
  final String? refreshToken;
  final int? expiresIn;

  LoginResponse({
    required this.user,
    required this.token,
    this.refreshToken,
    this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? {};
    return LoginResponse(
      user: User.fromJson(userData),
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
    };
  }
}

class RegisterRequest {
  final String username;
  final String password;
  final String email;
  final String? name;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.email,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'username': username,
      'password': password,
      'email': email,
    };
    if (name != null) {
      data['name'] = name;
    }
    return data;
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
