/// 用户模型
/// 作者: 罗耀生
/// 日期: 2025-12-14

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String? email;
  final String? phone;
  final String? nickname;
  final String? avatar;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.nickname,
    this.avatar,
    this.status = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['userId'] ?? json['id'] ?? '') as String,
      username: (json['name'] ?? json['username'] ?? json['email'] ?? '') as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      status: json['status'] as int? ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (nickname != null) 'nickname': nickname,
      if (avatar != null) 'avatar': avatar,
      'status': status,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? nickname,
    String? avatar,
    int? status,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, username, email, phone, nickname, avatar, status];
}

/// 登录响应
class LoginResponse {
  final String token;
  final User user;
  final DateTime expiresAt;

  const LoginResponse({
    required this.token,
    required this.user,
    required this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // 支持 expiresIn (秒数) 和 expiresAt (时间戳) 两种格式
    DateTime expires;
    if (json['expiresAt'] != null) {
      expires = DateTime.parse(json['expiresAt']);
    } else if (json['expiresIn'] != null) {
      expires = DateTime.now().add(Duration(seconds: json['expiresIn'] as int));
    } else {
      expires = DateTime.now().add(const Duration(hours: 2));
    }
    
    return LoginResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: expires,
    );
  }
}
