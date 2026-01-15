<!-- 舵机开关控制页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="container">
    <!-- 控制区域 -->
    <view class="control-area">
      <!-- 位置控制面板 -->
      <view class="panel">
        <text class="panel-label">当前位置: {{ position }}</text>

        <!-- 位置显示器 -->
        <view class="display">
          <view class="indicator" :class="position"></view>
        </view>

        <!-- 位置按钮 -->
        <view class="buttons">
          <view class="btn" :class="{ active: position === '上' }" @click="setPosition('上')">上</view>
          <view class="btn" :class="{ active: position === '中' }" @click="setPosition('中')">中</view>
          <view class="btn" :class="{ active: position === '下' }" @click="setPosition('下')">下</view>
        </view>
      </view>

      <!-- 脉冲触发面板 -->
      <view class="panel">
        <text class="panel-title">脉冲触发</text>

        <!-- 高级选项勾选 -->
        <view class="advanced-toggle" @click="showAdvanced = !showAdvanced">
          <view class="checkbox" :class="{ checked: showAdvanced }">
            <text v-if="showAdvanced" class="check-icon">✓</text>
          </view>
          <text class="toggle-text">高级选项</text>
        </view>

        <!-- 脉冲时长设置 -->
        <view class="advanced-options" v-if="showAdvanced">
          <view class="option-row">
            <text class="option-label">脉冲时长</text>
            <text class="option-value">{{ pulseDuration }}ms</text>
          </view>
          <slider
            class="duration-slider"
            :value="pulseDuration"
            :min="100"
            :max="2000"
            :step="100"
            activeColor="#007AFF"
            @change="onDurationChange"
          />
          <view class="duration-hints">
            <text class="hint">100ms</text>
            <text class="hint">2000ms</text>
          </view>
          <view class="preset-btns">
            <view class="preset-btn" :class="{ active: pulseDuration === 200 }" @click="pulseDuration = 200">快速</view>
            <view class="preset-btn" :class="{ active: pulseDuration === 500 }" @click="pulseDuration = 500">标准</view>
            <view class="preset-btn" :class="{ active: pulseDuration === 1000 }" @click="pulseDuration = 1000">慢速</view>
          </view>
        </view>

        <!-- 脉冲触发按钮 -->
        <view class="pulse-btn" :class="{ sending: sending }" @click="sendPulse">
          <text v-if="sending" class="spinner"></text>
          <text class="pulse-text">{{ sending ? '发送中...' : '脉冲触发' }}</text>
        </view>
      </view>

      <!-- 状态信息 -->
      <view class="status">
        <view class="status-dot"></view>
        <text class="status-text">在线</text>
        <text class="status-time">最后更新: 2秒前</text>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      position: '上',
      sending: false,
      showAdvanced: false,
      pulseDuration: 500
    }
  },
  methods: {
    setPosition(pos) {
      this.position = pos
    },
    onDurationChange(e) {
      this.pulseDuration = e.detail.value
    },
    sendPulse() {
      if (this.sending) return
      this.sending = true
      setTimeout(() => {
        this.sending = false
        uni.showToast({ title: '脉冲已发送', icon: 'success' })
      }, this.pulseDuration)
    }
  }
}
</script>

<style lang="scss">
@import '@/styles/tokens.scss';

.container {
  min-height: 100vh;
  background: $color-bg;
}

.control-area {
  padding: $spacing-lg;
}

.panel {
  background: $color-card;
  border-radius: $radius-lg;
  padding: $spacing-lg;
  margin-bottom: $spacing-md;
}

.panel-label {
  font-size: $font-sm;
  color: $color-text-secondary;
  margin-bottom: $spacing-md;
}

.panel-title {
  font-size: $font-md;
  font-weight: 500;
  color: $color-text;
  margin-bottom: $spacing-md;
}

.display {
  height: 160rpx;
  background: $color-bg;
  border-radius: $radius-md;
  margin-bottom: $spacing-md;
  position: relative;
}

.indicator {
  width: 80rpx;
  height: 40rpx;
  background: $color-primary;
  border-radius: 20rpx;
  position: absolute;
  top: 20rpx;
  left: 50%;
  transform: translateX(-50%);
  transition: all 0.3s ease;
  &.中 { top: 60rpx; }
  &.下 { top: 100rpx; }
}

.buttons {
  display: flex;
  gap: $spacing-sm;
}

.btn {
  flex: 1;
  height: 72rpx;
  border: 2rpx solid $color-border;
  border-radius: $radius-md;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: $font-md;
  color: $color-text;
  transition: all 0.2s ease;
  &.active {
    background: $color-primary;
    border-color: $color-primary;
    color: #FFF;
  }
}

// 高级选项勾选框
.advanced-toggle {
  display: flex;
  align-items: center;
  gap: $spacing-sm;
  padding: $spacing-sm 0;
  margin-bottom: $spacing-sm;
}

.checkbox {
  width: 40rpx;
  height: 40rpx;
  border: 2rpx solid $color-border;
  border-radius: $radius-sm;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  &.checked {
    background: $color-primary;
    border-color: $color-primary;
  }
}

.check-icon {
  font-size: 24rpx;
  color: #FFF;
  font-weight: bold;
}

.toggle-text {
  font-size: $font-sm;
  color: $color-text;
}

.advanced-options {
  background: $color-bg;
  border-radius: $radius-md;
  padding: $spacing-md;
  margin-bottom: $spacing-md;
}

.option-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-sm;
}

.option-label {
  font-size: $font-sm;
  color: $color-text;
}

.option-value {
  font-size: $font-md;
  font-weight: 600;
  color: $color-primary;
}

.duration-slider {
  margin: $spacing-sm 0;
}

.duration-hints {
  display: flex;
  justify-content: space-between;
  margin-bottom: $spacing-md;
}

.hint {
  font-size: $font-xs;
  color: $color-text-secondary;
}

.preset-btns {
  display: flex;
  gap: $spacing-sm;
}

.preset-btn {
  flex: 1;
  height: 56rpx;
  border: 2rpx solid $color-border;
  border-radius: $radius-sm;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: $font-xs;
  color: $color-text-secondary;
  &.active {
    background: rgba(0, 122, 255, 0.1);
    border-color: $color-primary;
    color: $color-primary;
  }
}

.pulse-btn {
  height: 88rpx;
  border: 2rpx solid $color-border;
  border-radius: $radius-md;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  &.sending {
    background: $color-bg;
    opacity: 0.7;
  }
}

.pulse-text {
  font-size: $font-md;
  color: $color-text;
}

.spinner {
  width: 32rpx;
  height: 32rpx;
  border: 3rpx solid $color-border;
  border-top-color: $color-primary;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-right: $spacing-sm;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.status {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: $spacing-sm;
  padding: $spacing-lg;
}

.status-dot {
  width: 16rpx;
  height: 16rpx;
  background: $color-success;
  border-radius: 50%;
}

.status-text {
  font-size: $font-md;
  color: $color-text;
}

.status-time {
  font-size: $font-sm;
  color: $color-text-secondary;
}
</style>
