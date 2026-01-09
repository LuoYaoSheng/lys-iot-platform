/// 产品模型
/// 作者: 罗耀生
/// 日期: 2025-12-14
/// 更新: 2025-12-19 - v0.2.0 添加控制模式、UI模板、图标等字段

import 'package:equatable/equatable.dart';
import 'dart:convert';

/// 控制模式枚举
enum ControlMode {
  toggle,    // 开关切换
  pulse,     // 脉冲触发
  dimmer,    // 调光调色
  readonly,  // 只读显示
  generic,   // 通用模式
}

extension ControlModeExt on ControlMode {
  String get value {
    return toString().split('.').last;
  }

  static ControlMode fromString(String value) {
    switch (value) {
      case 'toggle':
        return ControlMode.toggle;
      case 'pulse':
        return ControlMode.pulse;
      case 'dimmer':
        return ControlMode.dimmer;
      case 'readonly':
        return ControlMode.readonly;
      case 'generic':
        return ControlMode.generic;
      default:
        return ControlMode.generic;
    }
  }
}

class Product extends Equatable {
  final String productKey;
  final String name;
  final String? description;
  final String category;

  // v0.2.0 新增字段
  final String? controlMode;        // 控制模式: toggle/pulse/dimmer/readonly/generic
  final String? uiTemplate;         // UI模板名称
  final String? iconName;           // 图标名称(Material Icons)
  final String? iconColor;          // 图标颜色(HEX)
  final Map<String, dynamic>? capabilities; // 产品能力定义
  final Map<String, dynamic>? mqttTopics;   // MQTT主题配置
  final String? manufacturer;       // 制造商
  final String? model;              // 硬件型号

  // 原有字段
  final String nodeType;
  final String? dataFormat;
  final String? protocol;
  final int status;
  final int deviceCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.productKey,
    required this.name,
    this.description,
    required this.category,

    // v0.2.0 新增参数
    this.controlMode,
    this.uiTemplate,
    this.iconName,
    this.iconColor,
    this.capabilities,
    this.mqttTopics,
    this.manufacturer,
    this.model,

    // 原有参数
    this.nodeType = 'device',
    this.dataFormat,
    this.protocol,
    this.status = 1,
    this.deviceCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// 获取控制模式枚举
  ControlMode get controlModeEnum {
    if (controlMode == null) return ControlMode.generic;
    return ControlModeExt.fromString(controlMode!);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // 安全解析字符串字段
    String? safeString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value.isEmpty ? null : value;
      return value.toString();
    }

    // 安全解析 capabilities
    Map<String, dynamic>? parseCapabilities(dynamic value) {
      if (value == null || value == '') return null;
      if (value is Map) return value as Map<String, dynamic>;
      if (value is String && value.isNotEmpty) {
        try {
          return jsonDecode(value) as Map<String, dynamic>;
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // 安全解析 mqttTopics
    Map<String, dynamic>? parseMqttTopics(dynamic value) {
      if (value == null || value == '') return null;
      if (value is Map) return value as Map<String, dynamic>;
      if (value is String && value.isNotEmpty) {
        try {
          return jsonDecode(value) as Map<String, dynamic>;
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return Product(
      productKey: safeString(json['productKey']) ?? '',
      name: safeString(json['name']) ?? '',
      description: safeString(json['description']),
      category: safeString(json['category']) ?? '',

      // v0.2.0 新增字段解析
      controlMode: safeString(json['controlMode']),
      uiTemplate: safeString(json['uiTemplate']),
      iconName: safeString(json['iconName']),
      iconColor: safeString(json['iconColor']),
      capabilities: parseCapabilities(json['capabilities']),
      mqttTopics: parseMqttTopics(json['mqttTopics']),
      manufacturer: safeString(json['manufacturer']),
      model: safeString(json['model']),

      // 原有字段
      nodeType: safeString(json['nodeType']) ?? 'device',
      dataFormat: safeString(json['dataFormat']),
      protocol: safeString(json['protocol']),
      status: json['status'] is int ? json['status'] as int : (int.tryParse(json['status']?.toString() ?? '') ?? 1),
      deviceCount: json['deviceCount'] is int ? json['deviceCount'] as int : (int.tryParse(json['deviceCount']?.toString() ?? '') ?? 0),
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
      'productKey': productKey,
      'name': name,
      if (description != null) 'description': description,
      'category': category,

      // v0.2.0 新增字段
      if (controlMode != null) 'controlMode': controlMode,
      if (uiTemplate != null) 'uiTemplate': uiTemplate,
      if (iconName != null) 'iconName': iconName,
      if (iconColor != null) 'iconColor': iconColor,
      if (capabilities != null) 'capabilities': capabilities,
      if (mqttTopics != null) 'mqttTopics': mqttTopics,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,

      // 原有字段
      'nodeType': nodeType,
      if (dataFormat != null) 'dataFormat': dataFormat,
      if (protocol != null) 'protocol': protocol,
      'status': status,
      'deviceCount': deviceCount,
    };
  }

  @override
  List<Object?> get props => [
    productKey, name, category,
    controlMode, uiTemplate, iconName, iconColor, // v0.2.0
    nodeType, status,
  ];
}
