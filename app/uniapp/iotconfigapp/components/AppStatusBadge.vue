<!-- 状态徽章组件 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-14 -->
<!-- 用途: 显示设备/项目状态的小标签 -->

<template>
  <view class="status-badge" :class="statusClass">
    <text>{{ displayText }}</text>
  </view>
</template>

<script>
export default {
  name: 'AppStatusBadge',
  props: {
    // 状态值: 'online' | 'offline' | 'configuring' | 自定义
    status: {
      type: String,
      default: 'offline'
    },
    // 自定义显示文本
    text: {
      type: String,
      default: ''
    }
  },
  computed: {
    statusClass() {
      return this.status;
    },
    displayText() {
      if (this.text) return this.text;
      const map = {
        online: '在线',
        offline: '离线',
        configuring: '配置中'
      };
      return map[this.status] || this.status;
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.status-badge {
  padding: 8rpx 20rpx;
  border-radius: $radius-sm;
  font-size: $font-size-sm;
  font-weight: $font-weight-medium;
  display: inline-block;

  &.online {
    background: rgba(52, 199, 89, 0.1);
    color: $color-success;
  }

  &.offline {
    background: rgba(142, 142, 147, 0.1);
    color: $color-text-tertiary;
  }

  &.configuring {
    background: rgba(255, 149, 0, 0.1);
    color: $color-warning;
  }
}
</style>
