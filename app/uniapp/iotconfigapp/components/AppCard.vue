<template>
  <view
    :class="classList"
    :style="customStyle"
    @click="handleClick"
    @longpress="handleLongPress"
  >
    <slot />
  </view>
</template>

<script>
export default {
  name: 'AppCard',
  props: {
    // 卡片类型
    type: {
      type: String,
      default: 'default', // default | clickable | outlined | elevated
      validator: (val) => ['default', 'clickable', 'outlined', 'elevated'].includes(val)
    },
    // 自定义内边距
    padding: {
      type: String,
      default: 'md' // xs | sm | md | lg | xl
    },
    // 是否全宽
    isFullWidth: {
      type: Boolean,
      default: true
    },
    // 是否可点击
    clickable: Boolean,
    // 自定义样式
    customStyle: {
      type: Object,
      default: () => ({})
    }
  },
  emits: ['click', 'longpress'],
  computed: {
    classList() {
      const effectiveType = this.clickable ? 'clickable' : this.type;
      return [
        'app-card',
        `app-card--${effectiveType}`,
        `app-card--padding-${this.padding}`,
        {
          'app-card--full-width': this.isFullWidth
        }
      ];
    }
  },
  methods: {
    handleClick(e) {
      if (this.type === 'clickable' || this.clickable) {
        this.$emit('click', e);
      }
    },
    handleLongPress(e) {
      if (this.type === 'clickable' || this.clickable) {
        this.$emit('longpress', e);
      }
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.app-card {
  box-sizing: border-box;
  border-radius: $radius-lg;
  transition: all $duration-fast $ease-out;

  // 全宽
  &--full-width {
    width: 100%;
  }

  // 内边距
  &--padding-xs { padding: $spacing-sm; }
  &--padding-sm { padding: $spacing-md; }
  &--padding-md { padding: $spacing-md; }
  &--padding-lg { padding: $spacing-lg; }
  &--padding-xl { padding: $spacing-xl; }

  // 类型
  &--default {
    background-color: $color-bg-primary;
  }

  &--outlined {
    background-color: $color-bg-primary;
    border: 1px solid $color-border-primary;
  }

  &--elevated {
    background-color: $color-bg-primary;
    box-shadow: $shadow-md;
  }

  &--clickable {
    background-color: $color-bg-primary;
    box-shadow: $shadow-sm;

    &:active {
      background-color: $color-bg-secondary;
    }
  }
}
</style>
