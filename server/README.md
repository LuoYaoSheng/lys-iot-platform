# iot-platform-core

> IoT 中台核心 - 平台地基仓库

## 📋 仓库定位

**IoT 平台的内核，只做基础能力，5年内不应被推翻**

## ✅ 只允许做什么

核心六件事：

1. **用户管理** - 用户注册、登录、API Key
2. **项目管理** - Project 生命周期
3. **产品管理** - Product / 产品型号定义
4. **设备管理** - Device 生命周期与状态
5. **MQTT 鉴权与消息** - 设备接入与消息路由
6. **计费与配额** - 套餐、配额、计费模型

## ❌ 严禁做什么

- ❌ 具体项目业务逻辑
- ❌ UI 界面
- ❌ 规则引擎（业务相关）
- ❌ 某个硬件的特殊逻辑

## 🏗️ 技术栈

- **语言**: Go
- **框架**: Gin / Echo
- **数据库**: MySQL / PostgreSQL
- **缓存**: Redis
- **消息**: MQTT (EMQX)

## 📦 核心模块规划

```
iot-platform-core/
├── internal/
│   ├── auth/          # 认证鉴权
│   ├── user/          # 用户管理
│   ├── project/       # 项目管理
│   ├── product/       # 产品管理
│   ├── device/        # 设备管理
│   ├── mqtt/          # MQTT 服务
│   ├── quota/         # 配额管理
│   └── billing/       # 计费模块
├── api/               # REST API
├── pkg/               # 公共包
└── cmd/               # 入口
```

## 🔗 依赖关系

- **被依赖**: iot-platform-admin, iot-libs-common, apps, firmware
- **依赖**: 无（独立核心）

## 📝 核心数据模型

### User（用户）
- 平台账号
- API Key
- 套餐绑定

### Project（项目）
- 业务隔离单元
- 属于某个 User

### Product（产品）
- 硬件型号定义
- ProductKey
- 设备模板

### Device（设备）
- 唯一设备实例
- DeviceId
- 归属 Product 和 Project

## 🎯 设计原则

1. **克制** - 不做业务，只做基础设施
2. **稳定** - API 向后兼容
3. **解耦** - 与具体项目完全解耦
4. **可扩展** - 支持水平扩展

## 🚀 快速开始

### 本地开发

```bash
# 1. 启动基础设施
make dev-infra-up

# 2. 如需首次生成本地配置
cp .env.example .env

# 3. 启动后端
go run ./cmd/server
```

### 本地设备模拟

用于模拟一个持续在线的 MQTT 设备，方便 Android 模拟器和后端做联调：

```bash
# 默认会激活一个唯一的 SIM-EMU-* 设备并保持在线
make run-device-sim

# 也可以覆盖参数
API_BASE_URL=http://127.0.0.1:48080 \
PRODUCT_KEY=SW-SERVO-001 \
DEVICE_SN=SIM-EMU-002 \
BROKER_URL=tcp://127.0.0.1:48883 \
bash ./scripts/run-device-sim.sh
```

### 生产部署（极简版）

```bash
# 1. 修改配置（只需改IP地址）
cp .env.simple .env
vi .env  # 修改 SERVER_IP

# 2. 一键部署
bash deploy.sh
```

### 发布 Docker 镜像

```bash
# 登录 Docker Hub（首次）
docker login

# 发布镜像
bash publish.sh
```

## 📚 文档导航

### 部署相关
- [📘 部署指南](docs/部署指南.md) - 极简 3 步部署（推荐）
- [📙 镜像发布指南](docs/镜像发布指南.md) - 如何发布 Docker 镜像
- [📗 Docker 详细说明](docs/Docker详细说明.md) - Docker 完整配置说明

### 开发相关
- [📕 开发环境说明](docs/开发环境说明.md) - 开发 vs 生产环境配置
- [📔 安全配置](docs/安全配置.md) - 生产环境安全加固

### 相关仓库
- `iot-platform-docs` - IoT 平台设计白皮书、核心概念定义
- `iot-libs-common` - 公共基础库（Go/Flutter/JS SDK）
- `iot-platform-admin` - 管理后台
- `iot-config-app` - 配网 App

---

**作者**: 罗耀生
**创建时间**: 2025-12-13
**最后更新**: 2025-12-18
