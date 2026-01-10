# 服务端功能需求文档

**作者**: 罗耀生
**日期**: 2026-01-10
**版本**: v0.3.0

---

## 1. 概述

### 1.1 服务定位

IoT Platform Server 是基于 Go 语言开发的 IoT 设备管理后端服务，提供设备激活、认证、控制、消息路由等核心功能。

### 1.2 技术架构

| 模块 | 技术方案 |
|------|---------|
| 开发语言 | Go 1.24.0 |
| Web 框架 | Gin |
| ORM | GORM |
| 数据库 | MySQL 8.0 |
| 缓存 | Redis 7 (可选) |
| MQTT Broker | 内置 (mochi-mqtt) |
| 认证 | JWT + API Key |

### 1.3 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                       HTTP API 层                           │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐ │
│  │ 设备接口  │  │ 产品接口  │  │ 用户接口  │  │ MQTT回调  │ │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       服务层 (Service)                      │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐ │
│  │DeviceSvc  │  │ProductSvc │  │  UserSvc  │  │  MqttSvc  │ │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       数据层 (Repository)                   │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐ │
│  │ DeviceRepo│  │ProductRepo│  │  UserRepo │  │  MqttRepo │ │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
         ┌──────────────────┼──────────────────┐
         ▼                  ▼                  ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│    MySQL     │   │    Redis     │   │  MQTT Broker │
│  (持久化存储) │   │  (状态缓存)   │   │  (消息路由)  │
└──────────────┘   └──────────────┘   └──────────────┘
```

---

## 2. 功能模块

### 2.1 用户管理模块

#### 2.1.1 用户注册

**路由**: `POST /api/v1/users/register`

**功能描述**:
- 新用户注册
- 密码加密存储 (bcrypt)
- 邮箱格式验证
- 用户名唯一性检查

**请求参数**:
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

#### 2.1.2 用户登录

**路由**: `POST /api/v1/users/login`

**功能描述**:
- 邮箱/密码登录
- 生成 JWT Token
- 生成 RefreshToken

**请求参数**:
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
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 86400
  }
}
```

#### 2.1.3 Token 刷新

**路由**: `POST /api/v1/users/refresh-token`

**功能描述**:
- 使用 RefreshToken 获取新 Token
- 验证 RefreshToken 有效性

**请求参数**:
```json
{
  "refreshToken": "eyJhbGci..."
}
```

#### 2.1.4 获取用户信息

**路由**: `GET /api/v1/users/me`

**认证**: 需要 JWT Token

**响应**:
```json
{
  "code": 200,
  "data": {
    "userId": 1,
    "username": "user@example.com",
    "email": "user@example.com",
    "createdAt": "2026-01-10T10:00:00Z"
  }
}
```

#### 2.1.5 API Key 管理

**创建 API Key**:
```http
POST /api/v1/users/api-keys
Authorization: Bearer <token>

{
  "description": "用于设备集成"
}

Response:
{
  "code": 200,
  "data": {
    "keyId": "ak_xxx",
    "apiKey": "sk_xxx...",
    "description": "用于设备集成"
  }
}
```

**查询 API Keys**:
```http
GET /api/v1/users/api-keys
Authorization: Bearer <token>
```

**删除 API Key**:
```http
DELETE /api/v1/users/api-keys/:keyId
Authorization: Bearer <token>
```

---

### 2.2 产品管理模块

#### 2.2.1 创建产品

**路由**: `POST /api/v1/products`

**认证**: 需要 JWT Token

**请求参数**:
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

#### 2.2.2 产品列表

**路由**: `GET /api/v1/products`

**查询参数**:
- `category`: 产品类别
- `page`: 页码 (默认 1)
- `size`: 每页数量 (默认 20)

**响应**:
```json
{
  "code": 200,
  "data": {
    "list": [...],
    "total": 10,
    "page": 1,
    "size": 20
  }
}
```

#### 2.2.3 产品详情

**路由**: `GET /api/v1/products/:productKey`

**响应**:
```json
{
  "code": 200,
  "data": {
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
}
```

#### 2.2.4 更新产品

**路由**: `PUT /api/v1/products/:productKey`

#### 2.2.5 删除产品

