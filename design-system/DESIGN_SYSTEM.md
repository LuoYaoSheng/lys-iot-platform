# Open IoT Platform - 统一设计系统规范
> 作者: 罗耀生
> 版本: 1.0.0
> 更新日期: 2025-01-11

## 设计理念

**"简洁、智能、可靠"**

- **简洁**: 清晰的视觉层次，减少认知负担
- **智能**: 智能的交互反馈，流畅的动画过渡
- **可靠**: 一致的设计语言，可信赖的用户体验

---

## 1. 颜色系统 (Color System)

### 1.1 主色调 (Primary Colors)

| 色名 | 用途 | HEX | RGB | Flutter | UniApp |
|------|------|-----|-----|---------|--------|
| **Primary** | 主要操作、品牌色 | `#6366F1` | `rgb(99, 102, 241)` | `Color(0xFF6366F1)` | `#6366F1` |
| **Primary Light** | 悬停状态 | `#818CF8` | `rgb(129, 140, 248)` | `Color(0xFF818CF8)` | `#818CF8` |
| **Primary Dark** | 按下状态 | `#4F46E5` | `rgb(79, 70, 229)` | `Color(0xFF4F46E5)` | `#4F46E5` |
| **Primary Container** | 容器背景 | `#E0E7FF` | `rgb(224, 231, 255)` | `Color(0xFFE0E7FF)` | `#E0E7FF` |
| **On Primary** | 主色上的文字 | `#FFFFFF` | `rgb(255, 255, 255)` | `Color(0xFFFFFFFF)` | `#FFFFFF` |

### 1.2 语义色 (Semantic Colors)

| 色名 | 用途 | HEX | Flutter | UniApp |
|------|------|-----|---------|--------|
| **Success** | 成功状态 | `#10B981` | `Color(0xFF10B981)` | `#10B981` |
| **Success Light** | 成功背景 | `#D1FAE5` | `Color(0xFFD1FAE5)` | `#D1FAE5` |
| **Warning** | 警告状态 | `#F59E0B` | `Color(0xFFF59E0B)` | `#F59E0B` |
| **Warning Light** | 警告背景 | `#FEF3C7` | `Color(0xFFFEF3C7)` | `#FEF3C7` |
| **Error** | 错误状态 | `#EF4444` | `Color(0xFFEF4444)` | `#EF4444` |
| **Error Light** | 错误背景 | `#FEE2E2` | `Color(0xFFFEE2E2)` | `#FEE2E2` |
| **Info** | 信息状态 | `#3B82F6` | `Color(0xFF3B82F6)` | `#3B82F6` |
| **Info Light** | 信息背景 | `#DBEAFE` | `Color(0xFFDBEAFE)` | `#DBEAFE` |

### 1.3 中性色 (Neutral Colors)

| 色名 | 用途 | HEX | Flutter | UniApp |
|------|------|-----|---------|--------|
| **Gray 50** | 背景色 | `#F9FAFB` | `Color(0xFFF9FAFB)` | `#F9FAFB` |
| **Gray 100** | 浅背景 | `#F3F4F6` | `Color(0xFFF3F4F6)` | `#F3F4F6` |
| **Gray 200** | 分割线 | `#E5E7EB` | `Color(0xFFE5E7EB)` | `#E5E7EB` |
| **Gray 300** | 禁用边框 | `#D1D5DB` | `Color(0xFFD1D5DB)` | `#D1D5DB` |
| **Gray 400** | 占位符 | `#9CA3AF` | `Color(0xFF9CA3AF)` | `#9CA3AF` |
| **Gray 500** | 次要文字 | `#6B7280` | `Color(0xFF6B7280)` | `#6B7280` |
| **Gray 600** | 辅助文字 | `#4B5563` | `Color(0xFF4B5563)` | `#4B5563` |
| **Gray 700** | 主要文字 | `#374151` | `Color(0xFF374151)` | `#374151` |
| **Gray 800** | 标题文字 | `#1F2937` | `Color(0xFF1F2937)` | `#1F2937` |
| **Gray 900** | 强调文字 | `#111827` | `Color(0xFF111827)` | `#111827` |
| **White** | 纯白 | `#FFFFFF` | `Color(0xFFFFFFFF)` | `#FFFFFF` |

### 1.4 设备状态色 (Device Status)

| 状态 | HEX | 用途 |
|------|-----|------|
| **Online** | `#10B981` | 设备在线 |
| **Offline** | `#9CA3AF` | 设备离线 |
| **Connecting** | `#F59E0B` | 连接中 |
| **Error** | `#EF4444` | 错误状态 |

---

## 2. 字体系统 (Typography)

### 2.1 字体家族

