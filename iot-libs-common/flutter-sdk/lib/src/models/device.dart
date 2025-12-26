/// 设备模型
/// 作者: 罗耀生
/// 日期: 2025-12-14
/// 更新: 2025-12-19 - v0.2.0 添加产品信息字段

import 'package:equatable/equatable.dart';
import 'product.dart';

/// 设备状态枚举
enum DeviceStatus {
  inactive,   // 未激活
  online,     // 在线
  offline,    // 离线
  disabled,   // 已禁用
}

extension DeviceStatusExt on DeviceStatus {
  String get value {
    switch (this) {
      case DeviceStatus.inactive:
        return 'inactive';
      case DeviceStatus.online:
        return 'online';
      case DeviceStatus.offline:
        return 'offline';
      case DeviceStatus.disabled:
        return 'disabled';
    }
  }

  static DeviceStatus fromString(String value) {
    switch (value) {
      case 'online':
        return DeviceStatus.online;
      case 'offline':
        return DeviceStatus.offline;
      case 'disabled':
        return DeviceStatus.disabled;
      default:
        return DeviceStatus.inactive;
    }
  }
}

class Device extends Equatable {
  final String deviceId;
  final String deviceSN;
  final String productKey;
  final String? projectId;
  final String? name;
  final DeviceStatus status;
  final String? mqttUsername;
  final String? mqttPassword;
  final DateTime? lastOnlineAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // v0.2.0 新增字段
  final Product? product;  // 关联的产品信息

  const Device({
    required this.deviceId,
    required this.deviceSN,
    required this.productKey,
    this.projectId,
    this.name,
    this.status = DeviceStatus.inactive,
    this.mqttUsername,
    this.mqttPassword,
    this.lastOnlineAt,
    this.createdAt,
    this.updatedAt,
    this.product,  // v0.2.0
  });

  /// 是否在线
  bool get isOnline => status == DeviceStatus.online;

  /// MQTT Topic 前缀
  String get topicPrefix => '/sys/$productKey/$deviceId';

  /// 属性上报 Topic
  String get propertyPostTopic => '$topicPrefix/thing/event/property/post';

  /// 属性设置 Topic
  String get propertySetTopic => '$topicPrefix/thing/service/property/set';

  /// 命令下发 Topic
  String get commandTopic => '$topicPrefix/thing/service/+';

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceId'] as String,
      deviceSN: json['deviceSN'] as String? ?? json['deviceId'],
      productKey: json['productKey'] as String,
      projectId: json['projectId'] as String?,
      name: json['name'] as String?,
      status: DeviceStatusExt.fromString(json['status'] as String? ?? 'inactive'),
      mqttUsername: json['mqttUsername'] as String?,
      mqttPassword: json['mqttPassword'] as String?,
      lastOnlineAt: json['lastOnlineAt'] != null
          ? DateTime.parse(json['lastOnlineAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      // v0.2.0: 解析产品信息
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceSN': deviceSN,
      'productKey': productKey,
      if (projectId != null) 'projectId': projectId,
      if (name != null) 'name': name,
      'status': status.value,
      if (mqttUsername != null) 'mqttUsername': mqttUsername,
    };
  }

  Device copyWith({
    String? deviceId,
    String? deviceSN,
    String? productKey,
    String? projectId,
    String? name,
    DeviceStatus? status,
    String? mqttUsername,
    String? mqttPassword,
    DateTime? lastOnlineAt,
    Product? product,  // v0.2.0
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      deviceSN: deviceSN ?? this.deviceSN,
      productKey: productKey ?? this.productKey,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      status: status ?? this.status,
      mqttUsername: mqttUsername ?? this.mqttUsername,
      mqttPassword: mqttPassword ?? this.mqttPassword,
      lastOnlineAt: lastOnlineAt ?? this.lastOnlineAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      product: product ?? this.product,  // v0.2.0
    );
  }

  @override
  List<Object?> get props => [
    deviceId, deviceSN, productKey, projectId, name, status,
    product,  // v0.2.0
  ];
}

/// 设备属性
class DeviceProperty {
  final String propertyId;
  final dynamic value;
  final DateTime reportedAt;

  const DeviceProperty({
    required this.propertyId,
    required this.value,
    required this.reportedAt,
  });

  factory DeviceProperty.fromJson(Map<String, dynamic> json) {
    return DeviceProperty(
      propertyId: json['propertyId'] as String,
      value: json['value'],
      reportedAt: DateTime.parse(json['reportedAt']),
    );
  }
}

/// 设备事件
class DeviceEvent {
  final int id;
  final String deviceId;
  final String eventType;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  const DeviceEvent({
    required this.id,
    required this.deviceId,
    required this.eventType,
    required this.payload,
    required this.createdAt,
  });

  factory DeviceEvent.fromJson(Map<String, dynamic> json) {
    return DeviceEvent(
      id: json['id'] as int,
      deviceId: json['deviceId'] as String,
      eventType: json['eventType'] as String,
      payload: json['payload'] is String
          ? {}
          : json['payload'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
