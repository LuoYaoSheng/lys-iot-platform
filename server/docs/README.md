# IoT 平台核心 - 文档中心

> 所有技术文档的索引导航

---

## 📘 部署文档

### [部署指南](./部署指南.md) ⭐ 推荐
**适用场景**: 团队成员快速部署到宝塔服务器

**内容**:
- 3 步完成部署（极简版）
- 只需修改 1 个配置（服务器IP）
- Docker 镜像直接拉取，无需编译

---

### [镜像发布指南](./镜像发布指南.md)
**适用场景**: 开发者发布新版本到 Docker Hub

**内容**:
- 如何发布镜像到 Docker Hub
- 使用阿里云镜像仓库（可选）
- 自建 Docker Registry（可选）
- 一键发布脚本使用

---

### [Docker 详细说明](./Docker详细说明.md)
**适用场景**: 需要深入了解 Docker 配置

**内容**:
- Docker Compose 完整配置说明
- 多环境配置（开发/生产）
- 端口映射、网络配置
- 数据持久化

---

## 📕 开发文档

### [开发环境说明](./开发环境说明.md)
**适用场景**: 本地开发调试

**内容**:
- 开发环境 vs 生产环境区别
- 本地开发配置
- 如何连接本地数据库和 MQTT
- 常见问题解决

---

### [本地模拟联调 Runbook](../../docs/LOCAL_EMULATOR_RUNBOOK.md) ⭐ 推荐
**适用场景**: Android 模拟器 + 本地后端 + 本地模拟设备联调

**内容**:
- 本地端口与启动顺序
- `10.0.2.2` 模拟器访问方式
- 测试账号与设备模拟器
- 控制面板与状态联调验证

---

## 📔 运维文档

### [安全配置](./安全配置.md)
**适用场景**: 生产环境安全加固

**内容**:
- JWT 密钥配置
- 数据库安全
- EMQX 认证配置
- 防火墙和端口安全
- SSL/TLS 配置

---

### [监控与日志](./MONITORING.md)
**适用场景**: 生产环境监控和日志分析

**内容**:
- 日志管理
- 容器监控
- 应用监控
- 数据库监控
- MQTT 监控
- 告警配置

---

### [故障排查](./TROUBLESHOOTING.md)
**适用场景**: 遇到问题时的排查手册

**内容**:
- 常见问题和解决方案
- 后端服务问题
- 数据库问题
- MQTT 连接问题
- EMQX Webhook 问题
- 性能问题

---

## 📗 技术文档

### [EMQX 完整配置指南](./EMQX完整配置指南.md) ⭐ 重要
**适用场景**: 部署后必须完成的 EMQX 配置

**内容**:
- HTTP 认证配置
- HTTP 授权/ACL 配置（控制设备主题访问权限）
- Webhook 配置（设备上下线监听）
- 配置测试和验证
- 常见问题解决

---

### [EMQX Webhook 配置](./EMQX_WEBHOOK.md)
**适用场景**: 配置 EMQX 设备上下线通知（快速版）

**内容**:
- 设备上线 Webhook 配置
- 设备下线 Webhook 配置
- 5 分钟快速配置指南

---

## 🎯 快速链接

### 常用命令

```bash
# 部署相关
bash deploy.sh              # 一键部署
bash publish.sh             # 发布镜像

# Docker 管理
docker compose -f docker-compose.simple.yml ps        # 查看服务状态
docker compose -f docker-compose.simple.yml logs -f   # 查看日志
docker compose -f docker-compose.simple.yml restart   # 重启服务
docker compose -f docker-compose.simple.yml down      # 停止服务
```

### 服务访问地址

- API 服务: `http://你的IP:48080`
- EMQX 控制台: `http://你的IP:48884`
  - 账号: `admin`
  - 密码: `public`

---

## 📦 相关仓库

- [iot-platform-core](../) - 核心后端服务（本仓库）
- [iot-libs-common](../../iot-libs-common/) - 公共基础库
- [iot-platform-admin](../../iot-platform-admin/) - 管理后台
- [iot-platform-docs](../../iot-platform-docs/) - 设计文档
- [iot-config-app](../../iot-config-app/) - 配网 App

---

**维护者**: 罗耀生
**创建时间**: 2025-12-18
