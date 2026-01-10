# API 接口参考文档

**作者**: 罗耀生
**日期**: 2026-01-10
**版本**: v0.3.0

---

## 1. 接口概述

### 1.1 基础信息

| 项目 | 说明 |
|------|------|
| 基础路径 | `/api/v1` |
| 协议 | HTTPS (生产) / HTTP (开发) |
| 数据格式 | JSON |
| 字符编码 | UTF-8 |

### 1.2 认证方式

**JWT Token**:
```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**API Key**:
```http
X-API-Key: sk_xxxxxxxxxxxxx
X-API-Secret: xxxxxxxxxxxxxxxx
```

---

## 2. 用户接口

### 2.1 用户注册

```http
POST /api/v1/users/register
Content-Type: application/json
```

**请求体**:
```json
{
  "username": "user@example.com",
  "password": "password123",
  "email": "user@example.com"
}
```

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "userId": 1,
    "username": "user@example.com",
    "email": "user@example.com"
  }
}
```

### 2.2 用户登录

```http
POST /api/v1/users/login
Content-Type: application/json
```

**请求体**:
```json
{
  "username": "user@example.com",
  "password": "password123"
}
```

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "user": {
      "userId": 1,
      "username": "user@example.com",
      "email": "user@example.com"
    },
    "token": "eyJhbGci...",
    "refreshToken": "eyJhbGci...",
    "expiresIn": 86400
  }
}
```

### 2.3 刷新 Token

```http
POST /api/v1/users/refresh-token
Content-Type: application/json
```

**请求体**:
```json
{
  "refreshToken": "eyJhbGci..."
}
```

### 2.4 获取用户信息

```http
GET /api/v1/users/me
Authorization: Bearer <token>
```

### 2.5 创建 API Key

```http
POST /api/v1/users/api-keys
Authorization: Bearer <token>
Content-Type: application/json
```

**请求体**:
```json
{
  "description": "用于设备集成"
}
```

**响应**:
```json
{
  "code": 200,
  "data": {
    "keyId": "ak_xxx",
    "apiKey": "sk_xxx...",
    "description": "用于设备集成"
  }
}
```

### 2.6 查询 API Keys

```http
GET /api/v1/users/api-keys
Authorization: Bearer <token>
```

### 2.7 删除 API Key

```http
DELETE /api/v1/users/api-keys/:keyId
Authorization: Bearer <token>
```

---

## 3. 产品接口

### 3.1 创建产品

```http
POST /api/v1/products
Authorization: Bearer <token>
Content-Type: application/json
```

**请求体**:
```json
{
  "productKey": "SW-SERVO-002",
  "name": "智能开关 v2",
  "description": "ESP32 智能开关设备",
  "category": "switch",
  "controlMode": "toggle",
  "uiTemplate": "servo_switch",
  "iconName": "settings_remote",
  "iconColor": "#FF6B35",
  "manufacturer": "SmartLink",
  "model": "ESP32-Switch-v2"
}
```

**字段说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| productKey | string | 是 | 产品标识，全局唯一 |
| name | string | 是 | 产品名称 |
| description | string | 否 | 产品描述 |
| category | string | 否 | 产品类别 |
| controlMode | string | 否 | toggle/pulse/dimmer/readonly/generic |
| uiTemplate | string | 否 | UI 模板名称 |
| iconName | string | 否 | Material Icons 图标名 |
| iconColor | string | 否 | 图标颜色 (HEX) |
| manufacturer | string | 否 | 制造商 |
| model | string | 否 | 硬件型号 |

**响应**:
```json
{
  "code": 200,
  "data": {
    "productId": 2,
    "productKey": "SW-SERVO-002",
    "name": "智能开关 v2"
  }
}
```

### 3.2 产品列表

```http
GET /api/v1/products?category=switch&page=1&size=20
Authorization: Bearer <token>
```

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| category | string | 否 | 产品类别 |
| page | int | 否 | 页码，默认 1 |
| size | int | 否 | 每页数量，默认 20 |

**响应**:
```json
{
  "code": 200,
  "data": {
    "list": [
      {
        "productId": 1,
        "productKey": "SW-SERVO-001",
        "name": "Smart Servo Switch",
        "description": "ESP32 smart servo switch",
        "category": "switch",
        "controlMode": "toggle",
        "uiTemplate": "servo_switch",
        "iconName": "settings_remote",
        "iconColor": "#FF6B35",
        "manufacturer": "SmartLink",
        "model": "ESP32-Servo",
        "status": 1
      }
    ],
    "total": 10,
    "page": 1,
    "size": 20
  }
}
```

### 3.3 产品详情

```http
GET /api/v1/products/:productKey
Authorization: Bearer <token>
```

**响应**: 同产品列表项

### 3.4 更新产品

```http
PUT /api/v1/products/:productKey
Authorization: Bearer <token>
Content-Type: application/json
```

**请求体**: 同创建产品

### 3.5 删除产品

```http
DELETE /api/v1/products/:productKey
Authorization: Bearer <token>
```

---

## 4. 设备接口

### 4.1 设备激活

```http
POST /api/v1/devices/activate
Content-Type: application/json
```

**认证**: 无需认证 (设备端调用)

**请求体**:
```json
{
  "productKey": "SW-SERVO-001",
  "deviceSN": "AABBCCDDEEFF",
  "firmwareVersion": "1.0.0",
  "chipModel": "ESP32"
}
```

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "deviceId": "dev_a1b2c3d4",
    "deviceSecret": "sk_abc123...",
    "mqtt": {
      "server": "192.168.1.100",
      "port": 1883,
      "portTLS": 8883,
      "username": "SW-SERVO-001&dev_a1b2c3d4",
      "password": "tk_xyz789...",
      "clientId": "SW-SERVO-001&dev_a1b2c3d4",
      "keepAlive": 60
    },
    "topics": {
      "propertyPost": "/sys/SW-SERVO-001/dev_a1b2c3d4/thing/event/property/post",
      "propertySet": "/sys/SW-SERVO-001/dev_a1b2c3d4/thing/service/property/set",
      "status": "/sys/SW-SERVO-001/dev_a1b2c3d4/status"
    }
  }
}
```

