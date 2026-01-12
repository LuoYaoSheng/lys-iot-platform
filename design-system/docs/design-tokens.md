# 设计令牌 (Design Tokens)

**作者**: 罗耀生
**版本**: v1.0.0

---

## 1. 颜色系统

### 1.1 主色调 (Primary Colors)

| 令牌名称 | 色值 | 用途 | 示例 |
|---------|------|------|------|
| `primary` | `#007AFF` | 主操作、品牌色 | 登录按钮、激活状态 |
| `primaryLight` | `#3395FF` | 悬停状态 | 按钮 Hover |
| `primaryDark` | `#0056CC` | 按下状态 | 按钮 Pressed |

### 1.2 辅助色 (Secondary Colors)

| 令牌名称 | 色值 | 用途 |
|---------|------|------|
| `secondary` | `#5856D6` | 次要操作、标签 |

### 1.3 语义色 (Semantic Colors)

| 令牌名称 | 色值 | 用途 |
|---------|------|------|
| `success` | `#34C759` | 成功状态、在线指示 |
| `warning` | `#FF9500` | 警告状态、待处理 |
| `error` | `#FF3B30` | 错误状态、离线指示 |
| `info` | `#007AFF` | 信息提示 |

### 1.4 中性色 (Neutral Colors)

| 令牌名称 | 色值 | 用途 |
|---------|------|------|
| `white` | `#FFFFFF` | 卡片背景、输入框背景 |
| `gray50` | `#F5F5F7` | 页面背景 |
| `gray100` | `#E5E5EA` | 边框、分割线 |
| `gray200` | `#D1D1D6` | 禁用边框 |
| `gray300` | `#C7C7CC` | 禁用状态、占位符 |
| `gray500` | `#8E8E93` | 次要文本、图标 |
| `gray700` | `#3A3A3C` | 主要文本、标题 |
| `gray900` | `#000000` | 纯黑文本、强对比 |

### 1.5 设备状态色

| 状态 | 色值 | 图标 | 用途 |
|------|------|------|------|
| 在线 | `#34C759` | 🟢 | 设备在线指示 |
| 离线 | `#FF3B30` | 🔴 | 设备离线指示 |
| 未激活 | `#C7C7CC` | ⚪ | 设备未激活 |
| 禁用 | `#FF9500` | 🚫 | 设备已禁用 |

---

## 2. 字体系统

### 2.1 字体家族

| 平台 | 字体 |
|------|------|
| iOS | SF Pro |
| Android | Roboto |
| Flutter | 系统默认 |

### 2.2 字号 (Font Size)

| 令牌名称 | 大小 | 用途 |
|---------|------|------|
| `fontSizeLarge` | 28pt | 页面标题、大标题 |
| `fontSizeTitle` | 20pt | 卡片标题、区块标题 |
| `fontSizeBody` | 16pt | 正文、按钮文本 |
| `fontSizeBodySmall` | 14pt | 辅助文本、次要信息 |
| `fontSizeCaption` | 12pt | 说明文字、时间戳 |

### 2.3 字重 (Font Weight)

| 名称 | 数值 | 用途 |
|------|------|------|
| Regular | 400 | 正文 |
| Medium | 500 | 次级标题、按钮 |
| SemiBold | 600 | 标题 |

### 2.4 行高 (Line Height)

| 字号 | 行高 | 比例 |
|------|------|------|
| 28pt | 36pt | 1.29 |
| 20pt | 28pt | 1.40 |
| 16pt | 24pt | 1.50 |
| 14pt | 20pt | 1.43 |
| 12pt | 18pt | 1.50 |

---

## 3. 间距系统

### 3.1 间距规范

| 令牌名称 | 数值 | 用途 |
|---------|------|------|
| `spacing0` | 0pt | 无间距 |
| `spacing4` | 4pt | 极小间距（图标与文字） |
| `spacing8` | 8pt | 小间距（相关元素） |
| `spacing12` | 12pt | 中小间距 |
| `spacing16` | 16pt | 标准间距（页面边距、卡片内边距） |
| `spacing20` | 20pt | 中大间距 |
| `spacing24` | 24pt | 大间距（区块间距） |

### 3.2 页面边距

| 屏幕尺寸 | 左右边距 |
|---------|---------|
| 手机 (< 768px) | 16pt |
| 平板 (≥ 768px) | 24pt |

---

## 4. 圆角系统

| 令牌名称 | 数值 | 用途 |
|---------|------|------|
| `radiusSm` | 4pt | 小按钮、标签 |
| `radiusMd` | 8pt | 按钮、输入框、卡片 |
| `radiusLg` | 12pt | 对话框、大卡片 |
| `radiusXl` | 16pt | 特殊卡片、底部弹窗 |

---

## 5. 阴影系统

| 级别 | 描述 | 用途 |
|------|------|------|
| `0` | 无阴影 | 扁平设计 |
| `1` | 轻微阴影 | 悬浮状态 |

---

## 6. 动画系统

### 6.1 时长 (Duration)

| 令牌名称 | 数值 | 用途 |
|---------|------|------|
| `durationFast` | 150ms | 快速交互（按钮点击、开关切换） |
| `durationNormal` | 250ms | 标准交互（页面切换、弹窗） |
| `durationSlow` | 350ms | 复杂动画（加载动画） |

### 6.2 缓动曲线 (Easing)

| 名称 | 曲线 | 用途 |
|------|------|------|
| `easeOut` | cubic-bezier(0.0, 0.0, 0.2, 1.0) | 标准动画 |
| `easeInOut` | cubic-bezier(0.4, 0.0, 0.2, 1.0) | 进出动画 |

---

## 7. 图标系统

### 7.1 图标尺寸

| 尺寸 | 用途 |
|------|------|
| 16pt | 小图标（标签、按钮内） |
| 20pt | 标准图标（列表图标） |
| 24pt | 导航图标、tab 图标 |
| 32pt | 大图标（空状态） |
| 48pt | 超大图标（欢迎页） |

### 7.2 图标来源

- **Flutter**: Material Icons
- **UniApp**: uView Icons / 自定义 SVG

---

## 8. 触控规范

### 8.1 最小触控区域

| 类型 | 最小尺寸 |
|------|---------|
| 按钮 | 44x44pt |
| 列表项 | 高度 ≥ 48pt |
| 图标按钮 | 44x44pt |

---

## 9. 代码映射

### 9.1 Flutter

```dart
// lib/theme/minimal_tokens.dart
class MinimalTokens {
  // 颜色
  static const Color primary = Color(0xFF007AFF);
  static const Color success = Color(0xFF34C759);

  // 字号
  static const double fontSizeTitle = 20;

  // 间距
  static const double spacing16 = 16;

  // 圆角
  static const double radiusMd = 8;
}
```

### 9.2 UniApp

```scss
// styles/tokens.scss
$tokens: (
  // 颜色
  'primary': #007AFF,
  'success': #34C759,

  // 字号
  'font-size-title': 20rpx * 2,

  // 间距
  'spacing-16': 16rpx * 2,

  // 圆角
  'radius-md': 8rpx * 2,
);
```

---

**修改历史**

| 日期 | 版本 | 修改内容 | 作者 |
|------|------|----------|------|
| 2026-01-12 | v1.0.0 | 初始版本 | 罗耀生 |