```dart
// Flutter
static const fontFamily = {
  'sans': ['SF Pro Display', 'PingFang SC', 'Microsoft YaHei', 'sans-serif'],
}
```

```css
/* UniApp / CSS */
--font-family-base: -apple-system, BlinkMacSystemFont, 'SF Pro Display',
  'PingFang SC', 'Microsoft YaHei', 'Helvetica Neue', sans-serif;
```

### 2.2 字体大小 (Font Size)

| 级别 | 大小 | 用途 | Flutter | UniApp |
|------|------|------|---------|--------|
| **Display Large** | 57px | 特大标题 | `fontSize: 57` | `114rpx` |
| **Display Medium** | 45px | 大标题 | `fontSize: 45` | `90rpx` |
| **Headline Large** | 32px | 页面标题 | `fontSize: 32` | `64rpx` |
| **Headline Medium** | 28px | 区块标题 | `fontSize: 28` | `56rpx` |
| **Headline Small** | 24px | 小标题 | `fontSize: 24` | `48rpx` |
| **Title Large** | 22px | 卡片标题 | `fontSize: 22` | `44rpx` |
| **Title Medium** | 18px | 列表标题 | `fontSize: 18` | `36rpx` |
| **Body Large** | 17px | 正文大 | `fontSize: 17` | `34rpx` |
| **Body Medium** | 16px | 正文 | `fontSize: 16` | `32rpx` |
| **Body Small** | 14px | 正文小 | `fontSize: 14` | `28rpx` |
| **Label Large** | 14px | 标签大 | `fontSize: 14` | `28rpx` |
| **Label Medium** | 12px | 标签 | `fontSize: 12` | `24rpx` |
| **Label Small** | 11px | 标签小 | `fontSize: 11` | `22rpx` |

### 2.3 字重 (Font Weight)

| 名称 | 数值 | Flutter | CSS |
|------|------|---------|-----|
| **Light** | 300 | `FontWeight.w300` | `300` |
| **Regular** | 400 | `FontWeight.w400` | `400` |
| **Medium** | 500 | `FontWeight.w500` | `500` |
| **SemiBold** | 600 | `FontWeight.w600` | `600` |
| **Bold** | 700 | `FontWeight.w700` | `700` |

---

## 3. 间距系统 (Spacing)

基于 **8px 基准网格** (8pt Base Grid)