**错误响应**:
```json
{
  "code": 400,
  "message": "invalid_product_key",
  "data": null
}
```

### 4.2 设备列表

```http
GET /api/v1/devices?productKey=SW-SERVO-001&status=1&page=1&size=20
Authorization: Bearer <token>
```

**查询参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| productKey | string | 否 | 产品标识 |
| status | int | 否 | 设备状态 (0/1/2/3) |
| page | int | 否 | 页码，默认 1 |
| size | int | 否 | 每页数量，默认 20 |

**响应**:
```json
{
  "code": 200,
  "data": {
    "list": [
      {
        "deviceId": "dev_a1b2c3d4",
        "deviceSN": "AABBCCDDEEFF",
        "productKey": "SW-SERVO-001",
        "projectId": "proj_default",
        "name": "客厅开关",
        "status": "online",
        "statusText": "在线",
        "firmwareVersion": "1.0.0",
        "chipModel": "ESP32",
        "lastOnlineAt": "2026-01-10T15:30:00Z",
        "activatedAt": "2026-01-10T10:00:00Z",
        "createdAt": "2026-01-10T10:00:00Z",
        "product": {
          "productId": 1,
          "productKey": "SW-SERVO-001",
          "name": "Smart Servo Switch",
          "uiTemplate": "servo_switch",
          "iconName": "settings_remote",
          "iconColor": "#FF6B35"
        }
      }
    ],
    "total": 1,
    "page": 1,
    "size": 20
  }
}
```

### 4.3 设备详情

```http
GET /api/v1/devices/:deviceId
Authorization: Bearer <token>
```

**响应**: 同设备列表项

### 4.4 设备状态

