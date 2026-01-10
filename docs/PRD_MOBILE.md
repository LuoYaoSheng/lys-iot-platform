# 移动端功能需求文档

**作者**: 罗耀生
**日期**: 2026-01-10
**版本**: v0.3.0

---

## 1. 概述

### 1.1 应用定位

IoT Config App 是一个基于 Flutter 开发的移动端配网与控制应用，为用户提供设备配网、管理和控制的一站式体验。

### 1.2 技术架构

| 模块 | 技术方案 |
|------|---------|
| 开发框架 | Flutter 3.10.1 |
| 状态管理 | Provider |
| 网络通信 | Dio + WebSocket |
| 蓝牙通信 | flutter_blue_plus |
| 本地存储 | SharedPreferences |
| UI 设计 | Material Design 3 |

---

## 2. 功能模块

### 2.1 用户认证模块

#### 2.1.1 登录功能

**页面**: `lib/pages/login_page.dart`

**功能描述**:
- 支持邮箱/密码登录
- 自动读取服务器配置
- 登录成功后保存 Token
- 401 自动跳转登录页

**接口**:
```http
POST /api/v1/users/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password123"
}

Response:
{
  "code": 200,
  "message": "success",
  "data": {
    "user": {...},
    "token": "xxx",
    "refreshToken": "yyy",
    "expiresIn": 86400
  }
}
```

**交互流程**:
```
用户输入邮箱/密码
    │
    ▼
表单验证 (非空、格式)
    │
    ▼
调用登录接口
    │
    ├─ 成功 → 保存Token → 跳转主页
    │
    └─ 失败 → 显示错误提示
```

#### 2.1.2 注册功能

**页面**: `lib/pages/register_page.dart`

**功能描述**:
- 新用户注册
- 邮箱格式验证
- 密码强度校验

**接口**:
```http
POST /api/v1/users/register
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password123",
  "email": "user@example.com"
}
```

#### 2.1.3 Token 刷新

**功能描述**:
- Token 过期自动刷新
- 使用 RefreshToken 获取新 Token
- 刷新失败重新登录

---

### 2.2 设备管理模块

#### 2.2.1 设备列表

**页面**: `lib/pages/device_list_page.dart`

**功能描述**:
- 分页加载设备列表
- 实时显示设备状态
- 根据产品信息显示图标和颜色
- 下拉刷新、上拉加载更多
- 长按删除设备
- 点击查看控制面板

**接口**:
```http
GET /api/v1/devices?page=1&size=20&productKey=xxx&status=1
Authorization: Bearer <token>

Response:
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

**UI 展示**:
```
┌─────────────────────────────────────┐
│  设备列表                 [+ 添加]  │
├─────────────────────────────────────┤
│  🟢 客厅开关        在线           │
│  产品: Smart Servo Switch           │
│  固件: 1.0.0                        │
├─────────────────────────────────────┤
│  🔴 卧室开关        离线 2小时前   │
│  产品: Smart Servo Switch           │
│  固件: 0.9.0                        │
└─────────────────────────────────────┘
```

#### 2.2.2 设备详情

**页面**: `lib/pages/control_page.dart`

**功能描述**:
- 显示设备基本信息
- 动态渲染控制面板
- 实时显示设备状态

**接口**:
```http
GET /api/v1/devices/:deviceId/status
Authorization: Bearer <token>

Response:
{
  "code": 200,
  "data": {
    "deviceId": "dev_xxx",
    "deviceName": "客厅开关",
    "online": true,
    "position": "up",
    "lastOnlineAt": "2026-01-10T10:30:00Z"
  }
}
```

#### 2.2.3 设备删除

**功能描述**:
- 长按设备卡片
- 弹出删除确认对话框
- 调用删除接口

**接口**:
```http
DELETE /api/v1/devices/:deviceId
Authorization: Bearer <token>
```

---

### 2.3 BLE 配网模块

#### 2.3.1 设备扫描

**页面**: `lib/pages/scan_page.dart`

**功能描述**:
- 扫描附近 BLE 设备
- 过滤支持的设备类型
- 显示设备信号强度
- 权限请求处理

**支持设备**:
- `IoT-Switch-XXXX` - 舵机开关
- `IoT-Wakeup-XXXX` - USB 唤醒设备

**BLE UUID**:
```
Service UUID: 0000FFE0-0000-1000-8000-00805F9B34FB
WiFi Char:    0000FFE1-0000-1000-8000-00805F9B34FB
Status Char:  0000FFE2-0000-1000-8000-00805F9B34FB
```

#### 2.3.2 WiFi 配置

**页面**: `lib/pages/config_page.dart`

**功能描述**:
- 选择本地 WiFi
- 输入 WiFi 密码
- 发送配置到设备
- 实时显示配网进度

**配置数据格式**:
```json
{
  "ssid": "YourWiFi",
  "password": "YourPassword",
  "apiUrl": "http://192.168.1.100:48080"
}
```

**配网状态**:
```dart
enum ConfigStatus {
  idle,              // 等待配网
  connecting,        // 正在连接设备
  sendingConfig,     // 正在发送配置
  waitingWifi,       // 等待WiFi连接
  wifiConnected,     // WiFi连接成功
  activating,        // 正在激活
  activated,         // 配网成功
  error             // 配网失败
}
```

**配网流程**:
```
APP 扫描 BLE 设备
    │
    ▼
