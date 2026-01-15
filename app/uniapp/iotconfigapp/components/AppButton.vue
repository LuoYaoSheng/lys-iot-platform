<template>
  <view
    :class="classList"
    :style="customStyle"
    :hover-class="hoverClass"
    @click="handleClick"
  >
    <view v-if="isLoading" class="app-button__loading">
      <view class="app-button__spinner" />
    </view>
    <view v-else-if="icon" class="app-button__icon">
      <slot name="icon">
        <text :class="icon" />
      </slot>
    </view>
    <view v-if="text" class="app-button__text">
      <slot>{{ text }}</slot>
    </view>
  </view>
</template>

<script>
export default {
  name: 'AppButton',
  props: {
    // 按钮类型
    type: {
      type: String,
      default: 'primary', // primary | secondary | text | danger | icon
      validator: (val) => ['primary', 'secondary', 'text', 'danger', 'icon'].includes(val)
    },
    // 按钮尺寸
    size: {
      type: String,
      default: 'medium', // small | medium | large
      validator: (val) => ['small', 'medium', 'large'].includes(val)
    },
    // 按钮文本
    text: String,
    // 图标类名
    icon: String,
    // 是否加载中
    isLoading: Boolean,
    // 是否禁用
    disabled: Boolean,
    // 是否全宽
    isFullWidth: {
      type: Boolean,
      default: false
    },
    // 自定义样式
    customStyle: {
      type: Object,
      default: () => ({})
    }
  },
  emits: ['click'],
  computed: {
    classList() {
      return [
        'app-button',
        `app-button--${this.type}`,
        `app-button--${this.size}`,
        {
          'app-button--disabled': this.disabled || this.isLoading,
          'app-button--full-width': this.isFullWidth
        }
      ];
    },
    hoverClass() {
      if (this.disabled || this.isLoading) return '';
      if (this.type === 'text') return 'app-button--hover';
      return `app-button--${this.type}--active`;
    }
  },
  methods: {
    handleClick(e) {
      if (this.disabled || this.isLoading) return;
      this.$emit('click', e);
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.app-button {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  box-sizing: border-box;
  border: none;
  outline: none;
  transition: all $duration-normal $ease-out;
  white-space: nowrap;
  cursor: pointer;

  &::after {
    border: none;
  }

  // 尺寸
  &--small {
    height: $height-button-sm;
    padding: 0 $spacing-md;
    font-size: $font-size-sm;
    border-radius: $radius-md;

    .app-button__icon {
      font-size: $font-size-lg;
    }
  }

  &--medium {
    height: $height-button-md;
    padding: 0 $spacing-lg;
    font-size: $font-size-md;
    border-radius: $radius-lg;

    .app-button__icon {
      font-size: 18px;
    }
  }

  &--large {
    height: $height-button-lg;
    padding: 0 $spacing-xl;
    font-size: $font-size-lg;
    border-radius: $radius-lg;

    .app-button__icon {
      font-size: $font-size-xl;
    }
  }

  // 类型
  &--primary {
    background-color: $color-primary;
    color: #fff;

    &:active, &--active {
      background-color: $color-primary-active;
    }
  }

  &--secondary {
    background-color: $color-bg-secondary;
    color: $color-text-primary;
    border: 1px solid $color-border-secondary;

    &:active, &--active {
      background-color: $color-bg-tertiary;
    }
  }

  &--text {
    background-color: transparent;
    color: $color-text-secondary;

    &--hover {
      background-color: $color-bg-secondary;
    }

    &:active {
      color: $color-text-tertiary;
    }
  }

  &--danger {
    background-color: $color-error;
    color: #fff;

    &:active, &--active {
      background-color: #D62828;
    }
  }

  // 禁用状态
  &--disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  // 全宽
  &--full-width {
    width: 100%;
  }

  // 加载
  &__loading {
    display: flex;
    align-items: center;
  }

  &__spinner {
    width: 1em;
    height: 1em;
    border: 2px solid currentColor;
    border-top-color: transparent;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  // 图标
  &__icon {
    display: flex;
    align-items: center;
  }

  // 文本
  &__text {
    font-weight: $font-weight-medium;
  }

  // 图标和文本间距
  .app-button__icon + .app-button__text,
  .app-button__loading + .app-button__text {
    margin-left: $spacing-sm;
  }
}
</style>
