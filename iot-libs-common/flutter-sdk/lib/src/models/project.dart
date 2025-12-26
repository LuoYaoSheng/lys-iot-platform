/// 项目模型
/// 作者: 罗耀生
/// 日期: 2025-12-14

import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String projectId;
  final String name;
  final String? description;
  final String userId;
  final int status;
  final int deviceCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Project({
    required this.projectId,
    required this.name,
    this.description,
    required this.userId,
    this.status = 1,
    this.deviceCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      userId: json['userId'] as String,
      status: json['status'] as int? ?? 1,
      deviceCount: json['deviceCount'] as int? ?? 0,
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
      'projectId': projectId,
      'name': name,
      if (description != null) 'description': description,
      'userId': userId,
      'status': status,
      'deviceCount': deviceCount,
    };
  }

  Project copyWith({
    String? projectId,
    String? name,
    String? description,
    String? userId,
    int? status,
    int? deviceCount,
  }) {
    return Project(
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      deviceCount: deviceCount ?? this.deviceCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [projectId, name, description, userId, status, deviceCount];
}
