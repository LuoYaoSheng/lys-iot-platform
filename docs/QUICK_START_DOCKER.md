# Docker 一键部署

> 最快体验 Open IoT Platform 完整链路的方式。

## 前置条件

- [Docker](https://docs.docker.com/get-docker/) 已安装
- [Docker Compose](https://docs.docker.com/compose/install/) 已安装

## 一键启动

```bash
# 克隆仓库
git clone https://gitee.com/luoyaosheng/lys-iot-platform.git
cd lys-iot-platform/server

# 启动全部服务
docker compose up -d
```

启动完成后，以下服务将自动运行：

| 服务 | 地址 | 说明 |
|------|------|------|
| Core API | http://localhost:48080 | 设备引擎 API |
| MQTT Broker | localhost:48883 | MQTT 服务（内置） |
| MQTT WebSocket | localhost:48803 | MQTT WebSocket 接入 |
| MySQL | localhost:48306 | 数据库（root/root123456） |
| Redis | localhost:48379 | 缓存服务 |

## 验证服务状态

```bash
# 检查所有容器是否运行
docker compose ps

# 测试 API 是否可用
curl http://localhost:48080/api/v1/products
```

## 下一步

服务跑起来之后，你可以：

1. **使用移动端 APP** — 通过 BLE 配网连接真实设备（见 [快速开始](./START_HERE)）
2. **查看 API 文档** — 阅读 [API 参考](./API_REFERENCE) 了解接口能力
3. **理解架构** — 阅读 [仓库架构](./REPOSITORY_ARCHITECTURE) 和 [数据流架构](./ARCHITECTURE_DATA_FLOW)
4. **本地联调** — 按照 [本地模拟器 Runbook](./LOCAL_EMULATOR_RUNBOOK) 进行深度调试

## 停止服务

```bash
docker compose down

# 如需清除数据
docker compose down -v
```

## 常见问题

### 端口冲突

如果本机已占用上述端口，可以修改 `server/docker-compose.yml` 中的端口映射。

### 数据持久化

MySQL 和 Redis 的数据通过 Docker Volume 持久化，`docker compose down` 不会丢失数据。如需完全清除，使用 `docker compose down -v`。
