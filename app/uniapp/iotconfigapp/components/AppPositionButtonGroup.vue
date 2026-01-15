<!-- 位置按钮组组件 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-14 -->
<!-- 用途: 舵机位置选择按钮组（上/中/下） -->

<template>
  <view class="position-button-group">
    <view
      v-for="option in options"
      :key="option.value"
      class="position-btn"
      :class="{ active: modelValue === option.value }"
      @tap="handleSelect(option.value)"
    >
      <text>{{ option.label }}</text>
    </view>
  </view>
</template>

<script>
export default {
  name: 'AppPositionButtonGroup',
  props: {
    modelValue: {
      type: String,
      default: 'middle'
    },
    // 自定义选项 [{ value: 'up', label: '上' }, ...]
    options: {
      type: Array,
      default: () => [
        { value: 'up', label: '上' },
        { value: 'middle', label: '中' },
        { value: 'down', label: '下' }
      ]
    }
  },
  emits: ['update:modelValue', 'change'],
  methods: {
    handleSelect(value) {
      this.$emit('update:modelValue', value);
      this.$emit('change', value);
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.position-button-group {
  display: flex;
  gap: $spacing-sm;
  width: 100%;
  box-sizing: border-box;
}

.position-btn {
  flex: 1;
  height: 112rpx;
  background: #FFFFFF;
  border: 2rpx solid $color-border-primary;
  border-radius: $radius-lg;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: $font-size-xl;
  color: $color-text-primary;
  transition: all 0.2s;
  box-sizing: border-box;

  &.active {
    background: $color-primary;
    border-color: $color-primary;
    color: #FFFFFF;
  }
}
</style>