**路由**: `DELETE /api/v1/products/:productKey`

---

### 2.3 设备管理模块

#### 2.3.1 设备激活

**路由**: `POST /api/v1/devices/activate`

**认证**: 无需认证

**功能描述**:
- 设备首次激活注册
- 生成设备密钥
- 分配 MQTT 凭证
- 支持并发处理

**请求参数**:
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

**激活流程**:
```
1. 验证 Product Key 是否存在且启用
2. 检查设备是否已激活
   ├─ 已激活 → 返回现有配置
   └─ 未激活 → 创建新设备
3. 生成设备凭证
   - DeviceID: dev_xxxxxxxx
   - DeviceSecret: sk_xxxxxxxx
   - MQTT Username: {ProductKey}&{DeviceID}
   - MQTT Password: tk_xxxxxxxx
4. 保存到数据库
5. 返回激活信息
```

#### 2.3.2 设备列表

**路由**: `GET /api/v1/devices`

**认证**: 需要 JWT Token 或 API Key

**查询参数**:
- `productKey`: 产品标识 (可选)
- `status`: 设备状态 (可选，0/1/2/3)
- `page`: 页码 (默认 1)
- `size`: 每页数量 (默认 20)

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

#### 2.3.3 设备详情

**路由**: `GET /api/v1/devices/:deviceId`

**认证**: 需要 JWT Token 或 API Key

**响应**: 同设备列表项

#### 2.3.4 设备状态查询

**路由**: `GET /api/v1/devices/:deviceId/status`

**认证**: 需要 JWT Token 或 API Key

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

#### 2.3.5 设备控制

**路由**: `POST /api/v1/devices/:deviceId/control`

**认证**: 需要 JWT Token 或 API Key

**功能描述**:
- 构建控制消息
- 发布到 MQTT 主题
- 不等待设备响应

**请求参数 (新协议)**:
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

**请求参数 (旧协议兼容)**:
```json
{
  "switch": true,
  "angle": 90
}
```

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

#### 2.3.6 设备删除

**路由**: `DELETE /api/v1/devices/:deviceId`

**认证**: 需要 JWT Token

---

### 2.4 MQTT 模块

#### 2.4.1 内置 Broker

**功能描述**:
- 内置 MQTT Broker (mochi-mqtt)
- 无需外部 EMQX 依赖
- 支持认证和 ACL

**配置**:
```go
type MQTTConfig struct {
    Port      int    // 1883
    WSPort    int    // 8083
    EnableWS  bool   // true
}
```

#### 2.4.2 设备认证

**内部接口**: `POST /api/v1/mqtt/auth`

**功能描述**:
- 验证设备 MQTT 连接
- 检查 Username (ProductKey&DeviceID)
- 验证 Password
- 检查设备状态

**请求参数**:
```json
{
  "username": "SW-SERVO-001&dev_a1b2c3d4",
  "password": "tk_xyz789...",
  "clientId": "SW-SERVO-001&dev_a1b2c3d4"
}
```

**响应**:
```json
{
  "code": 200,
  "data": {
    "allowed": true,
    "deviceId": "dev_a1b2c3d4"
  }
}
```

#### 2.4.3 ACL 验证

**内部接口**: `POST /api/v1/mqtt/acl`

**功能描述**:
- 验证设备 Topic 订阅/发布权限
- 仅允许设备访问自己的 Topic

**规则**:
```
允许: /sys/{ProductKey}/{DeviceID}/#
拒绝: 其他所有 Topic
```

**请求参数**:
```json
{
  "username": "SW-SERVO-001&dev_a1b2c3d4",
  "topic": "/sys/SW-SERVO-001/dev_a1b2c3d4/thing/event/property/post",
  "action": "publish"
}
```

#### 2.4.4 连接状态回调

**功能描述**:
- 设备上线/下线回调
- 更新设备状态
- 更新 Redis 缓存

**流程**:
```
设备连接 MQTT
    │
    ▼
触发认证回调
    │
    ├─ 成功 → 标记设备在线 → 更新 Redis
    │
    └─ 失败 → 拒绝连接

设备断开 MQTT
    │
    ▼
30 秒无活动 → 标记设备离线 → 清除 Redis
```