| 级别 | 值 | 用途 | Flutter | UniApp |
|------|-----|------|---------|--------|
| **spacing-0** | 0px | 无间距 | `0` | `0` |
| **spacing-1** | 4px | 极小间距 | `4` | `8rpx` |
| **spacing-2** | 8px | 超小间距 | `8` | `16rpx` |
| **spacing-3** | 12px | 小间距 | `12` | `24rpx` |
| **spacing-4** | 16px | 标准间距 | `16` | `32rpx` |
| **spacing-5** | 20px | 中等间距 | `20` | `40rpx` |
| **spacing-6** | 24px | 大间距 | `24` | `48rpx` |
| **spacing-8** | 32px | 超大间距 | `32` | `64rpx |
| **spacing-10** | 40px | 特大间距 | `40` | `80rpx` |
| **spacing-12** | 48px | 巨大间距 | `48` | `96rpx` |
| **spacing-16** | 64px | 页面边距 | `64` | `128rpx` |

---

## 4. 圆角系统 (Border Radius)

| 级别 | 值 | 用途 | Flutter | UniApp |
|------|-----|------|---------|--------|
| **radius-none** | 0px | 无圆角 | `Radius.zero` | `0` |
| **radius-sm** | 4px | 小圆角 | `Radius.circular(4)` | `8rpx` |
| **radius-md** | 8px | 中圆角 | `Radius.circular(8)` | `16rpx` |
| **radius-lg** | 12px | 大圆角 | `Radius.circular(12)` | `24rpx` |
| **radius-xl** | 16px | 卡片圆角 | `Radius.circular(16)` | `32rpx` |
| **radius-2xl** | 24px | 大卡片圆角 | `Radius.circular(24)` | `48rpx` |
| **radius-full** | 9999px | 完全圆角 | `Radius.circular(9999)` | `9999rpx` |

---

## 5. 阴影/高度系统 (Elevation)

| 级别 | 描述 | Flutter (BoxShadow) | UniApp (box-shadow) |
|------|------|---------------------|---------------------|
| **elevation-0** | 无阴影 | `[]` | `none` |
| **elevation-1** | 轻微抬起 | `[BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 2)]` | `0 1px 2px rgba(0,0,0,0.04)` |
| **elevation-2** | 标准抬起 | `[BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 4)]` | `0 2px 4px rgba(0,0,0,0.06)` |
| **elevation-3** | 明显抬起 | `[BoxShadow(color: Color(0x10000000), offset: Offset(0, 4), blurRadius: 8)]` | `0 4px 8px rgba(0,0,0,0.08)` |
| **elevation-4** | 高抬起 | `[BoxShadow(color: Color(0x14000000), offset: Offset(0, 8), blurRadius: 16)]` | `0 8px 16px rgba(0,0,0,0.10)` |
| **elevation-5** | 超高抬起 | `[BoxShadow(color: Color(0x1A000000), offset: Offset(0, 12), blurRadius: 24)]` | `0 12px 24px rgba(0,0,0,0.12)` |

---

## 6. 组件样式规范

### 6.1 按钮 (Button)

| 类型 | 高度 | 内边距 | 圆角 | 字体大小 |
|------|------|--------|------|----------|
| **Large** | 56px | h24 | 16px | 18px |
| **Medium** | 48px | h20 | 12px | 16px |
| **Small** | 40px | h16 | 10px | 14px |

### 6.2 输入框 (Input)

| 属性 | 值 |
|------|-----|
| 高度 | 48px |
| 内边距 | h12 v16 |
| 圆角 | 12px |
| 边框 | 1px solid Gray 200 |
| 聚焦边框 | 2px solid Primary |

### 6.3 卡片 (Card)

| 属性 | 值 |
|------|-----|
| 内边距 | 16px / 24px |
| 圆角 | 16px |
| 阴影 | elevation-2 |
| 背景色 | White |

### 6.4 列表项 (List Item)

| 属性 | 值 |
|------|-----|
| 高度 | 64px |
| 内边距 | h12 v16 |
| 分割线 | 1px solid Gray 100 |

### 6.5 导航栏 (Navigation Bar)

| 属性 | 值 |
|------|-----|
| 高度 | 56px |
| 背景色 | White |
| 阴影 | elevation-1 |
| 标题字体 | Headline Small (SemiBold) |

---

## 7. 图标系统

使用 **Material Icons** (Flutter) 和 **uni-icons** (UniApp)

| 功能 | Material Icon | uni-icon |
|------|---------------|----------|
| 首页 | `home` | `home` |
| 设备 | `devices` | `settings` |
| 设置 | `settings` | `gear` |
| 添加 | `add` | `plus` |
| 删除 | `delete` | `trash` |
| 编辑 | `edit` | `compose` |
| WiFi | `wifi` | `wifi` |
| 蓝牙 | `bluetooth` | `Bluetooth` |
| 电源 | `power_settings_new` | `power` |
| 灯光 | `lightbulb` | `lightbulb` |
| 空调 | `ac_unit` | `snow` |
| 窗帘 | `curtains` | `loop` |
| 传感器 | `sensors` | `activity` |

---

## 8. 动画规范 (Animation)

### 8.1 缓动曲线 (Easing)

| 名称 | Cubic Bezier | 用途 |
|------|--------------|------|
| **Standard** | (0.4, 0.0, 0.2, 1) | 标准动画 |
| **Emphasized** | (0.0, 0.0, 0.2, 1) | 强调动画 |
| **Decelerated** | (0.0, 0.0, 0.2, 1) | 减速动画 |
| **Accelerated** | (0.4, 0.0, 1, 1) | 加速动画 |

### 8.2 持续时间 (Duration)

| 级别 | 时间 | 用途 |
|------|------|------|
| **Fast** | 150ms | 微交互 |
| **Normal** | 250ms | 标准过渡 |
| **Slow** | 350ms | 复杂动画 |
| **Slower** | 500ms | 页面切换 |

---

## 9. 响应式断点 (Breakpoints)

| 断点 | 宽度 | 设备 |
|------|------|------|
| **Mobile** | < 576px | 手机 |
| **Tablet** | 576px - 768px | 平板 |
| **Desktop** | > 768px | 桌面 |

---

## 10. 暗色模式 (Dark Mode)

| 色名 | Light | Dark |
|------|-------|------|
| **Background** | Gray 50 | Gray 900 |
| **Surface** | White | Gray 800 |
| **Primary** | Primary | Primary Light |
| **On Primary** | White | Gray 900 |
| **Text Primary** | Gray 900 | Gray 100 |
| **Text Secondary** | Gray 500 | Gray 400 |
| **Border** | Gray 200 | Gray 700 |

---

## 实现文件

- Flutter: `mobile-app/lib/theme/app_theme.dart`
- UniApp: `open-iot-uniapp/styles/theme.scss`

---

*本设计系统遵循 Material Design 3 和 iOS Human Interface Guidelines 的最佳实践*
