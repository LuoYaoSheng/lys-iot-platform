/// IoT 消息模型
/// 作者: 罗耀生
/// 日期: 2025-12-14

import 'dart:convert';

/// IoT 消息类型
enum IoTMessageType {
  propertyReport,    // 属性上报
  propertySet,       // 属性设置
  eventReport,       // 事件上报
  serviceCall,       // 服务调用
  serviceReply,      // 服务响应
  unknown,
}

/// IoT 消息
class IoTMessage {
  final String topic;
  final String payload;
  final int qos;
  final DateTime timestamp;

  const IoTMessage({
    required this.topic,
    required this.payload,
    this.qos = 0,
    required this.timestamp,
  });

  /// 解析 payload 为 JSON
  Map<String, dynamic>? get jsonPayload {
    try {
      return json.decode(payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// 获取消息类型
  IoTMessageType get messageType {
    if (topic.contains('/thing/event/property/post')) {
      return IoTMessageType.propertyReport;
    } else if (topic.contains('/thing/service/property/set')) {
      return IoTMessageType.propertySet;
    } else if (topic.contains('/thing/event/')) {
      return IoTMessageType.eventReport;
    } else if (topic.contains('/thing/service/') && topic.endsWith('_reply')) {
      return IoTMessageType.serviceReply;
    } else if (topic.contains('/thing/service/')) {
      return IoTMessageType.serviceCall;
    }
    return IoTMessageType.unknown;
  }

  /// 从 topic 提取 productKey
  String? get productKey {
    final parts = topic.split('/');
    if (parts.length > 2) {
      return parts[2];
    }
    return null;
  }

  /// 从 topic 提取 deviceId
  String? get deviceId {
    final parts = topic.split('/');
    if (parts.length > 3) {
      return parts[3];
    }
    return null;
  }

  @override
  String toString() => 'IoTMessage(topic: $topic, payload: $payload)';
}

/// 属性上报消息
class PropertyReportMessage {
  final String id;
  final String version;
  final Map<String, dynamic> params;
  final int timestamp;

  const PropertyReportMessage({
    required this.id,
    this.version = '1.0',
    required this.params,
    required this.timestamp,
  });

  factory PropertyReportMessage.fromJson(Map<String, dynamic> json) {
    return PropertyReportMessage(
      id: json['id'] as String? ?? '',
      version: json['version'] as String? ?? '1.0',
      params: json['params'] as Map<String, dynamic>? ?? {},
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'params': params,
      'timestamp': timestamp,
    };
  }

  /// 构建属性上报消息
  factory PropertyReportMessage.create(Map<String, dynamic> properties) {
    return PropertyReportMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      params: properties,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

/// 服务调用消息
class ServiceCallMessage {
  final String id;
  final String version;
  final String method;
  final Map<String, dynamic> params;

  const ServiceCallMessage({
    required this.id,
    this.version = '1.0',
    required this.method,
    required this.params,
  });

  factory ServiceCallMessage.fromJson(Map<String, dynamic> json) {
    return ServiceCallMessage(
      id: json['id'] as String? ?? '',
      version: json['version'] as String? ?? '1.0',
      method: json['method'] as String? ?? '',
      params: json['params'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'method': method,
      'params': params,
    };
  }
}

/// 服务响应消息
class ServiceReplyMessage {
  final String id;
  final int code;
  final Map<String, dynamic> data;

  const ServiceReplyMessage({
    required this.id,
    required this.code,
    required this.data,
  });

  factory ServiceReplyMessage.fromJson(Map<String, dynamic> json) {
    return ServiceReplyMessage(
      id: json['id'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'data': data,
    };
  }

  bool get isSuccess => code == 200;
}
