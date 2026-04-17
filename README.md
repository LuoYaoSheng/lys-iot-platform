# Open IoT Platform

> 开源 IoT 设备管理平台，目标是打通设备固件、BLE 配网、平台后端和移动端控制的完整链路。

**作者**: 罗耀生
**协议**: GPL v3
**仓库**:
- [Gitee](https://gitee.com/luoyaosheng/lys-iot-platform)
- [GitHub](https://github.com/LuoYaoSheng/open-iot-platform)

---

## 这是什么

`open-iot-platform` 不是单一服务仓库，而是一个 IoT monorepo。

它当前关注的是一条可跑通的真实链路：

1. 设备通过 BLE 获取 WiFi 和平台地址
2. 设备激活到 `server/`
3. 设备通过 MQTT 接入平台
4. `mobile-app/` 通过 API + MQTT 查看和控制设备

如果你第一次进入这个仓库，建议先把它理解为“系统入口”，而不是单独看某个子目录。

---

## 第一次进入先看这里

- 想快速理解整个仓库：看 [docs/START_HERE.md](docs/START_HERE.md)
- 想看模块边界：看 [docs/REPOSITORY_ARCHITECTURE.md](docs/REPOSITORY_ARCHITECTURE.md)
- 想直接跑本地链路：看 [docs/LOCAL_EMULATOR_RUNBOOK.md](docs/LOCAL_EMULATOR_RUNBOOK.md)
- 想最快用 Docker 跑起来：看 [docs/QUICK_START_DOCKER.md](docs/QUICK_START_DOCKER.md)

---

## 模块结构

```text
open-iot-platform/
├── server/              # 平台核心：API、设备激活、MQTT 鉴权、数据落库
├── mobile-app/          # Flutter 移动端：BLE 配网、设备列表、基础控制
├── iot-libs-common/     # 公共库：Flutter SDK 和后续可复用能力
├── firmware/            # 设备固件：ESP32 / ESP32-S3 示例
├── smartlink-hub/       # 落地页、发布物、非开发者说明和包装层
└── docs/                # 项目文档
```

需要特别说明：

- `server/` 是平台核心，不是演示脚本目录
- `mobile-app/` 是通用配网与控制客户端，不应承载后端规则
- `smartlink-hub/` 当前更接近产品化包装层和发布资源目录，不应被描述成成熟独立服务

---

## 当前技术栈

| 模块 | 当前现实 |
|------|----------|
| 后端 | Go + Gin + GORM |
| 数据层 | MySQL + Redis |
| MQTT 基础设施 | EMQX |
| 移动端 | Flutter |
| 固件 | PlatformIO + Arduino on ESP32 / ESP32-S3 |
| 部署 | Docker Compose |

说明：

- `server/` 中仍保留部分 `mochi-mqtt` 相关代码和依赖，但当前主部署链路已经围绕 `EMQX` 组织
- 对外文档默认应按当前部署现实描述，而不是按历史实现描述

---

## 快速开始

### 1. 跑服务端基础设施

```bash
git clone https://gitee.com/luoyaosheng/lys-iot-platform.git
cd open-iot-platform/server
docker compose up -d
```

不同 compose 文件的端口映射略有差异，启动后请以当前 `server/README.md` 和对应 compose 文件为准。

### 2. 跑移动端

```bash
cd mobile-app
flutter pub get
flutter run
```

### 3. 编译固件

```bash
cd firmware/switch
pio run
```

或：

```bash
cd firmware/usb-wakeup
pio run
```

---

## 当前推荐阅读顺序

1. [docs/START_HERE.md](docs/START_HERE.md)
2. [docs/REPOSITORY_ARCHITECTURE.md](docs/REPOSITORY_ARCHITECTURE.md)
3. [docs/CONFIGURATION_CHAIN.md](docs/CONFIGURATION_CHAIN.md)
4. [docs/LOCAL_EMULATOR_RUNBOOK.md](docs/LOCAL_EMULATOR_RUNBOOK.md)

如果只想先体验 Docker 方式，直接看 [docs/QUICK_START_DOCKER.md](docs/QUICK_START_DOCKER.md)。

---

## 当前边界

这个仓库当前已经有：

- 设备激活与基础设备管理
- MQTT 鉴权与接入链路
- BLE 配网移动端
- ESP32 / ESP32-S3 示例固件

这个仓库当前还没有优先做重：

- 完整 Web 管理后台
- 面向所有硬件形态的统一前端控制台
- 过早拆成多个“独立成熟子项目”

---

## 许可证

GNU General Public License v3.0

Issues：
- [Gitee Issues](https://gitee.com/luoyaosheng/lys-iot-platform/issues)
- [GitHub Issues](https://github.com/LuoYaoSheng/open-iot-platform/issues)
