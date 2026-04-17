# 贡献指南

> 欢迎为 Open IoT Platform 做出贡献！本指南帮助你快速参与项目开发。

## 报告 Issue

### Bug 报告

提交 Bug 时请包含：

1. **问题描述**：发生了什么，期望什么
2. **重现步骤**：详细的操作过程
3. **环境信息**：
   ```bash
   # 服务端
   docker compose version && docker version
   cat .env | grep -v PASSWORD

   # 移动端
   flutter doctor
   ```
4. **日志**：相关错误日志
5. **截图/录屏**：如果是 UI 问题

**提交地址**：
- [GitHub Issues](https://github.com/LuoYaoSheng/open-iot-platform/issues)
- [Gitee Issues](https://gitee.com/luoyaosheng/lys-iot-platform/issues)

### 功能建议

描述你希望看到的功能，包括使用场景和预期效果。

## 提交 PR

### 流程

1. Fork 仓库
2. 创建功能分支：`git checkout -b feat/your-feature`
3. 编写代码 + 测试
4. 提交代码（遵循提交信息格式）
5. 推送到你的 Fork
6. 创建 Pull Request

### PR 说明要求

- **Affected Modules**：影响的模块（server / mobile-app / firmware / docs）
- **Changes**：变更内容说明
- **Test Commands**：你运行的验证命令
- **Related Issue**：关联的 Issue（如有）
- **Screenshots/Logs**：UI 变更或设备行为变更时提供截图或串口日志

## 代码风格

### Go（服务端）

- 使用 `gofmt` 格式化代码
- 包名全小写，简短有意义
- 导出函数必须有 godoc 注释
- 错误处理不使用 panic，使用 error 返回

```go
// DeviceRepository 设备数据访问接口
type DeviceRepository interface {
    // Create 创建设备记录
    Create(ctx context.Context, device *model.Device) error
}
```

### Dart（移动端）

- 文件名 `snake_case.dart`
- 类名 `PascalCase`
- 成员变量和方法 `camelCase`
- 遵循 `analysis_options.yaml` 中的 lint 规则

```bash
# 代码检查
cd mobile-app
flutter analyze
```

### C++（固件）

- 类型名 `PascalCase`
- 宏和常量 `UPPER_SNAKE_CASE`
- 配置文件放在 `include/*.h`
- 遵循 Arduino 风格

```cpp
#define MQTT_PORT 48883
#define DEVICE_NAME "IoT-Switch"

class BleManager {
public:
    void begin();
    bool isConnected();
};
```

## 提交信息格式

采用简洁风格：

```
<模块> <日期> <简要说明>

示例：
Lys 20260110 修复设备列表类型转换错误
Lys 20260115 新增 USB 唤醒设备支持
Lys 20260120 更新部署文档端口映射
```

### 模块标记

| 标记 | 范围 |
|------|------|
| `server` | 后端服务 |
| `app` | 移动端 APP |
| `firmware` | 固件代码 |
| `docs` | 文档变更 |
| `deploy` | 部署配置 |
| `chore` | 构建/CI/依赖 |

## 开发环境快速设置

### 服务端

```bash
cd server
make dev-infra-up     # 启动 MySQL + Redis
cp .env.example .env  # 配置环境变量
go run ./cmd/server   # 启动后端
```

### 移动端

```bash
cd mobile-app
flutter pub get       # 安装依赖
flutter run           # 运行 APP
```

### 固件

```bash
cd firmware/switch    # 或 firmware/usb-wakeup
pio run               # 编译
pio run -t upload     # 烧写
pio device monitor    # 串口监控
```

## 项目结构

```
open-iot-platform/
├── server/              # 平台核心后端 (Go)
├── mobile-app/          # 移动端 APP (Flutter)
├── iot-libs-common/     # 公共库 (Flutter SDK 等)
├── smartlink-hub/       # 落地页 / 发布物 / 包装层
├── firmware/            # 硬件固件
│   ├── switch/         # ESP32 智能开关
│   └── usb-wakeup/     # ESP32-S3 USB 唤醒
└── docs/               # 文档站 (VitePress)
```

## 安全注意事项

- **禁止**提交 `.env` 文件（已在 `.gitignore` 中排除）
- **禁止**提交真实的设备凭证、API Key、密码
- 使用 `.env.example` 或 `.env.simple` 作为配置模板
- 设备密钥和 MQTT 端点作为敏感测试数据处理

## 相关文档

- [服务端开发指南](/SERVER_GUIDE) — 服务端开发环境搭建
- [固件开发指南](/FIRMWARE_GUIDE) — 固件开发环境
- [移动端配网指南](/MOBILE_APP_GUIDE) — APP 开发环境
- [部署与运维](/DEPLOYMENT_GUIDE) — 部署指南