连接设备 (UUID: FFE0)
    │
    ▼
发送 WiFi 配置 (写入 FFE1)
    │
    ▼
等待设备连接 WiFi
    │
    ▼
设备激活到平台
    │
    ▼
配网完成，添加到设备列表
```

#### 2.3.3 配网状态反馈

**设备状态通知**:
```json
{
  "status": "received|wifi_connected|activated|error",
  "message": "详细信息"
}
```

**状态指示**:
| 状态 | 进度 | 提示 |
|------|------|------|
| received | 20% | 已接收配置 |
| wifi_connected | 60% | WiFi 连接成功 |
| activated | 100% | 设备激活成功 |
| error | - | 配网失败，请重试 |

---

### 2.4 设备控制模块

#### 2.4.1 动态控制面板

**组件**: `lib/widgets/control_panels/control_panel_factory.dart`

**功能描述**:
- 根据产品信息动态创建控制面板
- 支持多种控制模式
- 统一的状态管理

**面板选择逻辑**:
```dart
// 优先级: uiTemplate > controlMode
switch (uiTemplate) {
  case 'servo':
    return SwitchServoPanel();      // 舵机混合控制
  case 'wakeup':
    return UsbWakeupPanel();         // USB 唤醒
  case 'switch':
    switch (controlMode) {
      case 'toggle':
        return SwitchTogglePanel();  // 开关切换
      case 'pulse':
        return SwitchPulsePanel();    // 脉冲触发
      case 'readonly':
        return SensorDisplayPanel(); // 传感器显示
      default:
        return GenericPanel();        // 通用面板
    }
  default:
    return GenericPanel();
}
```

#### 2.4.2 舵机混合控制面板

**组件**: `lib/widgets/control_panels/servo_switch_panel.dart`

**适用产品**: `uiTemplate: 'servo'`

**功能描述**:
- 三档位置切换 (上/中/下)
- 脉冲触发功能
- 实时位置显示

**控制协议**:
```json
// 位置切换
{
  "action": "toggle",
  "position": "up"     // up / middle / down
}

// 脉冲触发
{
  "action": "pulse",
  "duration": 500      // 毫秒
}
```

#### 2.4.3 USB 唤醒面板

**组件**: `lib/widgets/control_panels/usb_wakeup_panel.dart`

**适用产品**: `uiTemplate: 'wakeup'`

**功能描述**:
- 单键触发
- 唤醒状态反馈

**控制协议**:
```json
{
  "action": "trigger"
}
```

#### 2.4.4 开关切换面板

**组件**: `lib/widgets/control_panels/switch_toggle_panel.dart`

**适用产品**: `controlMode: 'toggle'`

**功能描述**:
- 开关状态切换
- 位置保持

#### 2.4.5 脉冲触发面板

**组件**: `lib/widgets/control_panels/switch_pulse_panel.dart`

**适用产品**: `controlMode: 'pulse'`

**功能描述**:
- 触发后自动恢复
- 可配置延迟时间

#### 2.4.6 控制接口

**接口**:
```http
POST /api/v1/devices/:deviceId/control
Authorization: Bearer <token>
Content-Type: application/json

{
  "action": "toggle",
  "position": "up"
}

