/// 设备数据模型
/// 作者: 罗耀生
/// 日期: 2025-12-13
/// 更新: 2026-01-07 - 兼容服务端字段名 (deviceSN) 和状态字符串类型

class Device {
  final String deviceId;
  final String deviceSn;
  final String productKey;
  final String name;
  final int status;
  final String statusText;
  final String? firmwareVersion;
  final String? chipModel;
  final String? lastOnlineAt;
  final String? activatedAt;
  final String createdAt;

  Device({
    required this.deviceId,
    required this.deviceSn,
    required this.productKey,
    required this.name,
    required this.status,
    required this.statusText,
    this.firmwareVersion,
    this.chipModel,
    this.lastOnlineAt,
    this.activatedAt,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    // 兼容服务端返回的字段名（deviceSN）和APP期望的字段名
    final String deviceSn = json['deviceSn'] ?? json['deviceSN'] ?? '';

    // status 兼容字符串和整数类型
    // 服务端返回: "online"/"offline"/"inactive"/"disabled"
    // APP内部使用: 1/2/0/3
    int status = 0;
    final statusValue = json['status'];
    if (statusValue is int) {
      status = statusValue;
    } else if (statusValue is String) {
      switch (statusValue.toLowerCase()) {
        case 'online':
          status = 1;
          break;
        case 'offline':
          status = 2;
          break;
        case 'disabled':
          status = 3;
          break;
        default:
          status = 0;
      }
    }

    return Device(
      deviceId: json['deviceId'] ?? '',
      deviceSn: deviceSn,
      productKey: json['productKey'] ?? '',
      name: json['name'] ?? '',
      status: status,
      statusText: json['statusText'] ?? '未知',
      firmwareVersion: json['firmwareVersion'],
      chipModel: json['chipModel'],
      lastOnlineAt: json['lastOnlineAt'],
      activatedAt: json['activatedAt'],
      createdAt: json['createdAt'] ?? '',
    );
  }

  bool get isOnline => status == 1;
  bool get isOffline => status == 2;
  bool get isDisabled => status == 3;
}

/// BLE 扫描到的设备
class BleDevice {
  final String id;
  final String name;
  final int rssi;

  BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });
}

/// 配网状态
enum ConfigStatus {
  idle,
  connecting,
  sendingConfig,
  waitingWifi,
  wifiConnected,
  activating,
  activated,
  error,
}

extension ConfigStatusExtension on ConfigStatus {
  String get text {
    switch (this) {
      case ConfigStatus.idle:
        return '等待配网';
      case ConfigStatus.connecting:
        return '正在连接设备...';
      case ConfigStatus.sendingConfig:
        return '正在发送WiFi配置...';
      case ConfigStatus.waitingWifi:
        return '设备正在连接WiFi...';
      case ConfigStatus.wifiConnected:
        return 'WiFi连接成功，正在激活...';
      case ConfigStatus.activating:
        return '正在激活设备...';
      case ConfigStatus.activated:
        return '配网成功！';
      case ConfigStatus.error:
        return '配网失败';
    }
  }
}
