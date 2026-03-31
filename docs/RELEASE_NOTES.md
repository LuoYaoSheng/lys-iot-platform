# Open IoT Platform v0.3.0 Release

**发布日期**: 2026-01-10

---

## 📦 下载文件说明

| 文件 | 大小 | 说明 |
|------|------|------|
| `open-iot-platform-v0.3.0.zip` | 27 MB | 完整发布包（解压后使用） |

### 压缩包内容

**固件 (firmware/)**
| 文件 | 芯片 | 烧写地址 |
|------|------|----------|
| esp32-servo-firmware.bin | ESP32 | 0x10000 |
| bootloader-esp32.bin | ESP32 | 0x1000 |
| partitions-esp32.bin | ESP32 | 0x8000 |
| esp32s3-wakeup-firmware.bin | ESP32-S3 | 0x10000 |
| bootloader-esp32s3.bin | ESP32-S3 | 0x1000 |
| partitions-esp32s3.bin | ESP32-S3 | 0x8000 |

**服务端 (server/)**
- `docker-compose.yml` - Docker Compose 配置
- `scripts/init.sql` - 数据库初始化脚本

**移动端**
- `iot-config-app.apk` - Android 配网控制 APP (直接安装)

---

## ✨ v0.3.0 更新内容

### 新增功能
- 🎯 **内置 MQTT Broker** - 无需外部 EMQX，简化部署
- 🎨 **动态控制面板** - 根据产品类型自动渲染控制界面
- 📱 **USB 唤醒设备支持** - 新增 ESP32-S3 USB HID 唤醒功能
- 📖 **完整 PRD 文档** - 总体/移动端/服务端/API 文档
- 🔔 **设备离线自动检测** - 30 秒无活动自动标记离线

### 优化改进
- 📊 设备列表位置字段仅对舵机设备显示
- 🔧 MQTT 地址自动提取与设备状态同步
- 🐛 修复舵机启动大幅度旋转问题
- 🐛 修复设备列表加载类型转换错误
- 🐛 修复 USB HID 初始化问题

---

## 🚀 快速开始

### 1. 烧写固件

使用 [Flash Download Tool](https://www.espressif.com/zh-hans/support/download/other-tools) 烧写：

1. 解压 `open-iot-platform-v0.3.0.zip`
2. 烧写固件到对应地址（见上表）

### 2. 安装 APP

直接安装 `iot-config-app.apk` 到 Android 手机

### 3. 部署服务端

```bash
# 上传 server/ 目录到服务器
cd server
docker compose up -d
```

服务地址：
- API: http://localhost:48080
- MQTT TCP: localhost:1883
- MQTT WebSocket: localhost:8083

### 4. BLE 配网

1. 设备上电进入配网模式（LED 闪烁）
2. 打开 APP，点击"添加设备"
3. 选择设备，输入 WiFi 密码
4. 等待配网完成

---

## 📖 文档链接

- [产品需求文档 (PRD)](https://gitee.com/luoyaosheng/lys-iot-platform/blob/master/docs/PRD.md)
- [移动端功能需求](https://gitee.com/luoyaosheng/lys-iot-platform/blob/master/docs/PRD_MOBILE.md)
- [服务端功能需求](https://gitee.com/luoyaosheng/lys-iot-platform/blob/master/docs/PRD_SERVER.md)
- [API 接口文档](https://gitee.com/luoyaosheng/lys-iot-platform/blob/master/docs/API_REFERENCE.md)
- [设备统一规范](https://gitee.com/luoyaosheng/lys-iot-platform/blob/master/docs/DEVICE_UNIFIED_SPEC.md)

---

## ⚠️ 注意事项

1. **ESP32-S3 USB 唤醒设备**: USB HID 模式下无法使用 USB 串口，请使用硬件串口查看日志
2. **首次使用**: 建议先清除 NVS (`esptool --erase-flash`) 重新配网
3. **服务端依赖**: 需要 Docker + MySQL + Redis

---

## 🔄 版本历史

- [v0.2.0](https://gitee.com/luoyaosheng/lys-iot-platform/releases/tag/v0.2.0) - USB 唤醒设备支持
- [v0.1.0](https://gitee.com/luoyaosheng/lys-iot-platform/releases/tag/v0.1.0) - 初始版本

---

**作者**: 罗耀生
**仓库**: https://gitee.com/luoyaosheng/lys-iot-platform
