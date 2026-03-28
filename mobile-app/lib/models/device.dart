// 设备数据模型
// 作者: 罗耀生
// 日期: 2025-12-13

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
    return Device(
      deviceId: json['deviceId'] ?? '',
      deviceSn: json['deviceSn'] ?? '',
      productKey: json['productKey'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 0,
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
