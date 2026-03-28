# 监控与日志指南

作者：罗耀生
最后更新：2025-12-16

---

## 📋 目录

- [监控概述](#监控概述)
- [日志管理](#日志管理)
- [容器监控](#容器监控)
- [应用监控](#应用监控)
- [数据库监控](#数据库监控)
- [MQTT监控](#mqtt监控)
- [告警配置](#告警配置)
- [性能分析](#性能分析)

---

## 监控概述

### 监控指标体系

```
系统监控
├── 基础设施层
│   ├── CPU使用率
│   ├── 内存使用率
│   ├── 磁盘使用率
│   └── 网络流量
├── 服务层
│   ├── 容器状态
│   ├── 服务可用性
│   └── 进程状态
├── 应用层
│   ├── API响应时间
│   ├── 请求成功率
│   ├── 并发连接数
│   └── 业务指标
└── 数据层
    ├── 数据库连接数
    ├── 查询性能
    └── 存储空间
```

### 监控目标

- **可用性**：服务正常运行时间 > 99.9%
- **响应时间**：API平均响应 < 200ms
- **错误率**：请求错误率 < 0.1%
- **资源使用**：CPU < 70%, 内存 < 80%

---

## 日志管理

### 日志级别

| 级别 | 说明 | 使用场景 |
|------|------|---------|
| DEBUG | 调试信息 | 开发环境 |
| INFO | 一般信息 | 生产环境默认 |
| WARN | 警告信息 | 潜在问题 |
| ERROR | 错误信息 | 需要关注的错误 |

### 查看日志

#### Docker部署

```bash
# 查看所有服务日志
docker-compose logs

# 查看特定服务
docker-compose logs backend
docker-compose logs mysql
docker-compose logs emqx

# 实时跟踪日志
docker-compose logs -f backend

# 查看最近N行
docker-compose logs --tail=100 backend

# 查看时间戳
docker-compose logs -t backend

# 组合使用
docker-compose logs -f --tail=50 -t backend
```

#### 手动部署

```bash
# systemd服务日志
sudo journalctl -u iot-platform

# 实时跟踪
sudo journalctl -u iot-platform -f

# 查看最近N行
sudo journalctl -u iot-platform -n 100

# 查看指定时间范围
sudo journalctl -u iot-platform --since "2025-12-16 10:00:00"
```

### 日志过滤

```bash
# 按关键字过滤
docker-compose logs backend | grep "ERROR"
docker-compose logs backend | grep "MQTT"

# 排除某些内容
docker-compose logs backend | grep -v "health check"

# 多条件过滤
docker-compose logs backend | grep -E "ERROR|WARN"

# 统计错误数量
docker-compose logs backend | grep "ERROR" | wc -l
```

### 日志标记说明

#### 后端服务日志标记

- `[Server]` - 服务器启动和关闭
- `[Database]` - 数据库连接和操作
- `[MQTT]` - MQTT客户端连接
- `[EMQX]` - EMQX API调用
- `[DeviceSync]` - 设备状态同步
- `[Webhook]` - Webhook事件处理
- `[Auth]` - 认证和授权
- `[API]` - HTTP API请求

#### 示例日志

```log
2025-12-16 10:30:00 [Server] Starting server on :8080
2025-12-16 10:30:01 [Database] Database connected
2025-12-16 10:30:02 [MQTT] MQTT client connected
2025-12-16 10:30:03 [EMQX] API连接测试成功
2025-12-16 10:30:04 [DeviceSync] 开始同步设备在线状态...
2025-12-16 10:30:05 [DeviceSync] 同步完成: 在线=5, 离线=2
2025-12-16 10:35:00 [Webhook] 客户端事件: client.connected, clientId=ESP32_001
2025-12-16 10:35:01 [DeviceSync] 更新设备状态: ESP32_001 -> online
```

### 日志轮转

#### Docker部署日志轮转

编辑 `docker-compose.yml`：

```yaml
services:
  backend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"      # 单个日志文件最大10MB
        max-file: "3"        # 保留最近3个文件
```

#### 手动部署日志轮转

创建 `/etc/logrotate.d/iot-platform`：

```bash
/var/log/iot-platform/*.log {
    daily                    # 每天轮转
    rotate 7                 # 保留7天
    compress                 # 压缩旧日志
    delaycompress            # 延迟压缩
    missingok               # 文件不存在不报错
    notifempty              # 空文件不轮转
    create 0640 iot iot     # 创建新文件的权限
    postrotate
        systemctl reload iot-platform
    endscript
}
```

### 集中式日志管理

#### 方案1：ELK Stack

**推荐配置**：
- **Elasticsearch**：日志存储和搜索
- **Logstash**：日志收集和处理
- **Kibana**：可视化查询

**Docker Compose扩展**：

```yaml
services:
  elasticsearch:
    image: elasticsearch:8.11.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - es_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"

  kibana:
    image: kibana:8.11.0
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch

  logstash:
    image: logstash:8.11.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    depends_on:
      - elasticsearch
```

#### 方案2：Loki + Grafana

**轻量级替代方案**：

```yaml
services:
  loki:
    image: grafana/loki:2.9.0
    ports:
      - "3100:3100"
    volumes:
      - loki_data:/loki

  promtail:
    image: grafana/promtail:2.9.0
    volumes:
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - ./promtail-config.yml:/etc/promtail/config.yml
    command: -config.file=/etc/promtail/config.yml
```

---

## 容器监控

### 查看容器状态

```bash
# 查看所有容器
docker-compose ps

# 查看容器详细信息
docker inspect iot_backend

# 查看容器资源使用
docker stats

# 查看特定容器资源
docker stats iot_backend iot_mysql iot_emqx
```

### 资源使用监控

```bash
# 实时监控
docker stats --no-stream

# 格式化输出
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

**输出示例**：
```
CONTAINER         CPU %     MEM USAGE / LIMIT
iot_backend       2.5%      120MiB / 2GiB
iot_mysql         1.2%      350MiB / 2GiB
iot_emqx          0.8%      200MiB / 2GiB
iot_redis         0.3%      50MiB / 512MiB
```

### 容器健康检查

#### 配置健康检查

```yaml
services:
  backend:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s        # 检查间隔
      timeout: 10s         # 超时时间
      retries: 3           # 重试次数
      start_period: 40s    # 启动等待时间
```

#### 查看健康状态

```bash
# 查看健康状态
docker-compose ps

# 查看健康检查日志
docker inspect --format='{{json .State.Health}}' iot_backend | jq
```

---

## 应用监控

### API性能监控

#### 响应时间统计

**在代码中添加中间件**（已实现示例）：

```go
// internal/middleware/metrics.go
func MetricsMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        path := c.Request.URL.Path

        c.Next()

        duration := time.Since(start)
        status := c.Writer.Status()

        log.Printf("[Metrics] %s %s - %d - %v",
            c.Request.Method, path, status, duration)
    }
}
```

#### 手动测试API性能

```bash
# 使用curl测试响应时间
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8080/api/v1/devices

# curl-format.txt 内容：
#     time_namelookup:  %{time_namelookup}\n
#        time_connect:  %{time_connect}\n
#     time_appconnect:  %{time_appconnect}\n
#    time_pretransfer:  %{time_pretransfer}\n
#       time_redirect:  %{time_redirect}\n
#  time_starttransfer:  %{time_starttransfer}\n
#                     ----------\n
#          time_total:  %{time_total}\n
```

#### 压力测试

```bash
# 使用Apache Bench
ab -n 1000 -c 10 http://localhost:8080/api/v1/health

# 使用wrk
wrk -t4 -c100 -d30s http://localhost:8080/api/v1/health
```

### 业务指标监控

#### 关键业务指标

- **设备统计**：
  - 总设备数
  - 在线设备数
  - 激活设备数
  - 设备上下线频率

- **用户统计**：
  - 活跃用户数
  - API调用次数
  - 认证成功/失败次数

- **消息统计**：
  - MQTT消息吞吐量
  - Webhook调用次数
  - 消息延迟

#### 查询业务指标

```sql
-- 设备统计
SELECT
    COUNT(*) as total_devices,
    SUM(CASE WHEN status = 'online' THEN 1 ELSE 0 END) as online_devices,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_devices
FROM devices;

-- 今日活跃用户
SELECT COUNT(DISTINCT user_id)
FROM auth_logs
WHERE created_at >= CURDATE();

-- 今日设备上线次数
SELECT COUNT(*)
FROM device_events
WHERE event_type = 'online' AND created_at >= CURDATE();
```

---

## 数据库监控

### 连接监控

```sql
-- 查看当前连接
SHOW PROCESSLIST;

-- 查看连接统计
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Max_used_connections';

-- 查看最大连接数配置
SHOW VARIABLES LIKE 'max_connections';
```

### 性能监控

```sql
-- 查看慢查询统计
SHOW STATUS LIKE 'Slow_queries';

-- 查看表锁等待
SHOW STATUS LIKE 'Table_locks_waited';

-- 查看InnoDB状态
SHOW ENGINE INNODB STATUS;
```

### 存储监控

```sql
-- 查看数据库大小
SELECT
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES
GROUP BY table_schema;

-- 查看各表大小
SELECT
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'iot_platform'
ORDER BY (data_length + index_length) DESC;
```

### 备份监控

```bash
# 检查最近备份
ls -lh /opt/backups/mysql/ | head -10

# 验证备份完整性
gunzip -t /opt/backups/mysql/latest.sql.gz
```

---

## MQTT监控

### EMQX Dashboard监控

访问：`http://localhost:48884`

**主要监控页面**：

1. **Overview（概览）**：
   - 节点状态
   - 连接数统计
   - 消息吞吐量

2. **Monitoring → Connections（连接）**：
   - 当前所有连接
   - 按ClientID搜索
   - 查看连接详情

3. **Monitoring → Topics（主题）**：
   - 活跃主题列表
   - 订阅者统计

4. **Monitoring → Subscriptions（订阅）**：
   - 所有订阅关系
   - QoS统计

### EMQX API监控

```bash
# 获取节点信息
curl -u "<API_KEY>:<SECRET>" http://localhost:48884/api/v5/nodes

# 获取连接统计
curl -u "<API_KEY>:<SECRET>" http://localhost:48884/api/v5/stats

# 获取指标
curl -u "<API_KEY>:<SECRET>" http://localhost:48884/api/v5/metrics

# 查询特定客户端
curl -u "<API_KEY>:<SECRET>" "http://localhost:48884/api/v5/clients?clientid=ESP32_001"
```

### 关键MQTT指标

- **connections.count**：当前连接数
- **messages.received**：接收消息数
- **messages.sent**：发送消息数
- **messages.dropped**：丢弃消息数
- **delivery.rate**：消息传输速率

---

## 告警配置

### 告警策略

| 指标 | 阈值 | 级别 | 动作 |
|------|------|------|------|
| CPU使用率 | > 80% | 警告 | 通知 |
| CPU使用率 | > 90% | 严重 | 立即处理 |
| 内存使用率 | > 85% | 警告 | 通知 |
| 磁盘使用率 | > 80% | 警告 | 清理 |
| API错误率 | > 1% | 警告 | 检查 |
| 数据库连接失败 | 任意 | 严重 | 立即处理 |
| MQTT断连 | 任意 | 严重 | 立即处理 |

### 简易告警脚本

```bash
#!/bin/bash
# /opt/monitoring/alert.sh

# 检查后端服务
if ! curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "【告警】后端服务无响应" | mail -s "IoT Platform Alert" admin@example.com
fi

# 检查数据库
if ! docker exec iot_mysql mysqladmin ping -h localhost > /dev/null 2>&1; then
    echo "【告警】数据库无响应" | mail -s "IoT Platform Alert" admin@example.com
fi

# 检查磁盘空间
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "【告警】磁盘使用率${DISK_USAGE}%" | mail -s "IoT Platform Alert" admin@example.com
fi
```

```bash
# 添加到crontab，每5分钟检查一次
*/5 * * * * /opt/monitoring/alert.sh
```

### 高级告警方案

#### Prometheus + Alertmanager

**特点**：
- 强大的查询语言（PromQL）
- 灵活的告警规则
- 多种通知渠道（邮件、Slack、钉钉等）

**配置示例**：

```yaml
# prometheus.yml
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

rule_files:
  - "alerts.yml"

# alerts.yml
groups:
  - name: iot_platform
    rules:
      - alert: HighCPUUsage
        expr: cpu_usage > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
```

---

## 性能分析

### Go程序性能分析

#### 启用pprof

```go
// main.go
import _ "net/http/pprof"

// 在单独的goroutine启动pprof服务器
go func() {
    log.Println(http.ListenAndServe("localhost:6060", nil))
}()
```

#### 使用pprof工具

```bash
# CPU性能分析
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30

# 内存分析
go tool pprof http://localhost:6060/debug/pprof/heap

# goroutine分析
go tool pprof http://localhost:6060/debug/pprof/goroutine

# Web界面查看
go tool pprof -http=:8081 http://localhost:6060/debug/pprof/heap
```

### 数据库性能分析

```sql
-- 启用性能统计
SET GLOBAL performance_schema = ON;

-- 查看最慢的查询
SELECT * FROM sys.statement_analysis
ORDER BY avg_latency DESC
LIMIT 10;

-- 查看表扫描情况
SELECT * FROM sys.statements_with_full_table_scans;
```

---

## 监控最佳实践

### 1. 分层监控

- **基础层**：服务器CPU、内存、磁盘、网络
- **服务层**：容器状态、进程状态
- **应用层**：API性能、业务指标
- **数据层**：数据库性能、存储空间

### 2. 主动监控

- 定期健康检查
- 定时执行监控脚本
- 设置合理的告警阈值
- 及时响应告警

### 3. 日志规范

- 使用统一的日志格式
- 合理设置日志级别
- 添加上下文信息（时间戳、请求ID等）
- 定期清理旧日志

### 4. 性能基准

- 建立性能基准
- 定期压力测试
- 跟踪性能趋势
- 优化性能瓶颈

---

## 推荐工具

### 开源免费

- **Grafana**：可视化监控面板
- **Prometheus**：监控数据收集
- **Loki**：轻量级日志系统
- **Node Exporter**：系统指标收集
- **cAdvisor**：容器监控

### 商业方案

- **Datadog**：全栈监控
- **New Relic**：APM性能监控
- **Sentry**：错误追踪
- **Elastic Cloud**：ELK托管服务

---

**良好的监控体系是保障系统稳定运行的基础！**
