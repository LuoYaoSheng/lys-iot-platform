# Open IoT Platform 设计系统

**作者**: 罗耀生
**版本**: v1.0.0
**更新日期**: 2026-01-12

---

## 概述

本设计系统为 Open IoT Platform 移动端项目（Flutter + UniApp）提供统一的 UI/UX 设计规范和参考标准。

### 目标项目

| 项目 | 技术栈 | 状态 |
|------|--------|------|
| `mobile-app` | Flutter 3.10.1 + Provider | 主项目 |
| `open-iot-uniapp` | UniApp (Vue 3) | 对齐目标 |

### 设计原则

| 原则 | 说明 |
|------|------|
| **简洁至上** | 遵循 Material Design 3，保持界面简洁专业 |
| **一致性** | 两个项目使用相同的设计令牌和组件规范 |
| **易用性** | 支持单手操作，关键触控区域不小于 44x44pt |
| **反馈及时** | 所有交互都有明确的视觉/触觉反馈 |

---

## 文档结构

```
design-system/
├── README.md              # 本文件 - 设计系统总览
├── docs/
│   ├── design-tokens.md   # 设计令牌（颜色、字体、间距、圆角等）
│   ├── pages.md           # 页面设计稿（所有页面的布局设计）
│   └── components.md      # 组件设计稿（可复用组件规范）
└── assets/                # 设计资源（图标、插图等）
```

---

## 快速索引

### 页面清单

| 页面 | 路径 | 说明 |
|------|------|------|
| 启动页 | `/splash` | 应用启动，版本检测 |
| 登录页 | `/login` | 邮箱/密码登录 |
| 注册页 | `/register` | 新用户注册 |
| 设备列表 | `/devices` | 主页，显示所有设备 |
| 扫码配网 | `/scan` | BLE 设备扫描 |
| WiFi配置 | `/config` | WiFi 密码配置 |
| 设备控制 | `/control/:id` | 设备详情与控制 |
| 系统设置 | `/settings` | 服务器配置与用户信息 |

### 组件清单

| 组件 | 类型 | 说明 |
|------|------|------|
| DeviceCard | 卡片 | 设备列表项 |
| ControlPanel | 面板 | 设备控制面板基类 |
| ServoSwitchPanel | 面板 | 舵机混合控制 |
| UsbWakeupPanel | 面板 | USB 唤醒控制 |
| StatusIndicator | 指示器 | 设备在线状态 |
| ConfigStepper | 步骤器 | 配网进度指示 |

---

## 设计令牌速查

### 主色调

```
Primary:     #007AFF (iOS Blue)
Secondary:   #5856D6 (Purple)
Success:     #34C759 (Green)
Warning:     #FF9500 (Orange)
Error:       #FF3B30 (Red)
```

### 中性色

```
White:   #FFFFFF
Gray50:  #F5F5F7 (背景)
Gray100: #E5E5EA (边框)
Gray200: #D1D1D6 (分割线)
Gray300: #C7C7CC (禁用)
Gray500:  #8E8E93 (次要文本)
Gray700:  #3A3A3C (主要文本)
Gray900:  #000000 (纯黑)
```

### 间距

```
4pt   - 极小间距
8pt   - 小间距
12pt  - 中小间距
16pt  - 标准间距
20pt  - 中大间距
24pt  - 大间距
```

### 圆角

```
4pt  - 小圆角 (按钮、输入框)
8pt  - 中圆角 (卡片)
12pt - 大圆角 (对话框)
16pt - 超大圆角 (特殊卡片)
```

---

## 版本历史

| 日期 | 版本 | 修改内容 | 作者 |
|------|------|----------|------|
| 2026-01-12 | v1.0.0 | 初始版本，建立设计系统 | 罗耀生 |
