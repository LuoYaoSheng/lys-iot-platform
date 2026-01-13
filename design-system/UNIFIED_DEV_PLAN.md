# Open IoT Platform - 统一 UI/UX 开发规划

**作者**: 罗耀生
**版本**: 1.0.0
**更新日期**: 2026-01-12
**参考原型**: `design-system/prototype/`

---

## 目标

确保 `mobile-app` (Flutter) 和 `open-iot-uniapp` (UniApp) 两个项目的 **UI/UX 完全一致**，均按照 `design-system/prototype/` 目录下的 HTML 原型实现。

---

## 1. 统一设计令牌

### 1.1 颜色系统 (Color Tokens)

| 令牌 | 色值 | Flutter | UniApp (rpx) | 用途 |
|------|------|---------|---------------|------|
| `primary` | `#007AFF` | `Color(0xFF007AFF)` | `#007AFF` | 主操作、品牌色 |
| `primaryLight` | `#3395FF` | `Color(0xFF3395FF)` | `#3395FF` | 悬停状态 |
| `primaryDark` | `#0056CC` | `Color(0xFF0056CC)` | `#0056CC` | 按下状态 |
| `success` | `#34C759` | `Color(0xFF34C759)` | `#34C759` | 成功/在线 |
| `warning` | `#FF9500` | `Color(0xFFFF9500)` | `#FF9500` | 警告 |
| `error` | `#FF3B30` | `Color(0xFFFF3B30)` | `#FF3B30` | 错误/离线 |
| `white` | `#FFFFFF` | `Color(0xFFFFFFFF)` | `#FFFFFF` | 白色 |
| `gray50` | `#F5F5F7` | `Color(0xFFF5F5F7)` | `#F5F5F7` | 页面背景 |
| `gray100` | `#E5E5EA` | `Color(0xFFE5E5EA)` | `#E5E5EA` | 分割线 |
| `gray200` | `#D1D1D6` | `Color(0xFFD1D1D6)` | `#D1D1D6` | 边框 |
| `gray300` | `#C7C7CC` | `Color(0xFFC7C7CC)` | `#C7C7CC` | 禁用 |
| `gray500` | `#8E8E93` | `Color(0xFF8E8E93)` | `#8E8E93` | 次要文字 |
| `gray700` | `#3A3A3C` | `Color(0xFF3A3A3C)` | `#3A3A3C` | 主要文字 |
| `gray900` | `#000000` | `Color(0xFF000000)` | `#000000` | 纯黑 |

### 1.2 间距系统 (Spacing Tokens)

| 令牌 | 值 | Flutter | UniApp (rpx) | 用途 |
|------|-----|---------|---------------|------|
| `spacing4` | 4px | `4.0` | `8rpx` | 极小间距 |
| `spacing8` | 8px | `8.0` | `16rpx` | 小间距 |
| `spacing12` | 12px | `12.0` | `24rpx` | 中小间距 |
| `spacing16` | 20px | `16.0` | `32rpx` | 标准间距/页面边距 |
| `spacing20` | 20px | `20.0` | `40rpx` | 中大间距 |
| `spacing24` | 24px | `24.0` | `48rpx` | 大间距 |
| `spacing32` | 32px | `32.0` | `64rpx` | 超大间距 |
| `spacing48` | 48px | `48.0` | `96rpx` | 特大间距 |

### 1.3 圆角系统 (Radius Tokens)

| 令牌 | 值 | Flutter | UniApp (rpx) | 用途 |
|------|-----|---------|---------------|------|
| `radiusSm` | 4px | `4.0` | `8rpx` | 小按钮、标签 |
| `radiusMd` | 8px | `8.0` | `16rpx` | 按钮、输入框 |
| `radiusLg` | 12px | `12.0` | `24rpx` | 卡片、对话框 |
| `radiusXl` | 16px | `16.0` | `32rpx` | 特殊卡片、底部弹窗 |

### 1.4 字体系统 (Typography Tokens)

