/// 项目 API
/// 作者: 罗耀生
/// 日期: 2025-12-14

import 'api_client.dart';
import '../models/api_response.dart';
import '../models/project.dart';

class ProjectApi {
  final ApiClient _client;

  ProjectApi(this._client);

  /// 创建项目
  Future<ApiResponse<Project>> createProject({
    required String name,
    String? description,
  }) async {
    return await _client.post<Project>(
      '/api/v1/projects',
      data: {
        'name': name,
        if (description != null) 'description': description,
      },
      fromJson: (data) => Project.fromJson(data),
    );
  }

  /// 获取项目列表
  Future<ApiResponse<PagedResponse<Project>>> getProjectList({
    int page = 1,
    int size = 20,
  }) async {
    return await _client.get<PagedResponse<Project>>(
      '/api/v1/projects',
      queryParameters: {
        'page': page,
        'size': size,
      },
      fromJson: (data) => PagedResponse.fromJson(
        data,
        (json) => Project.fromJson(json),
      ),
    );
  }

  /// 获取项目详情
  Future<ApiResponse<Project>> getProject(String projectId) async {
    return await _client.get<Project>(
      '/api/v1/projects/$projectId',
      fromJson: (data) => Project.fromJson(data),
    );
  }

  /// 更新项目
  Future<ApiResponse<Project>> updateProject({
    required String projectId,
    String? name,
    String? description,
  }) async {
    return await _client.put<Project>(
      '/api/v1/projects/$projectId',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      },
      fromJson: (data) => Project.fromJson(data),
    );
  }

  /// 删除项目
  Future<ApiResponse<void>> deleteProject(String projectId) async {
    return await _client.delete<void>(
      '/api/v1/projects/$projectId',
    );
  }
}
