# IoT 设备统一规范

**作者**: 罗耀生  
**日期**: 2026-01-07  
**版本**: v1.0

---

## 1. 硬件行为规范

### 1.1 状态指示 (LED)

| LED 状态 | 含义 |
|---------|------|
| 闪烁 (500ms 间隔) | BLE 配网模式，等待连接 |
| 常亮 | 正常运行 (已连接 MQTT) |
| 快闪 (100ms 间隔) | WiFi 连接中 |
| 慢闪 (2s 间隔) | MQTT 连接中 |
| 熄灭 | 关机或错误 |

### 1.2 按键操作

| 操作 | 行为 |
|------|------|
| 长按 BOOT 1秒 | 提示即将重置 (LED 变化) |
| 长按 BOOT 3秒 | **强制重置**，清除配置，进入 BLE 配网模式 |
| 松开按键 <3秒 | 取消重置 |

### 1.3 上电行为

```
首次上电 → 检查配置 → 无 WiFi → BLE 配网模式
已配置上电 → 检查配置 → 连接 WiFi → 连接 MQTT → 正常运行
WiFi 失败 → 自动回到 BLE 配网模式
```

---

## 2. 产品命名规范

| 产品类型 | PRODUCT_KEY | BLE 前缀 | 固件目录 |
|---------|-------------|----------|----------|
| 舵机开关 | `SW-SERVO-001` | `IoT-Switch-` | `/firmware/switch` |
| USB 唤醒 | `USB-WAKEUP-S3` | `IoT-Wakeup-` | `/firmware/wakeup` |

**命名规则：**
- PRODUCT_KEY: 大写字母，`-` 分隔，描述性强
- BLE 前缀: `IoT-` + 产品类型 + `-`
- 统一使用 4 字符后缀 (MAC 后 4 位)

---

## 3. BLE 配网统一规范

### 3.1 UUID 规范 (所有设备统一)

```
Service UUID: 0000FFE0-0000-1000-8000-00805F9B34FB
WiFi Char:    0000FFE1-0000-1000-8000-00805F9B34FB  
Status Char:  0000FFE2-0000-1000-8000-00805F9B34FB
```

### 3.2 数据格式 (JSON)

**发送 WiFi 配置:**
```json
{
  "ssid": "WiFi名称",
  "password": "WiFi密码",
  "apiUrl": "http://192.168.21.77:48080"  // 可选
}
```

**状态通知:**
```json
{
  "status": "received|wifi_connected|activated|error",
  "message": "详细信息"
}
```

---

## 4. 新增设备清单

开发新设备时，确保以下项目完成：

### 4.1 固件端
- [ ] `PRODUCT_KEY` 已定义
- [ ] BLE 前缀使用 `IoT-` 开头
- [ ] BLE UUID 使用统一值
- [ ] 实现长按 BOOT 3秒重置
- [ ] LED 状态指示完整
- [ ] 支持自定义 API 地址

### 4.2 服务端
- [ ] 在 `products` 表中创建产品记录
- [ ] 配置正确的 `mqtt_topics` 和 `capabilities`

### 4.3 APP 端
- [ ] 在 `ble_service.dart` 中添加 BLE 前缀
- [ ] 如需特殊控制面板，实现对应 UI

### 4.4 文档
- [ ] 更新本文档的产品列表
- [ ] 记录特殊配置说明

---

## 5. GPIO 统一规范

| 功能 | 引脚 | 说明 |
|------|------|------|
| LED_BUILTIN | 2 | 板载 LED (ESP32) |
| CONFIG_BUTTON | 0 | BOOT 按键 |

---

## 6. 环境变量规范

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| REDIS_HOST | localhost | Redis 地址 |
| REDIS_PORT | 47379 | Redis 端口 |
| REDIS_DEVICE_TTL | 120 | 设备在线超时(秒) |
| DB_HOST | localhost | MySQL 地址 |
| DB_PORT | 44306 | MySQL 端口 |

---

## 7. 修改历史

| 日期 | 版本 | 修改内容 | 作者 |
|------|------|----------|------|
| 2026-01-07 | v1.0 | 初始版本，统一规范 | 罗耀生 |