| 令牌 | 值 | Flutter | UniApp (rpx) | 用途 |
|------|-----|---------|---------------|------|
| `fontSizeCaption` | 12px | `12.0` | `24rpx` | 标签/角标 |
| `fontSizeBodySmall` | 14px | `14.0` | `28rpx` | 辅助信息 |
| `fontSizeBody` | 16px | `16.0` | `32rpx` | 正文 |
| `fontSizeTitle` | 20px | `20.0` | `40rpx` | 标题 |
| `fontSizeLarge` | 28px | `28.0` | `56rpx` | 大标题 |

### 1.5 阴影系统 (Shadow Tokens)

| 令牌 | CSS | Flutter | 用途 |
|------|-----|---------|------|
| `shadowSm` | `0 1px 2px rgba(0,0,0,0.05)` | `[BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)]` | 轻微阴影 |
| `shadowMd` | `0 4px 12px rgba(0,0,0,0.08)` | `[BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 12)]` | 标准阴影 |
| `shadowLg` | `0 8px 24px rgba(0,0,0,0.12)` | `[BoxShadow(color: Color(0x1F000000), offset: Offset(0, 8), blurRadius: 24)]` | FAB 阴影 |

### 1.6 动画系统 (Animation Tokens)

| 令牌 | 值 | 用途 |
|------|-----|------|
| `durationFast` | 150ms | 快速交互（按钮点击、开关切换） |
| `durationNormal` | 250ms | 标准交互（页面切换、弹窗） |
| `easeOut` | `cubic-bezier(0.0, 0.0, 0.2, 1.0)` | 标准缓动 |

---

## 2. 统一组件清单

### 2.1 按钮组件 (Button)

| 类型 | 样式 | Flutter | UniApp |
|------|------|---------|--------|
| **主要按钮** | 蓝色背景，白色文字 | `MinimalPrimaryButton` | `MinimalPrimaryButton` |
| **次要按钮** | 灰色背景，深色文字 | `MinimalSecondaryButton` | `MinimalSecondaryButton` |
| **轮廓按钮** | 透明背景，蓝色边框 | `MinimalOutlineButton` | `MinimalOutlineButton` |
| **文本按钮** | 透明背景，蓝色文字 | `MinimalTextButton` | `MinimalTextButton` |
| **错误按钮** | 红色背景 | `MinimalErrorButton` | `MinimalErrorButton` |

**统一规格**:
- 高度: 48px (96rpx)
- 圆角: 8px (16rpx)
- 字号: 16px (32rpx)
- 横向内边距: 24px (48rpx)

### 2.2 输入框组件 (TextField)

| 属性 | 值 |
|------|-----|
| 高度 | 48px (96rpx) |
| 圆角 | 8px (16rpx) |
| 背景色 | `gray50` |
| 边框 | 1px `gray200` |
| 聚焦边框 | 2px `primary` |
| 内边距 | h12px v16px (h24rpx v32rpx) |

**Flutter**: `MinimalTextField`
**UniApp**: `MinimalTextField`

### 2.3 卡片组件 (Card)

| 类型 | 用途 | Flutter | UniApp |
|------|------|---------|--------|
| **通用卡片** | 标准内容容器 | `MinimalCard` | `MinimalCard` |
| **设备卡片** | 设备列表项 | `MinimalDeviceCard` | `MinimalDeviceCard` |

**统一规格**:
- 圆角: 12px (24rpx)
- 内边距: 16px (32rpx)
- 阴影: `shadowSm`
- 边框: 1px `gray100`

### 2.4 状态指示器 (Status Indicator)

| 状态 | 颜色 | 尺寸 |
|------|------|------|
| **在线** | `success` | 8px (16rpx) 圆点 |
| **离线** | `error` | 8px (16rpx) 圆点 |
| **未激活** | `gray300` | 8px (16rpx) 圆点 |

**Flutter**: `MinimalStatusIndicator`
**UniApp**: `MinimalStatusBadge`

### 2.5 对话框组件 (Dialog)

