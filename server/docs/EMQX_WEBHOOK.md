# EMQX Webhook 最简配置（5分钟搞定）

作者：罗耀生
日期：2025-12-16

---

## 🚀 超简单配置（3步完成）

后端已经支持EMQX默认格式，**无需自定义Body**！

---

### 第1步：创建设备上线 Webhook

1. 登录 EMQX：`http://localhost:48884`（admin/public）

2. 点击：**Integration（集成）** → **Webhook** → **+ 创建**

3. 填写配置：

   **基本信息**：
   - **Name（名称）**：`device_online`
   - **Enable（启用）**：✅ 勾选

   **触发事件**：
   - **Event（事件）**：选择 `client.connected`（客户端连接）

   **HTTP配置**：
   - **URL**：`http://host.docker.internal:48080/api/v1/webhook/client`
   - **Method（方法）**：`POST`

4. 点击：**保存** 或 **Create**

---

### 第2步：创建设备下线 Webhook

重复第1步，但修改：

- **Name**：`device_offline`
- **Event**：选择 `client.disconnected`（客户端断开）
- **URL**：`http://host.docker.internal:48080/api/v1/webhook/client`（相同）

点击：**保存**

---

### 第3步：测试

**重启ESP32设备**：
1. 断电 → 上电
2. 观察后端日志：`[Webhook] 设备上线`
3. APP刷新：设备显示**在线** ✅

**断开设备**：
1. 拔掉ESP32电源
2. 后端日志：`[Webhook] 设备下线`
3. APP显示：**离线** ⚫

---

## ✅ 配置完成！

就这么简单！后端会自动识别EMQX默认发送的数据格式。

---

## 🔍 验证配置

### 检查Webhook状态

- **Integration** → **Webhook**
- 两个Webhook状态都应该是：**已启用**

### 查看统计

点击Webhook名称，查看：
- **Success（成功）**：应该大于0
- **Failed（失败）**：应该等于0

---

## 🐛 常见问题

### 问题：连接被拒绝（Connection refused）

**Linux用户**：
- 不能用 `host.docker.internal`
- 改用实际IP：

```bash
# 查看宿主机IP
ip addr show docker0 | grep 'inet '
# 例如输出：inet 172.17.0.1/16

# 修改URL为：
# http://172.17.0.1:48080/api/v1/webhook/client
```

**Windows/Mac用户**：
- 确认后端服务正在运行
- 测试：`curl http://localhost:48080/health`

### 问题：Webhook已触发但无效果

**检查后端日志**：
- 应该看到：`[Webhook] 客户端事件: client.connected`
- 如果看不到：检查后端是否运行

**检查设备激活**：
- 设备必须先通过APP配网激活
- username格式必须是：`productKey&deviceId`

---

## 📊 EMQX默认发送的数据格式

后端会自动处理以下格式：

**连接事件**：
```json
{
  "event": "client.connected",
  "clientid": "ESP32_xxx",
  "username": "switch-001&device_xxx",
  "peerhost": "192.168.1.100",
  "connected_at": 1702800000000,
  "timestamp": 1702800000000
}
```

**断开事件**：
```json
{
  "event": "client.disconnected",
  "clientid": "ESP32_xxx",
  "username": "switch-001&device_xxx",
  "reason": "normal",
  "disconnected_at": 1702800100000,
  "timestamp": 1702800100000
}
```

---

**配置完成！设备状态实时同步！** 🎉
