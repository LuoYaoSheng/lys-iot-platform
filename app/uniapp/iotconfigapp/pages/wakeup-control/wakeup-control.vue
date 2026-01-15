<!-- USB唤醒控制页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="container">
    <!-- 控制区域 - 整体居中（与Flutter一致） -->
    <view class="control-area">
      <!-- 唤醒按钮 -->
      <view class="wakeup-btn" :class="{ sending: sending, success: success }" @click="sendWakeup">
        <text v-if="sending" class="spinner"></text>
        <AppIcon v-else-if="success" name="check" :size="160" color="#FFFFFF" />
        <AppIcon v-else name="bolt" :size="160" color="#FFFFFF" />
        <text v-if="!sending && !success" class="btn-text">唤醒</text>
      </view>

      <!-- 状态信息 -->
      <view class="status">
        <view class="status-dot"></view>
        <text class="status-text">在线</text>
        <text class="status-time">最后更新: 5秒前</text>
      </view>

      <!-- 设备信息 -->
      <view class="info">
        <text class="info-label">设备信息</text>
        <text class="info-name">USB-WAKEUP-S3</text>
        <text class="info-firmware">固件: 1.0.0</text>
      </view>
    </view>
  </view>
</template>

<script>
import AppIcon from '@/components/AppIcon.vue'

export default {
  components: { AppIcon },
  data() {
    return {
      sending: false,
      success: false
    }
  },
  methods: {
    sendWakeup() {
      if (this.sending) return

      this.sending = true
      setTimeout(() => {
        this.sending = false
        this.success = true
        setTimeout(() => {
          this.success = false
        }, 2000)
      }, 800)
    }
  }
}
</script>

<style lang="scss">
@import '@/styles/tokens.scss';

.container {
  min-height: 100vh;
  background: $color-bg;
  display: flex;
  flex-direction: column;
}

// 控制区域 - 整体居中（与Flutter一致）
.control-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: $spacing-xl;
}

// 唤醒按钮
.wakeup-btn {
  width: 400rpx;
  height: 400rpx;
  background: $color-primary;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: $spacing-md;
  box-shadow: 0 16rpx 48rpx rgba(0, 122, 255, 0.3);
  transition: all 0.3s ease;

  &.sending {
    opacity: 0.7;
  }

  &.success {
    background: $color-success;
    box-shadow: 0 16rpx 48rpx rgba(52, 199, 89, 0.3);
  }
}

.icon {
  font-size: 160rpx;
  color: #FFF;
}

.btn-text {
  font-size: 48rpx;
  color: #FFF;
  font-weight: 500;
}

.spinner {
  width: 80rpx;
  height: 80rpx;
  border: 8rpx solid rgba(255, 255, 255, 0.3);
  border-top-color: #FFF;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

// 状态信息
.status {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: $spacing-sm;
  margin-top: 96rpx;
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
  margin-left: $spacing-sm;
}

// 设备信息
.info {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 96rpx;
}

.info-label {
  font-size: $font-xs;
  color: $color-text-secondary;
  margin-bottom: $spacing-md;
}

.info-name {
  font-size: $font-md;
  color: $color-text;
  font-weight: 500;
  margin-bottom: $spacing-xs;
}

.info-firmware {
  font-size: $font-xs;
  color: $color-text-secondary;
}
</style>