| 类型 | 用途 |
|------|------|
| **确认对话框** | 确认/取消操作 |
| **底部弹窗** | 表单、配置 |
| **操作菜单** | 上拉菜单 |

**Flutter**: `MinimalDialog`, `MinimalBottomSheet`
**UniApp**: `MinimalDialog`, `MinimalBottomSheet`

### 2.6 反馈组件 (Feedback)

| 类型 | 用途 |
|------|------|
| **Toast** | 轻提示 |
| **Loading** | 加载指示器 |
| **Empty** | 空状态 |

**Flutter**: `MinimalToast`, `MinimalLoading`, `MinimalEmpty`
**UniApp**: `MinimalToast`, `MinimalLoading`, `MinimalEmpty`

### 2.7 导航组件 (Navigation)

| 类型 | 用途 | Flutter | UniApp |
|------|------|---------|--------|
| **AppBar** | 顶部导航栏 | `AppBar` | 自定义导航栏 |
| **TabBar** | 底部标签栏 | `MinimalTabbar` | `MinimalTabbar` |
| **FAB** | 悬浮按钮 | `MinimalFab` | `MinimalFab` |

---

## 3. 统一页面结构

### 3.1 页面清单

| 页面 | 路由 | 原型文件 | 说明 |
|------|------|----------|------|
| 启动页 | `/splash` | - | Logo + 品牌名，2秒跳转 |
| 登录页 | `/login` | `pages/login.html` | 邮箱/密码登录 |
| 注册页 | `/register` | `pages/register.html` | 新用户注册 |
| 忘记密码 | `/forgot-password` | `pages/forgot-password.html` | 找回密码 |
| 设备列表 | `/devices` | `pages/device-list.html` | 主页，设备列表+TabBar |
| 扫码配网 | `/scan` | `pages/scan.html` | BLE 设备扫描 |
| WiFi配置 | `/config` | `pages/config.html` | WiFi 配置 |
| 舵机控制 | `/control/servo` | `pages/device-control-servo.html` | 舵机开关控制 |
| 唤醒控制 | `/control/wakeup` | `pages/device-control-wakeup.html` | USB 唤醒控制 |
| 设置页 | `/settings` | `pages/settings.html` | 系统设置 |
| 关于页 | `/about` | `pages/about.html` | 关于信息 |
| 场景编辑 | `/scene/edit` | `pages/scene-edit.html` | 场景编辑 |

### 3.2 页面布局标准

```
┌───────────────────────────────────────┐
│  ┌─────────────────────────────────┐ │  ← 状态栏 (44px)
│  │  9:41                    📶 🔋 │ │
│  └─────────────────────────────────┘ │
├───────────────────────────────────────┤
│  ┌─────────────────────────────────┐ │  ← AppBar (56px)
│  │  ←  标题              ⚙️       │ │
│  └─────────────────────────────────┘ │
├───────────────────────────────────────┤
│                                       │
│           页面内容区域                │
│                                       │
│           padding: 16px              │
│                                       │
├───────────────────────────────────────┤
│  ┌─────────────────────────────────┐ │  ← TabBar (60px) 或 FAB
│  │  📱 设备      👤 我的            │ │
│  └─────────────────────────────────┘ │
└───────────────────────────────────────┘
```

### 3.3 AppBar 规范

| 属性 | 值 |
|------|-----|
| 高度 | 56px (112rpx) |
| 背景色 | `white` |
| 边框 | 1px `gray100` (底部) |
| 标题字号 | 20px (40rpx), SemiBold |
| 标题颜色 | `gray700` |
| 返回图标 | 24x24px (48x48rpx) |

### 3.4 TabBar 规范

| 属性 | 值 |
|------|-----|
| 高度 | 60px (120rpx) |
| 背景色 | `white` |
| 边框 | 1px `gray100` (顶部) |
| 选中颜色 | `primary` |
| 未选中颜色 | `gray300` |
| 图标大小 | 24x24px (48x48rpx) |
| 标签字号 | 10px (20rpx) |