---

### 2.5 项目管理模块

#### 2.5.1 创建项目

**路由**: `POST /api/v1/projects`

**认证**: 需要 JWT Token

**请求参数**:
```json
{
  "projectName": "智能家居",
  "description": "家庭智能设备项目"
}
```

#### 2.5.2 项目列表

**路由**: `GET /api/v1/projects`

#### 2.5.3 项目详情

**路由**: `GET /api/v1/projects/:projectId`

#### 2.5.4 更新项目

**路由**: `PUT /api/v1/projects/:projectId`

#### 2.5.5 删除项目

**路由**: `DELETE /api/v1/projects/:projectId`

---

### 2.6 数据模型

#### 2.6.1 User 模型

```go
type User struct {
    ID        int64     `gorm:"primaryKey" json:"id"`
    Username  string    `gorm:"uniqueIndex;size:64" json:"username"`
    Email     string    `gorm:"uniqueIndex;size:128" json:"email"`
    Password  string    `gorm:"size:256" json:"-"`
    CreatedAt time.Time `json:"createdAt"`
    UpdatedAt time.Time `json:"updatedAt"`
}
```

#### 2.6.2 Product 模型

```go
type Product struct {
    ID          int64     `gorm:"primaryKey" json:"id"`
    ProductKey  string    `gorm:"uniqueIndex;size:64" json:"productKey"`
    Name        string    `gorm:"size:128" json:"name"`
    Description string    `gorm:"type:text" json:"description"`
    Category    string    `gorm:"size:64" json:"category"`

    // UI 控制相关
    ControlMode  string `gorm:"size:32" json:"controlMode"`     // toggle/pulse/dimmer/readonly/generic
    UITemplate   string `gorm:"size:64" json:"uiTemplate"`      // UI模板名称
    IconName     string `gorm:"size:64" json:"iconName"`        // Material Icons
    IconColor    string `gorm:"size:16" json:"iconColor"`       // HEX颜色
    Capabilities string `gorm:"type:text" json:"capabilities"`  // 产品能力(JSON)
    MQTTTopics   string `gorm:"type:text" json:"mqttTopics"`    // MQTT主题配置
    Manufacturer string `gorm:"size:128" json:"manufacturer"`
    Model        string `gorm:"size:64" json:"model"`

    Status    int       `gorm:"default:1" json:"status"`
    CreatedAt time.Time `json:"createdAt"`
    UpdatedAt time.Time `json:"updatedAt"`
}
```

#### 2.6.3 Device 模型

```go
type Device struct {
    ID              int64        `gorm:"primaryKey" json:"id"`
    DeviceID        string       `gorm:"uniqueIndex;size:64" json:"deviceId"`
    DeviceSN        string       `gorm:"size:64" json:"deviceSN"`
    DeviceSecret    string       `gorm:"size:128" json:"-"`
    ProductKey      string       `gorm:"size:64" json:"productKey"`
    ProjectID       string       `gorm:"index;size:64" json:"projectId"`
    Name            string       `gorm:"size:128" json:"name"`
    Status          DeviceStatus `gorm:"default:0" json:"status"`
    FirmwareVersion string       `gorm:"size:32" json:"firmwareVersion"`
    ChipModel       string       `gorm:"size:32" json:"chipModel"`
    MQTTUsername    string       `gorm:"size:128" json:"mqttUsername"`
    MQTTPassword    string       `gorm:"size:256" json:"-"`
    MQTTClientID    string       `gorm:"size:128" json:"mqttClientId"`
    LastOnlineAt    *time.Time   `json:"lastOnlineAt"`
    ActivatedAt     *time.Time   `json:"activatedAt"`
    CreatedAt       time.Time    `json:"createdAt"`
    UpdatedAt       time.Time    `json:"updatedAt"`
}

type DeviceStatus int
const (
    DeviceStatusInactive DeviceStatus = 0 // 未激活
    DeviceStatusOnline    DeviceStatus = 1 // 在线
    DeviceStatusOffline   DeviceStatus = 2 // 离线
    DeviceStatusDisabled  DeviceStatus = 3 // 禁用
)
```

