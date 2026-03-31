# Open IoT Platform

> 开源 IoT 设备管理平台 - 完整的物联网解决方案

**作者**: 罗耀生
**协议**: GPL v3
**📍 仓库地址**:
- [Gitee](https://gitee.com/luoyaosheng/lys-iot-platform) - 国内访问推荐
- [GitHub](https://github.com/LuoYaoSheng/open-iot-platform) - 国际访问

---

## 项目简介

一个轻量级的开源 IoT 平台，提供从硬件固件、云端服务到移动端配网的完整解决方案。

### 核心功能

- **设备管理**: 设备注册、激活、生命周期管理
- **产品管理**: 定义设备型号和物模型
- **MQTT 服务**: 设备认证与消息路由
- **物模型**: 属性、服务、事件定义
- **移动配网**: BLE 蓝牙配网 APP
- **硬件固件**: ESP32/ESP32-S3 设备固件

---

## 项目结构

```
open-iot-platform/
├── server/              # 后端服务 (Go + Gin + MySQL + Redis + EMQX)
├── mobile-app/          # 移动端配网 APP (Flutter)
├── iot-libs-common/     # 公共库 (Flutter SDK + 嵌入式库)
├── smartlink-hub/       # SmartLink 配网服务
├── firmware/            # 硬件固件
│   ├── switch/         # ESP32 智能开关固件
│   └── usb-wakeup/     # ESP32-S3 USB 键盘唤醒固件
└── docs/               # 文档
```

---

## 快速开始

### Docker 一键部署

```bash
git clone https://gitee.com/luoyaosheng/lys-iot-platform.git
cd open-iot-platform/server
docker compose up -d
```

### 本地模拟联调

如果你要在 Android 模拟器里跑完整本地链路，请先看：

- [本地联调 Runbook](docs/LOCAL_EMULATOR_RUNBOOK.md)
- [配置链路说明](docs/CONFIGURATION_CHAIN.md)
- [仓库结构说明](docs/REPOSITORY_ARCHITECTURE.md)

### 服务地址

| 服务 | 地址 | 说明 |
|------|------|------|
| Core API | http://localhost:48080 | 设备引擎 API |
| EMQX Dashboard | http://localhost:48884 | MQTT 管理 (admin/public) |
| MySQL | localhost:48306 | 数据库 (root/root123456) |
| Redis | localhost:48379 | 缓存服务 |
| MQTT TCP | localhost:48883 | MQTT 服务 |
| MQTT WebSocket | localhost:48803 | MQTT WebSocket |

---

## 移动端 APP

### 安装依赖

```bash
cd mobile-app
flutter pub get
```

### 运行 APP

```bash
# Android 真机/模拟器
flutter run

# iOS 模拟器 (需要 macOS)
flutter run -d iPhone
```

### 构建 APK

```bash
flutter build apk --release
```

详细说明请查看 [mobile-app/README.md](mobile-app/README.md)

---

## 硬件固件

### 1. ESP32 智能开关

```bash
cd firmware/switch
pio run
pio run --target upload
```

### 2. ESP32-S3 USB 唤醒设备

通过 MQTT 命令模拟键盘唤醒休眠的电脑。

```bash
cd firmware/usb-wakeup
pio run
pio run --target upload
```

详细说明请查看:
- [firmware/switch/README.md](firmware/switch/README.md)
- [firmware/usb-wakeup/README.md](firmware/usb-wakeup/README.md)

---

## 配网流程

### BLE 蓝牙配网

1. 设备上电进入配网模式（LED 五次快闪）
2. 打开移动端 APP，扫描蓝牙设备
3. 选择设备并配置 WiFi 信息
4. 设备自动连接 WiFi 并激活到平台
5. 配网完成，可远程控制设备

**设备蓝牙名称格式**: `IoT-Wakeup-XXXX` 或 `IoT-Switch-XXXX`

**配置数据格式**:
```json
{
  "ssid": "YourWiFi",
  "password": "YourPassword",
  "apiUrl": "http://192.168.1.100:48080"
}
```

---

## 技术栈

| 组件 | 技术选型 |
|------|---------|
| 后端 | Go + Gin + GORM |
| 数据库 | MySQL |
| 缓存 | Redis |
| MQTT | EMQX |
| 移动端 | Flutter + Dart |
| 固件 | ESP32/ESP32-S3 (PlatformIO + Arduino) |
| 部署 | Docker + Docker Compose |

---

## API 示例

### 创建产品

```bash
curl -X POST http://localhost:48080/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "智能开关",
    "description": "ESP32 智能开关设备"
  }'
```

### 注册设备

```bash
curl -X POST http://localhost:48080/api/v1/devices/register \
  -H "Content-Type: application/json" \
  -d '{
    "product_key": "switch_v1",
    "device_sn": "SN001"
  }'
```

---

## 开发路线图

- [x] 设备引擎核心功能
- [x] MQTT 认证与消息路由
- [x] 物模型管理
- [x] BLE 配网
- [x] 移动端 APP
- [x] ESP32 智能开关固件
- [x] ESP32-S3 USB 唤醒固件
- [ ] Web 管理界面
- [ ] 更多硬件支持

---

## 许可证

GNU General Public License v3.0

**Issues 反馈**:
- [Gitee Issues](https://gitee.com/luoyaosheng/lys-iot-platform/issues)
- [GitHub Issues](https://github.com/LuoYaoSheng/open-iot-platform/issues)
