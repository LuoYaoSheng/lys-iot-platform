/// 设备相关模型
/// 作者: 罗耀生

/// 设备类型枚举
enum DeviceType {
  servo('舵机开关'),
  wakeup('USB唤醒');

  final String label;
  const DeviceType(this.label);

  static DeviceType fromString(String? value) {
    switch (value) {
      case 'servo':
        return DeviceType.servo;
      case 'wakeup':
        return DeviceType.wakeup;
      default:
        return DeviceType.servo;
    }
  }
}

/// 设备状态枚举
enum DeviceStatusCode {
  notActivated(0, '未激活'),
  online(1, '在线'),
  offline(2, '离线'),
  disabled(3, '禁用');

  final int code;
  final String label;
  const DeviceStatusCode(this.code, this.label);

  static DeviceStatusCode fromCode(int? code) {
    switch (code) {
      case 0:
        return DeviceStatusCode.notActivated;
      case 1:
        return DeviceStatusCode.online;
      case 2:
        return DeviceStatusCode.offline;
      case 3:
        return DeviceStatusCode.disabled;
      default:
        return DeviceStatusCode.offline;
    }
  }

  static DeviceStatusCode fromString(String? status) {
    switch (status) {
      case 'online':
        return DeviceStatusCode.online;
      case 'offline':
        return DeviceStatusCode.offline;
      case 'not_activated':
        return DeviceStatusCode.notActivated;
      case 'disabled':
        return DeviceStatusCode.disabled;
      default:
        return DeviceStatusCode.offline;
    }
  }
}

/// 产品信息
class ProductInfo {
  final int? productId;
  final String? productKey;
  final String? name;
  final String? description;
  final String? category;
  final String? controlMode;
  final String? uiTemplate;
  final String? iconName;
  final String? iconColor;
  final String? manufacturer;
  final String? model;

  ProductInfo({
    this.productId,
    this.productKey,
    this.name,
    this.description,
    this.category,
    this.controlMode,
    this.uiTemplate,
    this.iconName,
    this.iconColor,
    this.manufacturer,
    this.model,
  });

  factory ProductInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProductInfo();
    return ProductInfo(
      productId: json['productId'] as int?,
      productKey: json['productKey'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      controlMode: json['controlMode'] as String?,
      uiTemplate: json['uiTemplate'] as String?,
      iconName: json['iconName'] as String?,
      iconColor: json['iconColor'] as String?,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productKey': productKey,
      'name': name,
      'description': description,
      'category': category,
      'controlMode': controlMode,
      'uiTemplate': uiTemplate,
      'iconName': iconName,
      'iconColor': iconColor,
      'manufacturer': manufacturer,
      'model': model,
    };
  }

  /// 根据产品信息判断设备类型
  DeviceType get deviceType {
    if (productKey?.contains('wakeup') == true || uiTemplate == 'wakeup') {
      return DeviceType.wakeup;
    }
    return DeviceType.servo;
  }
}

/// 设备模型
class Device {
  final String deviceId;
  final String? deviceSn;
  final String? productKey;
  final String? projectId;
  final String name;
  final DeviceStatusCode status;
  final String? statusText;
  final String? firmwareVersion;
  final String? chipModel;
  final DateTime? lastOnlineAt;
  final DateTime? activatedAt;
  final DateTime? createdAt;
  final ProductInfo? product;

  // 本地扩展字段
  String? _location; // 位置信息，如"上"/"下"

  Device({
    required this.deviceId,
    this.deviceSn,
    this.productKey,
    this.projectId,
    required this.name,
    required this.status,
    this.statusText,
    this.firmwareVersion,
    this.chipModel,
    this.lastOnlineAt,
    this.activatedAt,
    this.createdAt,
    this.product,
    String? location,
  }) : _location = location;