#### 2.6.4 DeviceProperty 模型

```go
type DeviceProperty struct {
    ID         int64     `gorm:"primaryKey" json:"id"`
    DeviceID   string    `gorm:"uniqueIndex:idx_device_property;size:64" json:"deviceId"`
    PropertyID string    `gorm:"uniqueIndex:idx_device_property;size:64" json:"propertyId"`
    Value      string    `gorm:"type:text" json:"value"`           // JSON格式
    ReportedAt time.Time `gorm:"index" json:"reportedAt"`
    CreatedAt  time.Time `json:"createdAt"`
    UpdatedAt  time.Time `json:"updatedAt"`
}
```

#### 2.6.5 DeviceEvent 模型

```go
type DeviceEvent struct {
    ID        int64     `gorm:"primaryKey" json:"id"`
    DeviceID  string    `gorm:"index;size:64" json:"deviceId"`
    EventType string    `gorm:"index;size:64" json:"eventType"` // online/offline/alert/property_report
    Payload   string    `gorm:"type:text" json:"payload"`       // JSON格式
    CreatedAt time.Time `gorm:"index" json:"createdAt"`
}
```

---

### 2.7 离线检测机制

**功能描述**:
- 定时扫描在线设备
- 检查 LastOnlineAt 时间
- 超过 30 秒未活动标记为离线

**实现**:
```go
// 每 30 秒执行一次
func (s *DeviceService) CheckOfflineDevices(timeout time.Duration) ([]string, error) {
    devices, _ := s.deviceRepo.FindByStatus(DeviceStatusOnline)

    for _, device := range devices {
        if time.Now().Sub(*device.LastOnlineAt) > timeout {
            s.deviceRepo.UpdateStatus(device.DeviceID, DeviceStatusOffline)
        }
    }
}
```

---

### 2.8 环境配置

#### 2.8.1 配置项

| 配置项 | 默认值 | 说明 |
|-------|--------|------|
| DB_HOST | localhost | MySQL 地址 |
| DB_PORT | 3306 | MySQL 端口 |
| DB_USER | root | MySQL 用户 |
| DB_PASSWORD | root123456 | MySQL 密码 |
| DB_NAME | iot_platform | 数据库名 |
| REDIS_HOST | localhost | Redis 地址 |
| REDIS_PORT | 6379 | Redis 端口 |
| REDIS_DEVICE_TTL | 120 | 设备在线 TTL (秒) |
| SERVER_PORT | 48080 | 服务端口 |
| MQTT_PORT | 1883 | MQTT 端口 |
| MQTT_WS_PORT | 8083 | MQTT WebSocket 端口 |
| JWT_SECRET | dev-secret | JWT 密钥 |
| JWT_EXPIRE_HOURS | 168 | Token 过期时间 (小时) |

#### 2.8.2 Docker 部署

**生产环境** (docker-compose.yml):
```yaml
services:
  iot-platform:
    image: docker.io/luoyaosheng/open-iot-platform:latest
    environment:
      DB_HOST: mysql
      REDIS_HOST: redis
    ports:
      - "48080:48080"
      - "1883:1883"
      - "8083:8083"
```

**开发环境** (docker-compose.dev.yml):
```yaml
services:
  iot-platform:
    build: .
    volumes:
      - ./internal:/app/internal
    environment:
      GIN_MODE: debug
```

---

## 3. API 响应规范

### 3.1 统一响应格式

**成功响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {...}
}
```

**错误响应**:
```json
{
  "code": 400,
  "message": "error_message",
  "data": null
}
```

### 3.2 状态码

| 状态码 | 说明 |
|-------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器错误 |

---

## 4. 安全要求

### 4.1 认证方式

| 场景 | 认证方式 |
|------|---------|
| 用户登录 | JWT Token |
| 设备集成 | API Key |
| 设备 MQTT | Username/Password |

### 4.2 密码要求

- 最小长度 8 位
- bcrypt 加密存储
- 不返回密码

---

**修改历史**

| 日期 | 版本 | 修改内容 | 作者 |
|------|------|----------|------|
| 2026-01-10 | v0.3.0 | 初始版本 | 罗耀生 |
