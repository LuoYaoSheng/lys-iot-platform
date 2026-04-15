# 服务端开发指南

> Open IoT Platform 服务端基于 Go + Gin 构建，提供设备管理、MQTT 鉴权、物模型定义等核心能力。

## 技术栈概览

| 组件 | 技术选型 | 说明 |
|------|---------|------|
| 语言 | Go 1.22+ | 高性能后端语言 |
| 框架 | Gin | HTTP 路由与中间件 |
| ORM | GORM | 数据库操作 |
| 数据库 | MySQL 8.x | 数据持久化 |
| 缓存 | Redis 7.x | 在线状态缓存、会话管理 |
| MQTT Broker | 内置 (mochi-mqtt) | 设备消息路由，无需外部 EMQX |
| 部署 | Docker + Docker Compose | 容器化部署 |

## 项目结构

```
server/
├── cmd/
│   └── server/          # 入口：main.go
├── internal/
│   ├── config/          # 配置加载（.env → 结构体）
│   ├── handler/         # HTTP 处理器（Gin HandlerFunc）
│   ├── model/           # 数据模型（GORM Model）
│   ├── repository/      # 数据访问层（SQL 操作）
│   ├── service/         # 业务逻辑层
│   ├── mqtt/            # MQTT Broker 内置逻辑
│   └── redis/           # Redis 缓存操作
├── pkg/
│   └── response/        # 统一响应封装
├── scripts/
│   ├── init.sql         # 数据库初始化
│   └── run-device-sim.sh  # 设备模拟器
├── docs/                # 内部运维文档
├── Makefile             # 构建与开发命令
├── docker-compose.yml   # 生产模式编排
└── docker-compose.dev.yml  # 开发模式编排
```

### 分层架构

```
Handler (HTTP 入口)
  │
  ├── 参数校验 & 绑定
  │
Service (业务逻辑)
  │
  ├── 编排业务流程
  ├── 事务管理
  │
Repository (数据访问)
  │
  ├── GORM 查询构建
  ├── SQL 执行
  │
Model (数据模型)
```

## 本地开发环境搭建

### 前置条件

- Go 1.22+
- Docker & Docker Compose
- Make（或直接使用 Go 命令）

### 1. 启动基础设施

开发模式只启动 MySQL、Redis 等基础服务，后端手动运行以便调试：

```bash
cd server
make dev-infra-up
```

### 2. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env，确认数据库连接等配置正确
```

关键配置项：

```env
# 数据库
DB_HOST=localhost
DB_PORT=48306
DB_USER=root
DB_PASSWORD=root123456
DB_NAME=iot_platform

# Redis
REDIS_HOST=localhost
REDIS_PORT=48379

# MQTT Broker（内置）
MQTT_BROKER=localhost
MQTT_PORT=48883
MQTT_WS_PORT=48803

# 服务端口
SERVER_PORT=48080
```

### 3. 运行后端

```bash
# 方式一：直接运行（支持热重载）
go run ./cmd/server

# 方式二：Make 命令
make run

# 方式三：构建后运行
make build
./bin/iot-core
```

### Makefile 常用命令

| 命令 | 说明 |
|------|------|
| `make dev-infra-up` | 启动开发基础设施（MySQL + Redis） |
| `make dev-infra-down` | 停止开发基础设施 |
| `make run` | 运行后端服务 |
| `make build` | 编译二进制文件 |
| `make test` | 运行测试 |
| `make docker-up` | Docker 生产模式一键启动 |
| `make run-device-sim` | 启动设备模拟器 |

## 核心模块说明

### Handler — HTTP 入口

位于 `internal/handler/`，每个 Handler 对应一组 REST API：

```go
// 路由注册示例
func RegisterRoutes(r *gin.Engine) {
    api := r.Group("/api/v1")
    {
        // 设备管理
        api.POST("/devices/register", deviceHandler.Register)
        api.GET("/devices", deviceHandler.List)
        api.GET("/devices/:id", deviceHandler.Get)

        // 产品管理
        api.POST("/products", productHandler.Create)
        api.GET("/products", productHandler.List)

        // MQTT 认证
        api.POST("/mqtt/auth", mqttHandler.Authenticate)
        api.POST("/mqtt/acl", mqttHandler.Authorize)

        // 控制指令
        api.POST("/control", controlHandler.SendCommand)
    }
}
```

### Service — 业务逻辑

位于 `internal/service/`，封装核心业务规则：

- **设备生命周期**：注册 → 激活 → 在线 → 离线 → 删除
- **MQTT 凭证**：基于 ProductKey + DeviceSecret 生成设备凭证
- **状态同步**：定时从 Broker 同步设备在线状态到 Redis

### Repository — 数据访问

位于 `internal/repository/`，使用 GORM 进行数据库操作：

```go
type DeviceRepository interface {
    Create(ctx context.Context, device *model.Device) error
    FindBySN(ctx context.Context, sn string) (*model.Device, error)
    UpdateStatus(ctx context.Context, id uint, status string) error
    ListByProduct(ctx context.Context, productKey string) ([]model.Device, error)
}
```

## MQTT Broker 内置方案

v0.3.0 起服务端内置了 mochi-mqtt Broker，无需外部 EMQX：

- **TCP 端口**：48883（容器外映射）
- **WebSocket 端口**：48803
- **Dashboard**：48884
- **认证**：通过 HTTP 回调到 `/api/v1/mqtt/auth` 验证设备凭证
- **ACL**：通过 HTTP 回调到 `/api/v1/mqtt/acl` 控制主题访问权限

### 设备认证流程

```
设备 CONNECT (username=ProductKey&DeviceId, password=DeviceSecret)
  │
  └→ Broker 回调 /api/v1/mqtt/auth
       │
       └→ Service 验证凭证
            │
            ├── 有效 → 允许连接 + 更新 Redis 在线状态
            └── 无效 → 拒绝连接
```

## 设备模拟器

开发时可使用内置模拟器测试：

```bash
# 默认模拟一个 SIM-EMU-* 设备
make run-device-sim

# 自定义参数
API_BASE_URL=http://127.0.0.1:48080 \
PRODUCT_KEY=SW-SERVO-001 \
DEVICE_SN=SIM-EMU-002 \
BROKER_URL=tcp://127.0.0.1:48883 \
bash ./scripts/run-device-sim.sh
```

## 开发模式 vs 生产模式

| 特性 | 开发模式 | 生产模式 |
|------|---------|---------|
| 后端运行方式 | `go run ./cmd/server` | Docker 容器 |
| 基础设施 | `docker-compose.dev.yml` | `docker-compose.yml` |
| 热重载 | ✅ 支持 | ❌ |
| 断点调试 | ✅ 支持 | ❌ |
| 适用场景 | 日常开发 | 部署/演示 |

切换方式：

```bash
# 开发 → 生产
docker compose -f docker-compose.dev.yml down
docker compose up -d

# 生产 → 开发
docker compose down
make dev-infra-up
go run ./cmd/server
```

## 测试

```bash
# 运行所有测试
make test

# 运行指定包的测试
go test -v ./internal/service/...

# 查看覆盖率
go test -cover ./...
```

## 相关文档

- [API 参考](/API_REFERENCE) — 完整 REST API 文档
- [部署与运维](/DEPLOYMENT_GUIDE) — 生产环境部署指南
- [数据流架构](/ARCHITECTURE_DATA_FLOW) — 全链路数据流说明
- [故障排查](/TROUBLESHOOTING) — 常见问题与解决方案