  factory Device.fromJson(Map<String, dynamic> json) {
    final statusValue = json['status'];
    DeviceStatusCode statusCode;
    if (statusValue is int) {
      statusCode = DeviceStatusCode.fromCode(statusValue);
    } else if (statusValue is String) {
      statusCode = DeviceStatusCode.fromString(statusValue);
    } else {
      statusCode = DeviceStatusCode.offline;
    }

    final nameValue = (json['name'] as String? ?? '').trim();
    return Device(
      deviceId: json['deviceId'] as String? ?? json['id'] as String? ?? '',
      deviceSn: json['deviceSN'] as String? ?? json['deviceSn'] as String?,
      productKey: json['productKey'] as String?,
      projectId: json['projectId'] as String?,
      name: nameValue.isEmpty ? '未知设备' : nameValue,
      status: statusCode,
      statusText: json['statusText'] as String?,
      firmwareVersion: json['firmwareVersion'] as String? ?? json['firmware'] as String?,
      chipModel: json['chipModel'] as String?,
      lastOnlineAt: json['lastOnlineAt'] != null
          ? DateTime.tryParse(json['lastOnlineAt'] as String)
          : null,
      activatedAt: json['activatedAt'] != null
          ? DateTime.tryParse(json['activatedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      product: json['product'] != null
          ? ProductInfo.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceSN': deviceSn,
      'productKey': productKey,
      'projectId': projectId,
      'name': name,
      'status': status.code,
      'statusText': statusText,
      'firmwareVersion': firmwareVersion,
      'chipModel': chipModel,
      'lastOnlineAt': lastOnlineAt?.toIso8601String(),
      'activatedAt': activatedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'product': product?.toJson(),
    };
  }

  /// 是否在线
  bool get isOnline => status == DeviceStatusCode.online;

  /// 设备类型（根据产品信息推断）
  DeviceType get deviceType => product?.deviceType ?? DeviceType.servo;

  /// 型号信息
  String? get model => product?.model ?? chipModel;

  /// 位置信息（本地存储）
  String? get location => _location;
  set location(String? value) => _location = value;

  /// 获取状态文本
  String get displayStatus {
    if (statusText != null) return statusText!;
    return status.label;
  }

  /// 获取显示名称（处理空值）
  String get displayName => name.isEmpty ? '未知设备' : name;

  /// 获取离线时长文本
  String get offlineText {
    if (isOnline || lastOnlineAt == null) return displayStatus;

    final diff = DateTime.now().difference(lastOnlineAt!);
    if (diff.inHours > 0) {
      return '离线 ${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '离线 ${diff.inMinutes}分钟前';
    } else {
      return '离线 刚刚';
    }
  }

  Device copyWith({
    String? deviceId,
    String? deviceSn,
    String? productKey,
    String? projectId,
    String? name,
    DeviceStatusCode? status,
    String? statusText,
    String? firmwareVersion,
    String? chipModel,
    DateTime? lastOnlineAt,
    DateTime? activatedAt,
    DateTime? createdAt,
    ProductInfo? product,
    String? location,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      deviceSn: deviceSn ?? this.deviceSn,
      productKey: productKey ?? this.productKey,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      chipModel: chipModel ?? this.chipModel,
      lastOnlineAt: lastOnlineAt ?? this.lastOnlineAt,
      activatedAt: activatedAt ?? this.activatedAt,
      createdAt: createdAt ?? this.createdAt,
      product: product ?? this.product,
      location: location ?? _location,
    );
  }
}

/// 设备列表响应
class DeviceListResponse {
  final List<Device> list;
  final int total;
  final int page;
  final int size;

  DeviceListResponse({
    required this.list,
    required this.total,
    required this.page,
    required this.size,
  });

  factory DeviceListResponse.fromJson(Map<String, dynamic> json) {
    final listData = json['list'] as List? ?? [];
    return DeviceListResponse(
      list: listData.map((e) => Device.fromJson(e)).toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'size': size,
    };
  }
}

/// 设备状态响应
class DeviceStatusResponse {
  final String deviceId;
  final String? deviceName;
  final bool online;
  final String? position;
  final String? status;
  final DateTime? lastOnlineAt;

  DeviceStatusResponse({
    required this.deviceId,
    this.deviceName,
    required this.online,
    this.position,
    this.status,
    this.lastOnlineAt,
  });

  factory DeviceStatusResponse.fromJson(Map<String, dynamic> json) {
    return DeviceStatusResponse(
      deviceId: json['deviceId'] as String? ?? '',
      deviceName: json['deviceName'] as String?,
      online: json['online'] as bool? ?? json['status'] == 'online',
      position: json['position'] as String?,
      status: json['status'] as String?,
      lastOnlineAt: json['lastOnlineAt'] != null
          ? DateTime.tryParse(json['lastOnlineAt'] as String)
          : null,
    );
  }
}

/// 控制请求
class ControlRequest {
  final String? action;
  final String? position;
  final int? duration;
  final bool? switchValue;
  final int? angle;

  ControlRequest({
    this.action,
    this.position,
    this.duration,
    this.switchValue,
    this.angle,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    // 新协议
    if (action != null) data['action'] = action;
    if (position != null) data['position'] = position;
    if (duration != null) data['duration'] = duration;

    // 旧协议（兼容）
    if (switchValue != null) data['switch'] = switchValue;
    if (angle != null) data['angle'] = angle;

    return data;
  }

  /// 创建位置切换请求
  factory ControlRequest.toggle(String position) {
    return ControlRequest(
      action: 'toggle',
      position: position,
    );
  }

  /// 创建脉冲触发请求
  factory ControlRequest.pulse(int duration) {
    return ControlRequest(
      action: 'pulse',
      duration: duration,
    );
  }

  /// 创建唤醒请求
  factory ControlRequest.trigger() {
    return ControlRequest(
      action: 'trigger',
    );
  }
}