```http
GET /api/v1/devices/:deviceId/status
Authorization: Bearer <token>
```

**响应**:
```json
{
  "code": 200,
  "data": {
    "deviceId": "dev_a1b2c3d4",
    "deviceName": "客厅开关",
    "online": true,
    "position": "up",
    "status": "online",
    "lastOnlineAt": "2026-01-10T15:30:00Z"
  }
}
```

### 4.5 设备控制

```http
POST /api/v1/devices/:deviceId/control
Authorization: Bearer <token>
Content-Type: application/json
```

**新协议请求**:
```json
{
  "action": "toggle",
  "position": "up"
}
```

或
```json
{
  "action": "pulse",
  "duration": 500
}
```

**旧协议请求 (兼容)**:
```json
{
  "switch": true,
  "angle": 90
}
```

**参数说明**:
| 参数 | 类型 | 说明 |
|------|------|------|
| action | string | toggle/pulse/trigger |
| position | string | up/middle/down (toggle 模式) |
| duration | int | 延迟时间毫秒 (pulse 模式) |
| switch | bool | 开关状态 (旧协议) |
| angle | int | 角度 0-180 (旧协议) |

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "message": "command_sent"
  }
}
```

### 4.6 删除设备

```http
DELETE /api/v1/devices/:deviceId
Authorization: Bearer <token>
```

---

## 5. MQTT 主题规范

### 5.1 主题格式

```
/sys/{ProductKey}/{DeviceID}/{action}
```

### 5.2 设备上报

**主题**: `/sys/{ProductKey}/{DeviceID}/thing/event/property/post`

**方向**: 设备 → 服务端

**消息**:
```json
{
  "method": "thing.event.property.post",
  "id": "123456",
  "params": {
    "position": "up",
    "angle": 90,
    "wifi_rssi": -45
  },
  "time": 1704886800000
}
```

### 5.3 设备控制

**主题**: `/sys/{ProductKey}/{DeviceID}/thing/service/property/set`

**方向**: 服务端 → 设备

**消息**:
```json
{
  "method": "thing.service.property.set",
  "id": "789012",
  "params": {
    "action": "toggle",
    "position": "up"
  },
  "time": 1704886800000
}
```

### 5.4 设备状态

**主题**: `/sys/{ProductKey}/{DeviceID}/status`

**方向**: 双向

**在线消息**:
```json
{
  "status": "online",
  "time": 1704886800000
}
```

**离线消息**:
```json
{
  "status": "offline",
  "time": 1704886800000
}
```

---

## 6. 错误码

### 6.1 错误响应格式

```json
{
  "code": 400,
  "message": "error_message",
  "data": null
}
```

### 6.2 常见错误码

| 错误码 | 说明 |
|-------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

### 6.3 业务错误码

| 错误信息 | 说明 |
|---------|------|
| invalid_product_key | 无效的产品标识 |
| product_disabled | 产品已禁用 |
| device_not_found | 设备不存在 |
| device_not_activated | 设备未激活 |
| device_disabled | 设备已禁用 |
| invalid_password | 密码错误 |
| invalid_client_id | ClientID 不匹配 |
| no_control_params | 无控制参数 |

---

## 7. WebSocket 接口

### 7.1 连接

```javascript
const ws = new WebSocket('ws://localhost:8083/mqtt');

// 认证
ws.send(JSON.stringify({
  action: 'auth',
  username: 'SW-SERVO-001&dev_a1b2c3d4',
  password: 'tk_xyz789...'
}));
```

### 7.2 订阅主题

```javascript
ws.send(JSON.stringify({
  action: 'subscribe',
  topic: '/sys/SW-SERVO-001/dev_a1b2c3d4/thing/event/property/post'
}));
```

### 7.3 接收消息

```javascript
ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  console.log(message.topic, message.payload);
};
```

---

**修改历史**

| 日期 | 版本 | 修改内容 | 作者 |
|------|------|----------|------|
| 2026-01-10 | v0.3.0 | 初始版本 | 罗耀生 |