### 3.5 FAB 规范

| 属性 | 值 |
|------|-----|
| 尺寸 | 56x56px (112x112rpx) |
| 圆角 | 16px (32rpx) |
| 背景色 | `primary` |
| 图标/文字 | "+" 28px (56rpx) |
| 阴影 | `shadowLg` |
| 位置 | 右下角 (距底 80px 带TabBar, 24px 不带) |

---

## 4. 设备控制面板

### 4.1 舵机开关控制面板

```
┌─────────────────────────────────────┐
│  ← 客厅开关           ✏️            │  AppBar
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │        当前位置: 上            │ │
│  │                               │ │
│  │      ┌───┐                    │ │
│  │      │ █ │  ●                 │ │  位置指示器
│  │      ├───┤                    │ │
│  │      │ ○ │  ○                 │ │
│  │      └───┘                    │ │
│  │                               │ │
│  │  ┌────┐ ┌────┐ ┌────┐        │ │  位置按钮
│  │  │ 上 │ │ 中 │ │ 下 │        │ │
│  │  └────┘ └────┘ └────┘        │ │
│  │                               │ │
│  │  ─────────────────────────    │ │
│  │  脉冲触发          □ 高级     │ │
│  │  ┌───────────────────────┐    │ │
│  │  │  ⚡  脉冲触发          │    │ │  脉冲按钮
│  │  └───────────────────────┘    │ │
│  └───────────────────────────────┘ │
│                                     │
│     ● 在线    最后更新: 2秒前       │
│                                     │
│  ┌───────────────────────────────┐ │  设备信息
│  │  设备名称    客厅开关          │ │
│  │  设备 ID    dev_001a2b3c      │ │
│  │  产品类型    舵机开关          │ │
│  │  固件版本    1.0.0            │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 4.2 USB 唤醒控制面板

```
┌─────────────────────────────────────┐
│  ← 电脑唤醒           ✏️            │  AppBar
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │                               │ │
│  │           ┌─────────┐         │ │
│  │           │         │         │ │
│  │           │   ⚡     │         │ │  唤醒按钮
│  │           │         │         │ │    160x160px
│  │           │   唤醒   │         │ │
│  │           │         │         │ │
│  │           └─────────┘         │ │
│  │                               │ │
│  │      点击按钮唤醒电脑          │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                     │
│     ● 在线    最后更新: 5秒前       │
└─────────────────────────────────────┘
```

---

## 5. 实现文件对照

### 5.1 设计令牌文件

| 平台 | 文件路径 |
|------|----------|
| **Flutter** | `mobile-app/lib/design_system/tokens/` |
| - 颜色 | `color_tokens.dart` |
| - 间距 | `spacing_tokens.dart` |
| - 圆角 | `radius_tokens.dart` |
| **UniApp** | `open-iot-uniapp/styles/design-system/tokens/` |
| - 颜色 | `_colors.scss` |
| - 间距 | `_spacing.scss` |
| - 圆角 | `_radius.scss` |

### 5.2 组件文件

| 组件 | Flutter | UniApp |
|------|---------|--------|
| 按钮 | `design_system/components/buttons/minimal_buttons.dart` | `components/minimal/buttons/` |
| 输入框 | `design_system/components/inputs/minimal_text_field.dart` | `components/minimal/inputs/` |
| 卡片 | `design_system/components/cards/minimal_card.dart` | `components/minimal/cards/` |
| 设备卡片 | `design_system/components/devices/minimal_device_card.dart` | `components/minimal/cards/MinimalDeviceCard.vue` |
| 状态指示器 | `design_system/components/indicators/minimal_indicators.dart` | `components/minimal/indicators/` |
| 反馈 | `design_system/components/feedback/minimal_feedback.dart` | `components/minimal/feedback/` |
| 导航 | `design_system/components/navigation/` | `components/minimal/navigation/` |

### 5.3 页面文件

| 页面 | Flutter | UniApp |
|------|---------|--------|
| 启动页 | `pages/splash_page.dart` | `pages/splash/splash.vue` |
| 登录页 | `pages/login_page.dart` | `pages/login/login.vue` |
| 注册页 | `pages/register_page.dart` | `pages/register/register.vue` |
| 设备列表 | `pages/device_list_page.dart` | `pages/device-list/device-list.vue` |
| 扫码配网 | `pages/scan_page.dart` | `pages/scan/scan.vue` |
| WiFi配置 | `pages/config_page.dart` | `pages/config/config.vue` |
| 舵机控制 | `pages/control_page.dart` (动态渲染) | `pages/device-control/device-control-servo.vue` |
| 唤醒控制 | `pages/control_page.dart` (动态渲染) | `pages/device-control/device-control-wakeup.vue` |
| 设置页 | `pages/settings_page.dart` | `pages/settings/settings.vue` |

---

## 6. 开发任务清单

### 6.1 设计令牌同步

- [ ] **Flutter**: 更新 `lib/design_system/tokens/` 下的所有令牌文件
- [ ] **UniApp**: 更新 `styles/design-system/tokens/` 下的所有令牌文件
- [ ] 确保两个平台的令牌值完全一致（参考上述对照表）

### 6.2 基础组件同步

- [ ] **按钮组件**: 对齐样式（高度、圆角、颜色、字号）
- [ ] **输入框组件**: 对齐样式（高度、边框、聚焦状态）
- [ ] **卡片组件**: 对齐样式（圆角、内边距、阴影）
- [ ] **状态指示器**: 对齐样式（颜色、尺寸）
- [ ] **对话框组件**: 对齐样式（圆角、动画）
- [ ] **反馈组件**: 对齐样式（Toast、Loading、Empty）
- [ ] **导航组件**: 对齐样式（AppBar、TabBar、FAB）

### 6.3 页面同步

- [ ] **登录页**: 按照 `pages/login.html` 实现
- [ ] **注册页**: 按照 `pages/register.html` 实现
- [ ] **设备列表页**: 按照 `pages/device-list.html` 实现
- [ ] **舵机控制页**: 按照 `pages/device-control-servo.html` 实现
- [ ] **唤醒控制页**: 按照 `pages/device-control-wakeup.html` 实现
- [ ] **扫码配网页**: 按照 `pages/scan.html` 实现
- [ ] **WiFi配置页**: 按照 `pages/config.html` 实现
- [ ] **设置页**: 按照 `pages/settings.html` 实现

### 6.4 控制面板同步

- [ ] **舵机控制面板**: 位置指示器 + 位置按钮 + 脉冲控制
- [ ] **USB 唤醒面板**: 大按钮触发
- [ ] **传感器显示面板**: 数据展示
- [ ] **通用控制面板**: 动态渲染

---

## 7. 验收标准

### 7.1 视觉一致性

- [ ] 两个应用的颜色完全一致（对比原型截图）
- [ ] 两个应用的间距完全一致
- [ ] 两个应用的圆角完全一致
- [ ] 两个应用的字号完全一致

### 7.2 交互一致性

- [ ] 按钮点击反馈一致（缩放、颜色变化）
- [ ] 页面切换动画一致
- [ ] 弹窗动画一致
- [ ] 加载状态显示一致

### 7.3 功能一致性

- [ ] 相同的功能流程
- [ ] 相同的表单验证
- [ ] 相同的错误提示
- [ ] 相同的成功反馈

---

## 8. 参考资源

- **原型目录**: `design-system/prototype/`
- **设计规范**: `design-system/README.md`
- **设计令牌**: `design-system/docs/design-tokens.md`
- **组件规范**: `design-system/docs/components.md`
- **页面规范**: `design-system/docs/pages.md`

---

**更新历史**

| 日期 | 版本 | 修改内容 | 作者 |
|------|------|----------|------|
| 2026-01-12 | 1.0.0 | 初始版本，统一 UI/UX 开发规划 | 罗耀生 |
