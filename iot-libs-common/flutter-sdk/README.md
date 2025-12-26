# IoT Platform Flutter SDK

IoT 平台 Flutter SDK，提供设备连接、数据上报、命令下发等功能。

**作者**: 罗耀生
**日期**: 2025-12-14

## 功能特性

- ✅ 用户认证 (登录/注册)
- ✅ 项目管理 (CRUD)
- ✅ 设备管理 (激活/绑定/列表)
- ✅ MQTT 实时连接
- ✅ 属性上报与查询
- ✅ 服务调用与响应
- ✅ 自动重连机制

## 安装

```yaml
dependencies:
  iot_platform_sdk:
    path: ../iot-libs-common/flutter-sdk
```

或发布到私有仓库后：

```yaml
dependencies:
  iot_platform_sdk: ^1.0.0
```

## 快速开始

### 1. 初始化 SDK

```dart
import 'package:iot_platform_sdk/iot_platform_sdk.dart';

void main() async {
  // 开发环境
  final sdk = IoTSdk(config: IoTConfig.development());

  // 生产环境
  // final sdk = IoTSdk(config: IoTConfig.production(
  //   apiBaseUrl: 'https://api.yourserver.com',
  //   mqttHost: 'mqtt.yourserver.com',
  // ));

  // 恢复之前的登录状态
  await sdk.initialize();

  runApp(MyApp());
}
```

### 2. 用户登录

```dart
final success = await sdk.login(
  username: 'user@example.com',
  password: 'password123',
);

if (success) {
  print('登录成功: ${sdk.currentUser?.username}');
}
```

### 3. 获取设备列表

```dart
final result = await sdk.device.getDeviceList();
if (result.isSuccess) {
  final devices = result.data!.list;
  for (final device in devices) {
    print('设备: ${device.deviceId} - ${device.status.value}');
  }
}
```

### 4. 激活设备

```dart
final result = await sdk.device.activateDevice(
  productKey: 'your_product_key',
  deviceSN: 'device_serial_number',
  name: '我的设备',
);

if (result.isSuccess) {
  final device = result.data!;
  print('设备激活成功: ${device.deviceId}');
}
```

### 5. MQTT 连接与属性上报

```dart
// 连接设备
await sdk.connectDevice(device);

// 监听消息
sdk.mqtt?.messageStream.listen((message) {
  print('收到消息: ${message.topic}');
  print('内容: ${message.payload}');
});

// 上报属性
sdk.mqtt?.reportProperty({
  'temperature': 25.5,
  'humidity': 60,
});

// 调用服务
final reply = await sdk.mqtt?.callService(
  'reboot',
  {'delay': 5},
);
print('服务响应: ${reply?.code}');
```

### 6. 获取设备属性

```dart
final result = await sdk.device.getDeviceProperties(device.deviceId);
if (result.isSuccess) {
  final properties = result.data!;
  properties.forEach((key, prop) {
    print('$key: ${prop.value} (${prop.reportedAt})');
  });
}
```

## API 参考

### IoTSdk

| 方法 | 说明 |
|------|------|
| `initialize()` | 初始化 SDK，恢复登录状态 |
| `login(username, password)` | 用户登录 |
| `logout()` | 退出登录 |
| `connectDevice(device)` | 连接设备 MQTT |
| `disconnectDevice()` | 断开设备 MQTT |

### AuthApi

| 方法 | 说明 |
|------|------|
| `login(username, password)` | 登录 |
| `register(username, password, ...)` | 注册 |
| `getCurrentUser()` | 获取当前用户 |
| `updateProfile(...)` | 更新资料 |
| `changePassword(...)` | 修改密码 |

### DeviceApi

| 方法 | 说明 |
|------|------|
| `activateDevice(productKey, deviceSN)` | 激活设备 |
| `getDeviceList(...)` | 获取设备列表 |
| `getDevice(deviceId)` | 获取设备详情 |
| `getDeviceProperties(deviceId)` | 获取设备属性 |
| `getDeviceEvents(deviceId)` | 获取设备事件 |
| `sendCommand(deviceId, command, params)` | 发送命令 |

### IoTMqttClient

| 方法 | 说明 |
|------|------|
| `connect()` | 连接 MQTT |
| `disconnect()` | 断开连接 |
| `subscribe(topic)` | 订阅 Topic |
| `publish(topic, payload)` | 发布消息 |
| `reportProperty(properties)` | 上报属性 |
| `callService(serviceId, params)` | 调用服务 |

## 数据模型

### Device

```dart
class Device {
  String deviceId;       // 设备ID
  String deviceSN;       // 设备序列号
  String productKey;     // 产品Key
  String? projectId;     // 项目ID
  String? name;          // 设备名称
  DeviceStatus status;   // 状态: inactive/online/offline/disabled
  DateTime? lastOnlineAt;// 最后在线时间
}
```

### DeviceProperty

```dart
class DeviceProperty {
  String propertyId;     // 属性ID
  dynamic value;         // 属性值
  DateTime reportedAt;   // 上报时间
}
```

## 注意事项

1. **Token 管理**: SDK 会自动保存和恢复登录 Token
2. **MQTT 重连**: 内置自动重连机制，断线后会自动尝试重连
3. **错误处理**: 所有 API 返回 `ApiResponse`，通过 `isSuccess` 判断是否成功

## License

MIT
