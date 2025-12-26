/// 设备 API
/// 作者: 罗耀生
/// 日期: 2025-12-14

import 'api_client.dart';
import '../models/api_response.dart';
import '../models/device.dart';

class DeviceApi {
  final ApiClient _client;

  DeviceApi(this._client);

  /// 激活设备 (设备绑定)
  Future<ApiResponse<Device>> activateDevice({
    required String productKey,
    required String deviceSN,
    String? projectId,
    String? name,
  }) async {
    return await _client.post<Device>(
      '/api/v1/devices/activate',
      data: {
        'productKey': productKey,
        'deviceSN': deviceSN,
        if (projectId != null) 'projectId': projectId,
        if (name != null) 'name': name,
      },
      fromJson: (data) => Device.fromJson(data),
    );
  }

  /// 获取设备列表
  Future<ApiResponse<PagedResponse<Device>>> getDeviceList({
    String? productKey,
    String? projectId,
    DeviceStatus? status,
    int page = 1,
    int size = 20,
  }) async {
    return await _client.get<PagedResponse<Device>>(
      '/api/v1/devices',
      queryParameters: {
        if (productKey != null) 'productKey': productKey,
        if (projectId != null) 'projectId': projectId,
        if (status != null) 'status': status.value,
        'page': page,
        'size': size,
      },
      fromJson: (data) => PagedResponse.fromJson(
        data,
        (json) => Device.fromJson(json),
      ),
    );
  }

  /// 获取设备详情
  Future<ApiResponse<Device>> getDevice(String deviceId) async {
    return await _client.get<Device>(
      '/api/v1/devices/$deviceId',
      fromJson: (data) => Device.fromJson(data),
    );
  }

  /// 更新设备信息
  Future<ApiResponse<Device>> updateDevice({
    required String deviceId,
    String? name,
    String? projectId,
  }) async {
    return await _client.put<Device>(
      '/api/v1/devices/$deviceId',
      data: {
        if (name != null) 'name': name,
        if (projectId != null) 'projectId': projectId,
      },
      fromJson: (data) => Device.fromJson(data),
    );
  }

  /// 获取设备属性
  Future<ApiResponse<Map<String, DeviceProperty>>> getDeviceProperties(
    String deviceId,
  ) async {
    return await _client.get<Map<String, DeviceProperty>>(
      '/api/v1/devices/$deviceId/properties',
      fromJson: (data) {
        final map = <String, DeviceProperty>{};
        if (data is Map) {
          data.forEach((key, value) {
            map[key as String] = DeviceProperty(
              propertyId: key,
              value: value['value'],
              reportedAt: DateTime.parse(value['reportedAt']),
            );
          });
        }
        return map;
      },
    );
  }

  /// 获取设备事件列表
  Future<ApiResponse<List<DeviceEvent>>> getDeviceEvents(
    String deviceId, {
    int limit = 50,
  }) async {
    return await _client.get<List<DeviceEvent>>(
      '/api/v1/devices/$deviceId/events',
      queryParameters: {'limit': limit},
      fromJson: (data) => (data as List)
          .map((json) => DeviceEvent.fromJson(json))
          .toList(),
    );
  }

  /// 发送设备命令
  Future<ApiResponse<void>> sendCommand({
    required String deviceId,
    required String command,
    Map<String, dynamic>? params,
  }) async {
    return await _client.post<void>(
      '/api/v1/devices/$deviceId/commands',
      data: {
        'command': command,
        if (params != null) 'params': params,
      },
    );
  }

  /// 设置设备属性（通过控制接口）
  Future<ApiResponse<void>> setProperty({
    required String deviceId,
    required String propertyId,
    required dynamic value,
  }) async {
    return await _client.post<void>(
      '/api/v1/devices/$deviceId/control',
      data: {
        propertyId: value,
      },
    );
  }


  /// 删除设备
  Future<ApiResponse<void>> deleteDevice(String deviceId) async {
    return await _client.delete<void>(
      '/api/v1/devices/$deviceId',
    );
  }
}
