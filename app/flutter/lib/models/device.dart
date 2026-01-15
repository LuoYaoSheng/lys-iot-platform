/// 数据模型
/// 作者: 罗耀生
/// 日期: 2026-01-13

/// 设备类型枚举
enum DeviceType {
  servo('舵机开关'),
  wakeup('USB唤醒');

  final String label;
  const DeviceType(this.label);
}

/// 设备状态枚举
enum DeviceStatus {
  online('在线'),
  offline('离线'),
  configuring('配置中');

  final String label;
  const DeviceStatus(this.label);
}

/// 设备模型
class Device {
  String id;
  String name;
  DeviceType type;
  DeviceStatus status;
  String? firmware;
  String? location; // 位置信息，如"上"/"下"
  String? model; // 型号信息，如"USB-WAKEUP-S3"
  DateTime? lastSeen; // 最后在线时间，用于计算离线时长

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.firmware,
    this.location,
    this.model,
    this.lastSeen,
  });

  /// 获取状态文本
  String get statusText {
    switch (status) {
      case DeviceStatus.online:
        return '在线';
      case DeviceStatus.configuring:
        return '配置中';
      case DeviceStatus.offline:
        if (lastSeen != null) {
          final diff = DateTime.now().difference(lastSeen!);
          if (diff.inHours > 0) {
            return '离线 ${diff.inHours}小时前';
          } else if (diff.inMinutes > 0) {
            return '离线 ${diff.inMinutes}分钟前';
          } else {
            return '离线 刚刚';
          }
        }
        return '离线';
    }
  }

  Device copyWith({
    String? id,
    String? name,
    DeviceType? type,
    DeviceStatus? status,
    String? firmware,
    String? location,
    String? model,
    DateTime? lastSeen,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      firmware: firmware ?? this.firmware,
      location: location ?? this.location,
      model: model ?? this.model,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

/// 模拟数据存储
class MockData {
  static final List<Device> _devices = [
    Device(
      id: 'device_001',
      name: '客厅开关',
      type: DeviceType.servo,
      status: DeviceStatus.online,
      firmware: '1.0.0',
      location: '上',
    ),
    Device(
      id: 'device_002',
      name: '电脑唤醒',
      type: DeviceType.wakeup,
      status: DeviceStatus.online,
      firmware: '1.0.0',
      model: 'USB-WAKEUP-S3',
    ),
    Device(
      id: 'device_003',
      name: '卧室开关',
      type: DeviceType.servo,
      status: DeviceStatus.offline,
      firmware: '1.0.0',
      location: '下',
      lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  static List<Device> get devices => List.from(_devices);

  static void addDevice(Device device) {
    _devices.add(device);
  }

  static void removeDevice(String id) {
    _devices.removeWhere((d) => d.id == id);
  }

  static void updateDevice(String id, {String? name, DeviceStatus? status}) {
    final device = _devices.firstWhere((d) => d.id == id);
    if (name != null) device.name = name;
    if (status != null) device.status = status;
  }

  static Device? getDevice(String id) {
    try {
      return _devices.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
