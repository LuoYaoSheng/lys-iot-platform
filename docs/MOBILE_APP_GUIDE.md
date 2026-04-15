# 移动端配网指南

> Open IoT Platform 移动端是一个 Flutter 跨平台应用，提供 BLE 配网、设备列表和远程控制功能。

## App 版本说明

项目中有两个移动端相关目录：

| 目录 | 说明 | 状态 |
|------|------|------|
| `mobile-app/` | Flutter 原生应用（主力版本） | ✅ 活跃开发 |
| `app/` | UniApp + Flutter 补充版本 | 辅助 |

本指南以 `mobile-app/` 为主。

## Flutter 开发环境搭建

### 前置条件

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio（Android 开发）
- Xcode 14+（iOS 开发，需要 macOS）

### 安装 Flutter

```bash
# macOS
brew install --cask flutter

# 验证安装
flutter doctor
```

确保以下项目打勾：
- ✅ Flutter
- ✅ Android toolchain
- ✅ Android Studio
- ✅ Connected device

### 安装依赖

```bash
cd mobile-app
flutter pub get
```

## 核心功能

### 1. BLE 配网

通过蓝牙扫描附近 ESP32 设备，配置 WiFi 信息并完成平台绑定。

**配网流程**：

1. 设备上电进入配网模式（LED 五次快闪）
2. 打开 APP → 点击"添加设备"
3. 扫描蓝牙设备（名称格式：`IoT-Switch-XXXX` 或 `IoT-Wakeup-XXXX`）
4. 选择目标设备 → 建立蓝牙连接
5. 输入 WiFi SSID 和密码
6. APP 通过 BLE 发送配置到设备
7. 设备自动连接 WiFi、注册到平台、连接 MQTT
8. 配网完成，可远程控制

### 2. 设备列表

- 查看所有已绑定设备
- 实时显示在线/离线状态
- 按产品类型分组展示

### 3. 远程控制

- 设备开关控制（Toggle 模式）
- 舵机角度控制
- USB 唤醒触发
- 状态实时同步

## 项目结构

```
mobile-app/
├── lib/
│   ├── main.dart                  # 入口文件
│   ├── models/                    # 数据模型
│   │   └── device.dart
│   ├── pages/                     # 页面
│   │   ├── splash_page.dart       # 启动页
│   │   ├── login_page.dart        # 登录页（含服务器配置）
│   │   ├── register_page.dart     # 注册页
│   │   ├── scan_page.dart         # 蓝牙扫描页
│   │   ├── config_page.dart       # WiFi 配网页
│   │   ├── device_list_page.dart  # 设备列表
│   │   └── control_page.dart      # 设备控制页
│   ├── services/                  # 服务层
│   │   ├── api_service.dart       # API 调用
│   │   └── ble_service.dart       # 蓝牙服务
│   └── providers/                 # 状态管理
│       └── device_provider.dart
├── android/                       # Android 原生配置
├── ios/                           # iOS 原生配置
├── pubspec.yaml                   # 依赖管理
└── analysis_options.yaml          # Lint 规则
```

## API 对接说明

### 服务器地址配置

APP 支持动态配置服务器地址，无需修改代码：

1. 打开 APP → 登录页面右上角服务器图标
2. 填写 API 和 MQTT 地址
3. 保存后重启 APP

| 配置项 | 格式 | 示例 |
|--------|------|------|
| API 服务器地址 | `http://{IP}:{PORT}` | `http://192.168.1.100:48080` |
| MQTT 服务器地址 | `{IP}` 或 `{域名}` | `192.168.1.100` |

### 核心依赖

| 包名 | 用途 |
|------|------|
| `iot_platform_sdk` | IoT 平台 SDK（来自 `iot-libs-common/flutter-sdk`） |
| `flutter_blue_plus` | BLE 蓝牙通信 |
| `shared_preferences` | 本地持久化存储 |
| `provider` | 状态管理 |
| `permission_handler` | 权限管理 |

### 公共库引用

`pubspec.yaml` 中引用共享 SDK：

```yaml
dependencies:
  iot_platform_sdk:
    git:
      url: https://gitee.com/luoyaosheng/iot-libs-common.git
      path: flutter-sdk
      ref: main
```

更新公共库：

```bash
flutter pub upgrade
```

## 开发与构建

### 运行 APP

```bash
# Android 真机/模拟器
flutter run

# iOS 模拟器（需要 macOS）
flutter run -d iPhone

# 指定设备
flutter devices
flutter run -d <device_id>
```

### 构建 APK

```bash
# Debug 版本
flutter build apk

# Release 版本
flutter build apk --release

# 输出位置：build/app/outputs/flutter-apk/app-release.apk
```

### 构建 iOS

```bash
flutter build ios --release
# 需要在 Xcode 中打开项目并签名后才能安装到真机
```

### 代码检查

```bash
# Lint 检查
flutter analyze

# 运行测试
flutter test
```

## 常见问题

### 蓝牙扫描不到设备

- 确保设备已上电并进入配网模式（LED 五次快闪）
- 检查 APP 是否获得蓝牙和定位权限
- Android 需要开启位置服务（系统要求）
- 尝试关闭蓝牙后重新开启

### 配网失败

- 确保 WiFi 密码正确
- 确保 2.4GHz WiFi（ESP32 不支持 5GHz）
- 确保 MQTT 服务器地址配置正确
- 检查设备与服务端网络连通性

### APP 无法连接服务端

- 确认服务器地址格式正确（包含 `http://` 前缀）
- 确认防火墙开放了 48080 端口
- 浏览器访问 `http://{IP}:48080/health` 验证服务是否可用

## 相关文档

- [固件开发指南](/FIRMWARE_GUIDE) — ESP32 固件开发说明
- [API 参考](/API_REFERENCE) — REST API 文档
- [数据流架构](/ARCHITECTURE_DATA_FLOW) — 全链路数据流
- [快速开始](/START_HERE) — 项目快速上手
