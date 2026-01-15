<!-- 导航栏组件 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-14 -->

<template>
  <view class="app-navbar" :style="{ paddingTop: statusBarHeight + 'px' }">
    <view class="navbar-content">
      <!-- 左侧返回按钮 -->
      <view v-if="showBack" class="navbar-back" @tap="handleBack">
        <text class="back-icon">‹</text>
      </view>

      <!-- 中间标题 -->
      <text class="navbar-title" :class="{ 'has-back': showBack, 'has-actions': hasActions }">
        {{ title }}
      </text>

      <!-- 右侧操作区 -->
      <view class="navbar-actions">
        <slot name="actions"></slot>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  name: 'AppNavbar',
  props: {
    // 标题
    title: {
      type: String,
      default: ''
    },
    // 是否显示返回按钮
    showBack: {
      type: Boolean,
      default: true
    },
    // 背景色
    bgColor: {
      type: String,
      default: '#FFFFFF'
    },
    // 是否显示底部边框
    showBorder: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      statusBarHeight: 0
    };
  },
  computed: {
    hasActions() {
      return !!this.$slots.actions;
    }
  },
  onReady() {
    const systemInfo = uni.getSystemInfoSync();
    this.statusBarHeight = systemInfo.statusBarHeight || 0;
  },
  methods: {
    handleBack() {
      this.$emit('back');
      // 默认行为：返回上一页
      uni.navigateBack();
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.app-navbar {
  width: 100%;
  background: v-bind(bgColor);
  box-sizing: border-box;
  position: relative;
  z-index: 100;

  &::after {
    content: '';
    position: absolute;
    left: 0;
    right: 0;
    bottom: 0;
    height: 1rpx;
    background: $color-border-primary;
    transform: scaleY(0.5);
  }
}

.navbar-content {
  display: flex;
  align-items: center;
  height: 88rpx;
  padding: 0 $spacing-md;
}

.navbar-back {
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.back-icon {
  font-size: 56rpx;
  color: $color-text-primary;
  font-weight: 300;
}

.navbar-title {
  flex: 1;
  font-size: $font-size-lg;
  font-weight: $font-weight-semibold;
  color: $color-text-primary;
  text-align: center;

  &.has-back {
    margin-left: -$spacing-md;
  }

  &.has-actions {
    margin-right: -$spacing-md;
  }
}

.navbar-actions {
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
</style>
