<!-- 位置显示器组件 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-14 -->
<!-- 用途: 舵机位置可视化显示，带轨道和滑动指示器 -->

<template>
  <view class="position-display">
    <view class="position-track"></view>
    <view class="position-indicator" :class="position"></view>
  </view>
</template>

<script>
export default {
  name: 'AppPositionDisplay',
  props: {
    // 位置值: 'up' | 'middle' | 'down'
    position: {
      type: String,
      default: 'middle',
      validator: (value) => ['up', 'middle', 'down'].includes(value)
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.position-display {
  position: relative;
  height: 120rpx;
  background: #FFFFFF;
  border-radius: $radius-lg;
  display: flex;
  align-items: center;
  box-shadow: $shadow-sm;
}

.position-track {
  position: absolute;
  left: 60rpx;
  right: 60rpx;
  top: 50%;
  transform: translateY(-50%);
  height: 8rpx;
  background: $color-bg-secondary;
  border-radius: 4rpx;
}

.position-indicator {
  position: absolute;
  width: 80rpx;
  height: 80rpx;
  background: $color-primary;
  border-radius: 50%;
  top: 50%;
  transform: translateY(-50%);
  transition: left 0.3s, right 0.3s, transform 0.3s;
  box-shadow: 0 8rpx 24rpx rgba(0, 122, 255, 0.3);

  &.up {
    left: 20rpx;
  }

  &.middle {
    left: 50%;
    transform: translate(-50%, -50%);
  }

  &.down {
    left: auto;
    right: 20rpx;
  }
}
</style>
