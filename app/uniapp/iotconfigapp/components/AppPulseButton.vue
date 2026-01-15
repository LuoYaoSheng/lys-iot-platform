<!-- 脉冲触发按钮组件 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-14 -->
<!-- 用途: 脉冲触发按钮，支持发送中/成功状态 -->

<template>
  <view
    class="pulse-btn"
    :class="{ sending, success }"
    @tap="handleTap"
  >
    <text class="pulse-icon">{{ iconText }}</text>
    <text>{{ displayText }}</text>
  </view>
</template>

<script>
export default {
  name: 'AppPulseButton',
  props: {
    // 按钮状态
    sending: {
      type: Boolean,
      default: false
    },
    success: {
      type: Boolean,
      default: false
    },
    // 正常状态文本
    text: {
      type: String,
      default: '脉冲触发'
    },
    // 发送中文本
    sendingText: {
      type: String,
      default: '发送中...'
    },
    // 成功状态文本（可选，默认显示时长）
    successText: {
      type: String,
      default: ''
    },
    // 成功时显示的时长（毫秒）
    duration: {
      type: Number,
      default: null
    },
    // 是否禁用
    disabled: {
      type: Boolean,
      default: false
    }
  },
  emits: ['click'],
  computed: {
    iconText() {
      if (this.sending) return '⏳';
      if (this.success) return '✓';
      return '⚡';
    },
    displayText() {
      if (this.sending) return this.sendingText;
      if (this.success) {
        if (this.successText) return this.successText;
        if (this.duration) return `已发送 ${this.duration}ms`;
        return '已发送';
      }
      return this.text;
    }
  },
  methods: {
    handleTap() {
      if (!this.sending && !this.disabled) {
        this.$emit('click');
      }
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.pulse-btn {
  width: 100%;
  height: 112rpx;
  border: 2rpx solid $color-border-primary;
  border-radius: $radius-lg;
  background: #FFFFFF;
  font-size: $font-size-md;
  color: $color-text-primary;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: $spacing-sm;
  transition: all 0.2s;
  box-sizing: border-box;

  &:active {
    transform: scale(0.98);
  }

  &.sending {
    background: $color-bg-secondary;
    border-color: $color-border-primary;
    color: $color-text-tertiary;
  }

  &.success {
    background: $color-success;
    border-color: $color-success;
    color: #FFFFFF;
  }
}

.pulse-icon {
  font-size: 48rpx;
}
</style>
