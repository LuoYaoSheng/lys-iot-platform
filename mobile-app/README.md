# IoT 配网 App

> IoT 平台配网工具 - 通过蓝牙为设备配置 WiFi 和 MQTT

---

## 📱 App 简介

这是一个**通用的 IoT 配网应用**，用于：
1. 扫描附近的蓝牙设备（ESP32）
2. 通过蓝牙给设备配置 WiFi 信息
3. 配置设备连接到你的 IoT 平台
4. 查看和控制已配置的设备

---

## ✨ 核心特性

- ✅ **通用版本** - 不写死服务器地址，支持任意 IoT 平台
- ✅ **蓝牙配网** - 通过 BLE 配置设备 WiFi
- ✅ **设备管理** - 查看设备列表和状态
- ✅ **设备控制** - 远程控制设备开关
- ✅ **用户认证** - 登录/注册功能

---

## 🎯 使用场景

### 场景 1: 团队成员使用（生产环境）

**前提**: 你已经在服务器上部署了 IoT 平台（`117.50.216.173`）

**步骤**:
1. 安装并打开 App
2. 首次使用点击"设置服务器地址"
3. 填写配置:
   ```
   API 服务器地址: http://117.50.216.173:48080
   MQTT 服务器地址: 117.50.216.173
   ```
4. 重启 App
5. 注册账号并登录
6. 开始配网和控制设备

---

### 场景 2: 本地开发调试

**前提**: 本地运行了 `iot-platform-core` 后端服务

**步骤**:
1. 启动本地后端服务（Docker 或 直接运行）
2. 打开 App，设置服务器地址:
   ```
   API 服务器地址: http://192.168.x.x:48080  (你的电脑IP)
   MQTT 服务器地址: 192.168.x.x
   ```
3. 重启 App，注册并登录

---

### 场景 3: 使用 natapp 内网穿透（真机调试）

**步骤**:
1. 配置 natapp 隧道
2. 在 App 中设置:
   ```
   API 服务器地址: http://your-natapp-url:48080
   MQTT 服务器地址: your-natapp-mqtt-host
   ```

---

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode (用于编译)

### 安装依赖

```bash
cd mobile-app
flutter pub get
```

### 运行 App

```bash
# 运行到 Android 真机/模拟器
flutter run

# 运行到 iOS 模拟器（需要 macOS）
flutter run -d iPhone
```

### 构建 APK（Android）

```bash
# Debug 版本
flutter build apk

# Release 版本
flutter build apk --release

# 生成的文件位置:
# build/app/outputs/flutter-apk/app-release.apk
```

### 构建 iOS App

```bash
flutter build ios --release

# 需要在 Xcode 中打开项目并签名后才能安装到真机
```

---

## 🔧 配置说明

### 1. 服务器地址配置

App 支持动态配置服务器地址，**不需要修改代码**。

在登录页面点击"设置服务器地址"按钮，填写：

| 配置项 | 说明 | 示例 |
|--------|------|------|
| API 服务器地址 | IoT 平台后端地址 | `http://117.50.216.173:48080` |
| MQTT 服务器地址 | MQTT Broker 地址 | `117.50.216.173` |

**注意**: 修改后需要重启 App 才能生效。

---

### 2. 使用公共库（iot-libs-common）

App 引用了 `iot-libs-common/flutter-sdk`，提供了统一的 API 和 MQTT 客户端。

在 `pubspec.yaml` 中：

```yaml
dependencies:
  iot_platform_sdk:
    git:
      url: https://gitee.com/你的用户名/iot-libs-common.git
      path: flutter-sdk
      ref: main
```

如果公共库有更新，运行：

```bash
flutter pub upgrade
```

---

## 📦 项目结构

```
lib/
├── main.dart                  # 入口文件
├── models/                    # 数据模型
│   └── device.dart
├── pages/                     # 页面
│   ├── splash_page.dart       # 启动页
│   ├── login_page.dart        # 登录页（含服务器配置）
│   ├── register_page.dart     # 注册页
│   ├── scan_page.dart         # 蓝牙扫描页
│   ├── config_page.dart       # WiFi 配网页
│   ├── device_list_page.dart  # 设备列表
│   └── control_page.dart      # 设备控制页
├── services/                  # 服务层
│   ├── api_service.dart       # API 调用
│   └── ble_service.dart       # 蓝牙服务
└── providers/                 # 状态管理
    └── device_provider.dart
```

---

## 🎨 功能说明

### 1. 蓝牙配网流程

1. **扫描设备**: 扫描附近的 ESP32 蓝牙设备
2. **连接设备**: 选择设备并建立蓝牙连接
3. **配置 WiFi**: 输入 WiFi SSID 和密码
4. **配置 MQTT**: App 自动填入服务器地址和端口
5. **发送配置**: 通过蓝牙发送配置到设备
6. **完成配网**: 设备自动连接 WiFi 和 MQTT

---

### 2. 设备控制

- 查看设备列表
- 查看设备在线状态
- 控制设备开关
- 实时同步设备状态

---

## 🔗 依赖说明

### 核心依赖

| 包名 | 用途 |
|------|------|
| `iot_platform_sdk` | IoT 平台 SDK（来自公共库） |
| `flutter_blue_plus` | 蓝牙通信 |
| `shared_preferences` | 本地存储 |
| `provider` | 状态管理 |
| `permission_handler` | 权限管理 |

---

## ❓ 常见问题

### 1. 如何修改服务器地址？

在登录页面点击"设置服务器地址"，填写你的服务器信息，重启 App 即可。

### 2. 公共库更新后如何同步？

```bash
flutter pub upgrade
```

### 3. 蓝牙扫描不到设备？

- 确保设备已开启蓝牙广播
- 检查 App 是否获得了蓝牙和定位权限
- Android 需要开启定位服务

### 4. 配网失败？

- 确保 WiFi 密码正确
- 确保设备可以连接到该 WiFi
- 确保 MQTT 服务器地址填写正确

---

## 📚 相关仓库

- [iot-platform-core](../iot-platform-core/) - 核心后端服务
- [iot-libs-common](../iot-libs-common/) - 公共基础库（包含 Flutter SDK）
- [iot-device/firmware-switch](../iot-device/firmware-switch/) - ESP32 固件

---

## 📄 许可证

MIT License

---

**作者**: 罗耀生
**创建时间**: 2025-12-13
**最后更新**: 2025-12-18
