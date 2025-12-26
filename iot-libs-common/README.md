# iot-libs-common

> IoT 公共基础库 - 通用组件与 SDK 层

## 📋 仓库定位

**基础组件库，封装通用功能，让后期每做一个新项目都能直接拿来用，开发成本越来��低**

> **把重复的逻辑、SDK、工具封装起来，未来新项目可以直接复用**

## ✅ 核心目标

1. **减少重复代码** - 统一实现，一次维护
2. **降低开发成本** - 新项目只写业务逻辑
3. **统一规范** - Topic、API、数据结构、鉴权、日志都统一
4. **长期维护** - Bug 修一次，所有项目受益

## 📦 库的内容

### 1️⃣ Go / Core 层 SDK

```
go-sdk/
├── mqtt/              # MQTT 客户端 SDK
│   ├── client.go      # 下发命令、接收消息
│   └── auth.go        # MQTT 鉴权
├── api/               # API 客户端
│   ├── client.go      # REST API 调用
│   └── auth.go        # API 认证工具
├── model/             # 公共数据结构
│   ├── user.go
│   ├── project.go
│   ├── product.go
│   └── device.go
├── logger/            # 日志封装
├── errors/            # 异常处理
├── audit/             # 审计工具
└── billing/           # 计费/配额工具
```

### 2️⃣ Flutter / App 层 SDK

```
flutter-sdk/
├── lib/
│   ├── api/           # API 封装 SDK
│   │   ├── client.dart
│   │   └── auth.dart
│   ├── mqtt/          # MQTT 客户端封装
│   │   ├── client.dart
│   │   └── local_control.dart  # 可选本地直控
│   ├── models/        # 数据模型
│   ├── widgets/       # UI 公共组件
│   │   ├── device_card.dart
│   │   ├── switch_button.dart
│   │   └── status_indicator.dart
│   ├── state/         # 状态管理模板
│   └── utils/         # 通用工具
│       ├── error_handler.dart
│       └── toast.dart
└── pubspec.yaml
```

### 3️⃣ JS / UniApp / Web 层 SDK

```
js-sdk/
├── src/
│   ├── api/           # REST API SDK
│   ├── mqtt/          # MQTT 客户端封装
│   ├── models/        # 数据模型
│   └── components/    # 公共 UI 组件库
└── package.json
```

### 4️⃣ 小程序 SDK

```
miniapp-sdk/
├── utils/
│   ├── api.js         # API 封装
│   ├── mqtt.js        # MQTT 封装
│   └── auth.js        # 认证工具
├── components/        # 公共组件
└── models/            # 数据模型
```

## 🏗️ 目录结构

```
iot-libs-common/
├── go-sdk/            # Go SDK
├── flutter-sdk/       # Flutter SDK
├── js-sdk/            # JS SDK
├── miniapp-sdk/       # 小程序 SDK
├── firmware-sdk/      # 硬件固件 SDK（可选）
└── docs/              # SDK 使用文档
    ├── go-sdk.md
    ├── flutter-sdk.md
    ├── js-sdk.md
    └── examples/
```

## 🔗 依赖关系

- **依赖**: iot-platform-core (API 定义)
- **被依赖**: 所有 app, firmware, project 仓库

## 🎯 设计原则

1. **高内聚低耦合** - 每个 SDK 独立可用
2. **向后兼容** - API 不轻易破坏性变更
3. **文档完善** - 每个 SDK 都有使用示例
4. **测试覆盖** - 核心功能有单元测试

## 📊 使用示例

### Go SDK 示例

```go
import "iot-libs-common/go-sdk/mqtt"

client := mqtt.NewClient(config)
client.Publish("device/123/control", payload)
```

### Flutter SDK 示例

```dart
import 'package:iot_sdk/api/client.dart';

final client = IotApiClient(apiKey: 'xxx');
await client.getDeviceList(projectId);
```

### JS SDK 示例

```javascript
import { IotClient } from '@iot/js-sdk';

const client = new IotClient({ apiKey: 'xxx' });
await client.device.list(projectId);
```

## 🚀 版本管理

- 使用语义化版本（Semantic Versioning）
- 主版本号变更 = 破坏性变更
- 次版本号变更 = 新功能
- 补丁版本号变更 = Bug 修复

## 📄 相关文档

参考 `iot-platform-docs` 仓库中的：
- SDK 开发规范
- API 接口文档

---

**作者**: 罗耀生
**创建时间**: 2025-12-13
