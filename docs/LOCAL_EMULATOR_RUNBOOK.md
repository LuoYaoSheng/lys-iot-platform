# 本地联调 Runbook（Android 模拟器）

## 适用场景

用于在本机完成以下链路联调：

1. Go 后端
2. MySQL / Redis / EMQX
3. Android 模拟器中的 Flutter App
4. 本地 MQTT 模拟设备

当前默认端口：

- API: `48080`
- MySQL: `48306`
- Redis: `48379`
- MQTT: `48883`
- MQTT WebSocket: `48803`
- EMQX Dashboard / API: `48884`

## 启动顺序

### 1. 启动基础设施

在 `server/` 下执行：

```bash
make dev-infra-up
```

确认容器状态：

```bash
docker-compose -f docker-compose.dev.yml ps
```

### 2. 启动后端

```bash
cd server
go run ./cmd/server
```

健康检查：

```bash
curl http://127.0.0.1:48080/health
```

### 3. 启动本地模拟设备

```bash
cd server
make run-device-sim
```

默认会激活并保持在线：

- `productKey`: `SW-SERVO-001`
- `deviceSN`: 自动生成，例如 `SIM-EMU-1711630000`

如果你希望复用同一台模拟设备，请显式指定：

```bash
DEVICE_SN=SIM-EMU-001 make run-device-sim
```

## Android 模拟器配置

Android Emulator 访问宿主机必须使用 `10.0.2.2`，不要填 `localhost`。

App 内本地配置应为：

- API URL: `http://10.0.2.2:48080`
- MQTT Host: `10.0.2.2`
- MQTT Port: `48883`

如果需要重新跑干净流程，可清空 App 数据后重启：

```bash
adb -s emulator-5554 shell pm clear com.lys.iot.iot_config_app
```

## 本地测试账号

可使用本地测试账号：

- Email: `emulator.local@example.com`
- Password: `StrongPass1`

如果账号不存在，可重新注册：

```bash
curl -X POST http://127.0.0.1:48080/api/v1/users/register \
  -H "Content-Type: application/json" \
  -d '{"email":"emulator.local@example.com","password":"StrongPass1","name":"Emulator User"}'
```

## 联调验证

### 1. 验证设备列表

登录 App 后应看到：

- `智能开关(舵机版)`
- 设备 ID 如 `dev_xxxxxxxx`
- 状态 `在线`

### 2. 验证控制面板

点开设备后应出现：

- `位置控制`
- `当前位置: 中/上/下`
- `上 / 中 / 下` 三个按钮

### 3. 验证后端状态

```bash
curl -H "Authorization: Bearer <token>" \
  http://127.0.0.1:48080/api/v1/devices/<deviceId>/status
```

期望看到：

- `"online": true`
- `"status": "online"`
- `"position": "up"` 或 `"middle"` 或 `"down"`

## 常见问题

### EMQX API 401

不要用 Dashboard 用户 `admin/public` 直接访问 `/api/v5/*`。本地开发应使用已经创建好的 API key/secret，并写入 `server/.env`。

### 设备显示离线

先确认 `make run-device-sim` 是否仍在运行。如果模拟设备退出，App 中设备会重新变成离线。

### Android 模拟器连不上后端

检查是否错误使用了 `localhost`。模拟器里必须改成 `10.0.2.2`。

### 控制按钮是灰的

这通常表示设备状态仍是离线。先看后端状态接口，再确认模拟设备是否保持 MQTT 长连接。
