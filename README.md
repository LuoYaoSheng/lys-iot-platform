# Open IoT Platform

> 开源 IoT 设备管理平台

**作者**: 罗耀生
**协议**: GPL v3
**仓库**: https://gitee.com/luoyaosheng/open-iot-platform

---

## 项目简介

一个轻量级的开源 IoT 平台，专注于设备连接和管理。适用于个人开发者、创客和小型项目。

### 核心功能

- **产品管理**: 定义设备型号和物模型
- **设备管理**: 设备注册、激活、生命周期管理
- **MQTT 服务**: 设备认证与消息路由
- **物模型**: 属性、服务、事件定义
- **配网工具**: BLE 配网 + SmartLink Hub

---

## 项目结构

```
open-iot-platform/
├── server/              # 设备引擎 (Go + Gin + MySQL + Redis + EMQX)
├── smartlink-hub/       # SmartLink 配网服务
├── firmware/            # 硬件固件
│   ├── switch/         # ESP32 智能开关固件
│   └── usb-wakeup/     # USB 键盘唤醒固件 (开发中)
└── docker/             # Docker 部署配置
```

---

## 快速开始

### Docker 一键部署

```bash
git clone https://gitee.com/luoyaosheng/open-iot-platform.git
cd open-iot-platform/server
docker compose up -d
```

### 服务地址

| 服务 | 地址 | 说明 |
|------|------|------|
| Core API | http://localhost:48080 | 设备引擎 API |
| EMQX Dashboard | http://localhost:49084 | MQTT 管理 (admin/public) |
| MySQL | localhost:44306 | 数据库 (root/root123456) |
| Redis | localhost:47379 | 缓存服务 |

---

## 硬件接入

### 1. ESP32 智能开关

```bash
cd firmware/switch
pio run
pio run --target upload
```

### 2. USB 唤醒设备 (开发中)

基于 ESP32-S3 的 USB HID 设备，通过远程命令唤醒电脑。

---

## 技术栈

| 组件 | 技术选型 |
|------|---------|
| 后端 | Go + Gin + GORM |
| 数据库 | MySQL |
| 缓存 | Redis |
| MQTT | EMQX |
| 固件 | ESP32 (PlatformIO + Arduino) |
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
- [x] Docker 部署
- [ ] USB 唤醒固件开发
- [ ] 更多硬件支持

---

## 许可证

GNU General Public License v3.0

---

## 联系方式

- Gitee: https://gitee.com/luoyaosheng
- Issues: https://gitee.com/luoyaosheng/open-iot-platform/issues