Response:
{
  "code": 200,
  "message": "success",
  "data": {
    "message": "command_sent"
  }
}
```

---

### 2.5 系统设置模块

#### 2.5.1 服务器配置

**页面**: `lib/pages/settings_page.dart`

**功能描述**:
- 配置 API 服务器地址
- 配置 MQTT 服务器地址
- 本地持久化存储

**配置项**:
| 配置项 | 默认值 | 说明 |
|-------|--------|------|
| API 地址 | http://localhost:48080 | API 服务地址 |
| MQTT 地址 | localhost:1883 | MQTT 地址 |

#### 2.5.2 用户信息

**功能描述**:
- 显示登录用户信息
- 退出登录
- 清除本地缓存

---

### 2.6 状态管理

#### 2.6.1 DeviceProvider

**文件**: `lib/providers/device_provider.dart`

**功能描述**:
- 全局设备状态管理
- 设备列表管理
- 加载状态管理
- 错误状态管理

**状态**:
```dart
class DeviceState {
  List<Device> devices;           // 设备列表
  bool isLoading;                 // 加载中
  String? errorMessage;           // 错误信息
  ConfigStatus configStatus;      // 配网状态
}
```

#### 2.6.2 AuthProvider

**文件**: `lib/providers/auth_provider.dart`

**功能描述**:
- 登录状态管理
- Token 管理
- 用户信息管理

---

### 2.7 数据模型

#### 2.7.1 Device 模型

**文件**: `lib/models/device.dart`

```dart
class Device {
  String deviceId;           // 设备唯一标识
  String deviceSn;          // 设备序列号
  String productKey;        // 产品标识
  String name;              // 设备名称
  int status;               // 设备状态 (0:未激活, 1:在线, 2:离线, 3:禁用)
  String statusText;        // 状态文本
  String? firmwareVersion;  // 固件版本
  String? chipModel;        // 芯片型号
  String? lastOnlineAt;     // 最后在线时间
  String? activatedAt;      // 激活时间
  String createdAt;         // 创建时间

  // 产品信息
  ProductInfo? product;     // 产品详情

  // 计算属性
  bool get isOnline => status == 1;
  bool get isOffline => status == 2;
}
```

#### 2.7.2 ProductInfo 模型

```dart
class ProductInfo {
  int id;
  String productKey;
  String name;
  String? description;
  String? category;
  String? controlMode;      // toggle/pulse/dimmer/readonly/generic
  String? uiTemplate;       // UI模板名称
  String? iconName;         // Material Icons
  String? iconColor;        // HEX颜色
  String? manufacturer;
  String? model;
}
```

---

## 3. UI/UX 设计

### 3.1 设计规范

**主题**: Material Design 3
**主色调**: 蓝色系
**字体**: 系统默认

### 3.2 页面导航

```
SplashPage
    │
    ├─ 未登录 → LoginPage ↔ RegisterPage
    │
    └─ 已登录 → DeviceListPage
                      │
                      ├─ ScanPage → ConfigPage
                      │
                      ├─ ControlPage (点击设备)
                      │
                      └─ SettingsPage
```

### 3.3 设备状态指示

| 状态 | 图标 | 颜色 |
|------|------|------|
| 在线 | 🟢 | 绿色 |
| 离线 | 🔴 | 红色 |
| 未激活 | ⚪ | 灰色 |
| 禁用 | 🚫 | 橙色 |

---

## 4. 权限说明

### 4.1 必需权限

| 权限 | 用途 |
|------|------|
| BLUETOOTH_SCAN | 扫描 BLE 设备 |
| BLUETOOTH_CONNECT | 连接 BLE 设备 |
| ACCESS_FINE_LOCATION | 获取 WiFi 信息 |

### 4.2 权限请求时机

- 首次打开应用
- 点击添加设备

---

## 5. 错误处理

### 5.1 网络错误

| 错误类型 | 处理方式 |
|---------|---------|
| 超时 | 提示"网络超时，请重试" |
| 连接失败 | 提示"网络连接失败" |
| 401 | 跳转登录页 |
| 403 | 提示"无权限" |
| 500 | 提示"服务器错误" |

### 5.2 BLE 错误

| 错误类型 | 处理方式 |
|---------|---------|
| 蓝牙未开启 | 提示开启蓝牙 |
| 权限拒绝 | 引导开启权限 |
| 连接失败 | 提示重试 |
| 配置失败 | 提示检查WiFi密码 |

---

## 6. 性能要求

| 指标 | 要求 |
|------|------|
| 应用启动 | < 2 秒 |
| 设备列表加载 | < 1 秒 |
| BLE 扫描延迟 | < 3 秒 |
| 控制响应 | < 500ms |

---

**修改历史**

| 日期 | 版本 | 修改内容 | 作者 |
|------|------|----------|------|
| 2026-01-10 | v0.3.0 | 初始版本 | 罗耀生 |
