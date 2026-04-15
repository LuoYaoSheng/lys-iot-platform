# 部署与运维

> Open IoT Platform 部署指南，涵盖 Docker 部署、环境配置、安全加固和日常运维。

## Docker Compose 部署

### 极简版部署（推荐入门）

适合快速体验和开发测试。

```bash
# 1. 克隆代码
git clone https://github.com/LuoYaoSheng/open-iot-platform.git
cd open-iot-platform/server

# 2. 配置环境变量
cp .env.simple .env
# 编辑 .env，只需修改 SERVER_IP 为你的服务器 IP 或域名

# 3. 一键启动
docker compose up -d
```

部署完成后的服务地址：

| 服务 | 地址 | 说明 |
|------|------|------|
| Core API | `http://localhost:48080` | 设备引擎 API |
| MQTT TCP | `localhost:48883` | MQTT 服务 |
| MQTT WebSocket | `localhost:48803` | MQTT WebSocket |
| MQTT Dashboard | `http://localhost:48884` | MQTT 管理 (admin/public) |
| MySQL | `localhost:48306` | 数据库 (root/root123456) |
| Redis | `localhost:48379` | 缓存服务 |

### 完整版部署（生产推荐）

包含所有服务组件，适合正式环境。

```bash
cd server

# 1. 配置环境变量
cp .env.example .env
vi .env  # 按需修改所有配置项

# 2. 启动所有服务
docker compose up -d

# 3. 查看服务状态
docker compose ps
```

### 数据库自动初始化

v0.3.0+ 已内置数据库自动初始化：

- 应用启动时自动检查产品表是否为空
- 如果为空，自动插入默认产品数据
- **无需手动执行 SQL 脚本**

验证初始化成功：

```bash
docker compose logs -f iot-core | grep -E "(Checking default data|Created product)"
```

## 环境变量配置

### 核心配置

```env
# 服务器
SERVER_IP=192.168.1.100        # 服务器公网 IP 或域名
SERVER_PORT=48080               # API 端口

# 数据库
DB_HOST=mysql                   # Docker 内使用服务名
DB_PORT=3306                    # 容器内部端口
DB_USER=root
DB_PASSWORD=root123456          # ⚠️ 生产环境务必修改
DB_NAME=iot_platform

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# MQTT Broker（内置）
MQTT_BROKER=localhost
MQTT_PORT=48883
MQTT_WS_PORT=48803
MQTT_BROKER_EXTERNAL=你的服务器IP  # ESP32 设备连接用

# JWT
JWT_SECRET=your-jwt-secret      # ⚠️ 生产环境务必使用随机密钥
JWT_EXPIRE_HOURS=2
```

### Docker 端口映射

| 容器端口 | 映射端口 | 服务 |
|----------|---------|------|
| 48080 | 48080 | Core API |
| 1883 | 48883 | MQTT TCP |
| 8083 | 48803 | MQTT WebSocket |
| 18083 | 48884 | MQTT Dashboard |
| 3306 | 48306 | MySQL |
| 6379 | 48379 | Redis |

## 生产环境安全加固

### 1. 修改默认密码

```bash
# 生成随机密码
openssl rand -base64 16 | tr -d "=+/" | cut -c1-16

# 生成 JWT 密钥
JWT_SECRET=$(openssl rand -base64 32)
echo "JWT_SECRET=$JWT_SECRET" >> .env
```

**必须修改的默认密码**：

- MySQL root 密码
- MQTT Dashboard 登录密码
- JWT 密钥

### 2. 防火墙配置

只开放必要端口：

```bash
# Ubuntu (UFW)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp         # SSH
sudo ufw allow 48080/tcp      # API（公开）
sudo ufw allow 48883/tcp      # MQTT（公开）
sudo ufw allow from 你的IP to any port 48884  # Dashboard（限制 IP）
sudo ufw enable
```

### 3. SSL/TLS 配置

使用 Nginx 反向代理 + Let's Encrypt：

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;

    location / {
        proxy_pass http://localhost:48080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

自动续期：

```bash
sudo crontab -e
# 每月 1 号凌晨 3 点续期
0 3 1 * * certbot renew --quiet && systemctl reload nginx
```

### 4. 数据库安全

- 默认配置不对外暴露 MySQL 端口
- 如需远程管理，使用 SSH 端口转发：

```bash
ssh -L 48306:localhost:48306 user@your_server_ip
```

## 端口规划

### 标准端口方案（v0.3.0）

| 端口 | 服务 | 协议 | 开放级别 |
|------|------|------|---------|
| 48080 | Core API | HTTP | 公开 |
| 48883 | MQTT Broker | TCP | 公开（设备连接） |
| 48803 | MQTT WebSocket | WS | 公开 |
| 48884 | MQTT Dashboard | HTTP | 受限（仅管理员 IP） |
| 48306 | MySQL | TCP | 内部 |
| 48379 | Redis | TCP | 内部 |

## 常用运维命令

```bash
# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f              # 所有服务
docker compose logs -f iot-core     # 后端服务
docker compose logs -f mysql        # 数据库

# 重启服务
docker compose restart iot-core

# 停止所有服务
docker compose down

# 更新镜像并重启
docker compose pull
docker compose up -d --force-recreate

# 数据库备份
docker exec iot-platform_mysql mysqldump -uroot -proot123456 iot_platform > backup.sql

# 数据库恢复
docker exec -i iot-platform_mysql mysql -uroot -proot123456 iot_platform < backup.sql
```

### 定期维护

```bash
# 每日：检查服务健康
docker compose ps && docker compose logs --tail 50 | grep -i error

# 每周：清理 Docker 资源
docker system prune -f

# 每月：更新镜像
docker compose pull && docker compose up -d
```

## 安全检查清单

- [ ] 所有默认密码已修改
- [ ] JWT 密钥使用随机生成
- [ ] 防火墙规则已配置
- [ ] Dashboard 仅限管理员 IP 访问
- [ ] MySQL 不对外暴露
- [ ] SSL/TLS 证书已配置（生产环境）
- [ ] 数据库定期备份已设置
- [ ] SSH 密钥登录已启用

## 常见部署问题

### 端口被占用

```bash
# 检查端口占用
lsof -i :48080

# 修改 docker-compose.yml 中的端口映射
ports:
  - "48081:48080"  # 改为其他端口
```

### 镜像拉取失败

```bash
# 手动拉取
docker pull luoyaosheng/iot-platform-core:latest

# 使用阿里云镜像加速器
# 在 Docker 配置中添加 registry-mirrors
```

### 服务启动失败

```bash
# 查看日志定位问题
docker compose logs iot-core

# 常见原因：
# 1. 数据库未就绪 → 等待几秒后重启
# 2. 端口冲突 → 修改端口映射
# 3. 环境变量配置错误 → 检查 .env 文件
```

## 相关文档

- [故障排查](/TROUBLESHOOTING) — 常见问题解决方案
- [服务端开发指南](/SERVER_GUIDE) — 本地开发环境搭建
- [快速开始](/QUICK_START_DOCKER) — Docker 一键部署
- [发布指南](/RELEASE_GUIDE) — 版本发布流程
