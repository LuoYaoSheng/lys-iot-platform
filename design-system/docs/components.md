# 组件设计稿

**作者**: 罗耀生
**版本**: v1.0.0

---

## 组件清单

| 组件 | 类型 | 说明 |
|------|------|------|
| DeviceCard | 卡片 | 设备列表项 |
| StatusIndicator | 指示器 | 设备在线状态 |
| ConfigStepper | 步骤器 | 配网进度 |
| ControlPanel | 面板 | 设备控制面板基类 |
| ServoSwitchPanel | 面板 | 舵机混合控制 |
| UsbWakeupPanel | 面板 | USB 唤醒控制 |
| IconButton | 按钮 | 图标按钮 |
| LoadingSpinner | 加载 | 加载动画 |

---

## 1. DeviceCard (设备卡片)

### 用途
设备列表页中显示单个设备的信息和状态

### 布局

```
┌────────────────────────────────────────┐
│ ●  设备名称        在线  ⋮            │
│                                         │
│ 产品: Smart Servo Switch | v1.0.0     │
└────────────────────────────────────────┘
```

### 规格

| 属性 | 值 |
|------|-----|
| 高度 | 72pt |
| 圆角 | `radiusLg` (12pt) |
| 背景色 | `white` (#FFFFFF) |
| 外边距 | `spacing4` (4pt) |
| 内边距 | `spacing16` (16pt) |
| 阴影 | 无 (elevation: 0) |

### 状态变体

#### 在线状态
```
┌────────────────────────────────────────┐
│ 🟢 客厅开关        在线  ⋮            │
│ 位置: 上   固件: 1.0.0                 │
└────────────────────────────────────────┘
```

#### 离线状态
```
┌────────────────────────────────────────┐
│ 🔴 卧室开关        离线  ⋮            │
│ 位置: 下   离线 2 小时前                │
└────────────────────────────────────────┘
```

#### 未激活状态
```
┌────────────────────────────────────────┐
│ ⚪ 新设备        未激活  ⋮            │
│ 等待激活...                            │
└────────────────────────────────────────┘
```

### 文字层级

| 元素 | 字号 | 颜色 | 字重 |
|------|------|------|------|
| 设备名称 | 16pt | `gray700` | Medium (500) |
| 状态文本 | 14pt | `success`/`error`/`gray500` | Regular (400) |
| 产品信息 | 12pt | `gray500` | Regular (400) |

### 代码实现

#### Flutter
```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          children: [
            StatusIndicator(device.status),
            Text(device.name, style: bodyLarge),
            Spacer(),
            Text(device.statusText, style: bodyMedium),
            Icon(Icons.more_vert),
          ],
        ),
        SizedBox(height: 8),
        // 产品信息行
      ],
    ),
  ),
)
```

#### UniApp
```vue
<view class="device-card" :class="statusClass">
  <view class="card-header">
    <view class="status-dot" :class="statusClass"></view>
    <text class="device-name">{{ name }}</text>
    <view class="spacer"></view>
    <text class="status-text">{{ statusText }}</text>
    <text class="more-icon">⋮</text>
  </view>
  <view class="card-footer">
    <text>位置: {{ position }}</text>
    <text>固件: {{ version }}</text>
  </view>
</view>
```

---

## 2. StatusIndicator (状态指示器)

### 用途
显示设备的在线/离线状态

### 规格

| 状态 | 颜色 | 图标 |
|------|------|------|
| 在线 | `success` (#34C759) | ● 8pt |
| 离线 | `error` (#FF3B30) | ● 8pt |
| 未激活 | `gray300` (#C7C7CC) | ● 8pt |
| 禁用 | `warning` (#FF9500) | 🚫 16pt |

### 代码实现

#### Flutter
```dart
Container(
  width: 8,
  height: 8,
  decoration: BoxDecoration(
    color: _getStatusColor(device.status),
    shape: BoxShape.circle,
  ),
)
```

#### UniApp
```vue
<view class="status-dot" :class="statusClass"></view>

<style>
.status-dot.online { background: #34C759; }
.status-dot.offline { background: #FF3B30; }
.status-dot.inactive { background: #C7C7CC; }
</style>
```

---

## 3. ConfigStepper (配网步骤器)

### 用途
显示设备配网的进度状态

### 布局

```
┌─────┬─────┬─────┬─────┐
│  ✓  │  ✓  │  •  │  ○  │
│连接 │发送 │WiFi │激活 │
│设备 │配置 │连接 │设备 │
└─────┴─────┴─────┴─────┘
  25%   50%   75%  100%
```

### 规格

| 属性 | 值 |
|------|-----|
| 每步宽度 | 60pt |
| 圆圈直径 | 24pt |
| 圆角 | `radiusSm` (4pt) |

### 状态样式

| 状态 | 图标 | 背景 | 文字颜色 |
|------|------|------|----------|
| 完成 | ✓ | `success` | `success` |
| 进行中 | • | `primary` | `primary` |
| 待完成 | ○ | `gray100` | `gray300` |

### 代码实现

#### Flutter
```dart
Row(
  children: steps.asMap().entries.map((entry) {
    final index = entry.key;
    final step = entry.value;
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? green :
                      isCurrent ? blue : gray100,
            shape: BoxShape.circle,
          ),
          child: isCompleted ? Icon(Icons.check, size: 16) : null,
        ),
        Text(step.label, style: caption),
      ],
    );
  }).toList(),
)
```

---

## 4. ControlPanel (控制面板基类)

### 用途
所有设备控制面板的基类，定义统一接口

### 通用结构

```
┌────────────────────────────────────┐
│                                    │
│         设备状态显示区              │
│                                    │
├────────────────────────────────────┤
│                                    │
│         控制按钮区                  │
│                                    │
└────────────────────────────────────┘
```

### 接口定义

```dart
abstract class ControlPanel extends StatefulWidget {
  String deviceId;
  String deviceName;
  bool isOnline;

  // 状态数据
  Map<String, dynamic> get currentStatus;

  // 发送控制指令
  Future<void> sendCommand(Map<String, dynamic> command);

  // 刷新状态
  Future<void> refreshStatus();
}
```

---

## 5. ServoSwitchPanel (舵机控制面板)

### 用途
舵机开关设备的三档位置控制和脉冲触发

### 布局

```
┌────────────────────────────────────┐
│                                    │
│        当前位置: 上                 │
│                                    │
│      ┌───┐                         │
│      │ █ │    ●                    │
│      ├───┤                         │
│      │ ○ │    ○                    │
│      └───┘                         │
│                                    │
│  ┌───────┐ ┌───────┐ ┌───────┐    │
│  │  上   │ │  中   │ │  下   │    │
│  └───────┘ └───────┘ └───────┘    │
│                                    │
│  ┌────────────────────────────┐    │
│  │        脉冲触发            │    │
│  └────────────────────────────┘    │
│                                    │
└────────────────────────────────────┘
```

### 规格

| 元素 | 值 |
|------|-----|
| 位置图示 | 120x100pt |
| 位置按钮 | 88x48pt |
| 脉冲按钮 | 全宽 48pt |

### 控制协议

```json
// 位置切换
{
  "action": "toggle",
  "position": "up"     // up / middle / down
}

// 脉冲触发
{
  "action": "pulse",
  "duration": 500      // 毫秒
}
```

### 状态映射

| 服务端值 | 显示 |
|---------|------|
| `up` | 上 (● ○ ○) |
| `middle` | 中 (○ ● ○) |
| `down` | 下 (○ ○ ●) |

---

## 6. UsbWakeupPanel (USB 唤醒面板)

### 用途
USB 唤醒设备的单键触发控制

### 布局

```
┌────────────────────────────────────┐
│                                    │
│                                    │
│            ┌─────────┐             │
│            │         │             │
│            │   ⚡     │             │
│            │         │             │
│            │   唤醒   │             │
│            │         │             │
│            └─────────┘             │
│                                    │
│                                    │
│        点击按钮唤醒电脑             │
│                                    │
└────────────────────────────────────┘
```

### 规格

| 元素 | 值 |
|------|-----|
| 唤醒按钮 | 160x160pt，`radiusXl` (16pt) |
| 图标 | 48pt |
| 按下效果 | 缩放 0.95 |

### 控制协议

```json
{
  "action": "trigger"
}
```

### 交互反馈

| 阶段 | 效果 |
|------|------|
| 按下 | 按钮缩小 0.95，震动 |
| 发送中 | 按钮显示加载动画 |
| 成功 | 按钮绿色闪烁 + "已发送" 提示 |
| 失败 | 按钮红色闪烁 + 错误提示 |

---

## 7. IconButton (图标按钮)

### 用途
各种图标操作按钮

### 规格

| 尺寸 | 按钮大小 | 图标大小 |
|------|---------|---------|
| 小 | 32x32pt | 16pt |
| 中 | 40x40pt | 20pt |
| 大 | 48x48pt | 24pt |

### 变体

#### 填充型
```
┌─────────┐
│    +    │  主色背景，白色图标
└─────────┘
```

#### 轮廓型
```
┌─────────┐
│    ←    │  透明背景，边框
└─────────┘
```

#### 纯图标
```
     ⋮
   无背景
```

### 代码实现

#### Flutter
```dart
// 填充型
IconButton(
  icon: Icon(Icons.add),
  style: ElevatedButton.styleFrom(
    backgroundColor: MinimalTokens.primary,
    foregroundColor: MinimalTokens.white,
    minimumSize: Size(48, 48),
  ),
  onPressed: () {},
)

// 轮廓型
IconButton(
  icon: Icon(Icons.arrow_back),
  style: OutlinedButton.styleFrom(
    minimumSize: Size(40, 40),
  ),
  onPressed: () {},
)
```

---

## 8. LoadingSpinner (加载动画)

### 用途
加载状态指示

### 规格

| 属性 | 值 |
|------|-----|
| 尺寸 | 24pt (标准) / 48pt (大) |
| 颜色 | `primary` (#007AFF) |

### 类型

#### 圆形加载器
```
    ⏳
  (旋转动画)
```

#### 点状加载器
```
  •  •  •
  (跳跃动画)
```

### 代码实现

#### Flutter
```dart
// 圆形
SizedBox(
  width: 24,
  height: 24,
  child: CircularProgressIndicator(
    strokeWidth: 2,
    valueColor: AlwaysStoppedAnimation(primary),
  ),
)
```

#### UniApp
```vue
<view class="loading-spinner">
  <view class="spinner"></view>
</view>

<style>
.spinner {
  width: 48rpx;
  height: 48rpx;
  border: 4rpx solid #f3f3f3;
  border-top: 4rpx solid #007AFF;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}
@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>
```

---

## 9. InputField (输入框)

### 用途
各种文本输入场景

### 布局

```
┌────────────────────────────┐
│ Label                      │
│ ┌────────────────────────┐ │
│ │ Placeholder           👁️│ │
│ └────────────────────────┘ │
│ Helper text               │
└────────────────────────────┘
```

### 规格

| 属性 | 值 |
|------|-----|
| 高度 | 48pt |
| 圆角 | `radiusMd` (8pt) |
| 背景色 | `gray50` (#F5F5F7) |
| 边框 | 1pt `gray200` |
| 内边距 | 横向 16pt，纵向 12pt |

### 状态

| 状态 | 边框颜色 |
|------|----------|
| 默认 | `gray200` |
| 聚焦 | `primary` 2pt |
| 错误 | `error` 1pt |
| 禁用 | `gray300` |

### 代码实现

#### Flutter
```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: MinimalTokens.gray50,
    hintText: '请输入邮箱',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: gray200, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: primary, width: 2),
    ),
  ),
)
```

---

## 10. Button (按钮)

### 用途
各种操作触发

### 类型

#### 主要按钮 (Filled)
```
┌────────────────────┐
│      确 定         │  主色背景，白色文字
└────────────────────┘
```

#### 次要按钮 (Outlined)
```
┌────────────────────┐
│      取 消         │  透明背景，边框
└────────────────────┘
```

#### 文字按钮 (Text)
```
      忘记密码？
   无背景，主色文字
```

### 规格

| 属性 | 值 |
|------|-----|
| 高度 | 48pt |
| 圆角 | `radiusMd` (8pt) |
| 横向内边距 | 24pt |
| 字号 | 16pt，Medium (500) |

### 状态

| 状态 | 主要按钮 | 次要按钮 |
|------|----------|----------|
| 默认 | `primary` 背景 | `primary` 边框 |
| 按下 | `primaryDark` 背景 | `primary` 背景 |
| 禁用 | `gray300` 背景 | `gray300` 边框 |
| 加载 | 显示加载动画 | 显示加载动画 |

---

**修改历史**

| 日期 | 版本 | 修改内容 | 作者 |
|------|------|----------|------|
| 2026-01-12 | v1.0.0 | 初始版本 | 罗耀生 |
