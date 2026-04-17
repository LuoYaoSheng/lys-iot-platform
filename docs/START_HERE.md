# Open IoT Platform Start Here

> 给第一次想从 `Open IoT Platform` 学完整 IoT 链路的人。

---

## 这套项目适合谁

适合下面这类人：

- 已经会一点 BLE 或 App 开发，想继续看完整链路
- 想把设备、配网、MQTT、服务端和移动端串起来
- 想看一个真实 IoT 项目怎么拆模块

如果你还没有 BLE 基础，建议先看：

- [Smart BLE](https://gitee.com/luoyaosheng/lys-smart-ble)

---

## 推荐阅读顺序

### 1. 先看根 README

先理解这套项目到底包含哪些部分：

- 服务端（Go + Gin + MySQL + Redis + MQTT）
- 移动端（Flutter 跨平台配网 APP）
- 固件（ESP32 / ESP32-S3 设备固件）
- 公共库（Flutter SDK + 嵌入式库）
- SmartLink 落地页与发布包装层

> 根 README 位于仓库根目录，请到 [Gitee 仓库](https://gitee.com/luoyaosheng/lys-iot-platform) 或 [GitHub 仓库](https://github.com/LuoYaoSheng/open-iot-platform) 查看。

### 2. 再看仓库结构文档

建议下一步看：

- [仓库架构](./REPOSITORY_ARCHITECTURE)

### 3. 再看本地联调 Runbook

如果你要真的跑起来，请继续看：

- [Docker 一键部署](./QUICK_START_DOCKER) — 最快的体验方式
- [本地模拟器 Runbook](./LOCAL_EMULATOR_RUNBOOK)
- [配置链路说明](./CONFIGURATION_CHAIN)

### 4. 最后按模块进入

各模块的 README 位于仓库对应目录中，请到仓库页面查看：

- **服务端**：`server/` — 后端 API、MQTT Broker、设备管理
- **移动端**：`mobile-app/` — Flutter BLE 配网 APP
- **固件**：`firmware/` — ESP32 智能开关 / ESP32-S3 USB 唤醒
- **公共库**：`iot-libs-common/` — Flutter SDK + 嵌入式公共库

---

## 你应该先关注什么

### 我想看完整链路

先看：

- [Docker 一键部署](./QUICK_START_DOCKER) — 5 分钟跑起来
- [仓库架构](./REPOSITORY_ARCHITECTURE)
- [数据流架构](./ARCHITECTURE_DATA_FLOW)
- [本地模拟器 Runbook](./LOCAL_EMULATOR_RUNBOOK)

### 我想先跑服务端

先看：

- [Docker 一键部署](./QUICK_START_DOCKER)

### 我想先看移动端配网

先看：

- 移动端 README（位于仓库 `mobile-app/` 目录）

### 我想先看设备和固件

先看：

- 固件 README（位于仓库 `firmware/switch/` 和 `firmware/usb-wakeup/` 目录）

---

## 下一步

- [Docker 一键部署](./QUICK_START_DOCKER)
- [仓库架构](./REPOSITORY_ARCHITECTURE)
- [数据流架构](./ARCHITECTURE_DATA_FLOW)
- [本地模拟器 Runbook](./LOCAL_EMULATOR_RUNBOOK)
- [配置链路说明](./CONFIGURATION_CHAIN)
