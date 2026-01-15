<!-- 时长选择芯片组组件 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-14 -->
<!-- 用途: 脉冲时长选择（如 300ms/500ms/1s/2s） -->

<template>
  <view class="duration-chip-group">
    <view
      v-for="option in normalizedOptions"
      :key="option.value"
      class="duration-chip"
      :class="{ active: modelValue === option.value }"
      @tap="handleSelect(option.value)"
    >
      <text>{{ option.label }}</text>
    </view>
  </view>
</template>

<script>
export default {
  name: 'AppDurationChipGroup',
  props: {
    modelValue: {
      type: Number,
      default: 500
    },
    // 选项配置：数字数组或对象数组
    // 数字: [300, 500, 1000, 2000]
    // 对象: [{ value: 300, label: '300ms' }, ...]
    options: {
      type: Array,
      default: () => [300, 500, 1000, 2000]
    }
  },
  emits: ['update:modelValue', 'change'],
  computed: {
    normalizedOptions() {
      return this.options.map(opt => {
        if (typeof opt === 'number') {
          return {
            value: opt,
            label: opt >= 1000 ? `${opt / 1000}s` : `${opt}ms`
          };
        }
        return opt;
      });
    }
  },
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

.duration-chip-group {
  display: flex;
  gap: $spacing-sm;
  width: 100%;
  box-sizing: border-box;
}

.duration-chip {
  flex: 1;
  height: 72rpx;
  border: 2rpx solid $color-border-primary;
  border-radius: $radius-md;
  background: #FFFFFF;
  font-size: $font-size-sm;
  color: $color-text-primary;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  box-sizing: border-box;

  &.active {
    background: $color-primary;
    border-color: $color-primary;
    color: #FFFFFF;
  }
}
</style>
