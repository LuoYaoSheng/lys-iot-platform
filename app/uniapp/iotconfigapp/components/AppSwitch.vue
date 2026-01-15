<template>
  <view class="app-switch" :class="{ 'app-switch--disabled': disabled }">
    <view
      class="app-switch__input"
      :class="{ 'app-switch__input--checked': modelValue, 'app-switch__input--disabled': disabled }"
      @click="handleToggle"
    >
      <view class="app-switch__track" />
      <view class="app-switch__thumb" />
    </view>
    <view v-if="label" class="app-switch__label" @click="handleLabelClick">
      {{ label }}
    </view>
  </view>
</template>

<script>
export default {
  name: 'AppSwitch',
  props: {
    modelValue: {
      type: Boolean,
      default: false
    },
    label: String,
    disabled: {
      type: Boolean,
      default: false
    }
  },
  emits: ['update:modelValue', 'change'],
  methods: {
    handleToggle() {
      if (this.disabled) return;
      const newValue = !this.modelValue;
      this.$emit('update:modelValue', newValue);
      this.$emit('change', newValue);
    },
    handleLabelClick() {
      if (this.disabled) return;
      this.handleToggle();
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.app-switch {
  display: inline-flex;
  align-items: center;

  &--disabled {
    opacity: 0.5;
  }

  &__input {
    position: relative;
    display: inline-block;
    width: 96rpx;
    height: 56rpx;
    flex-shrink: 0;

    &--checked {
      .app-switch__track {
        background-color: $color-primary;
      }

      .app-switch__thumb {
        transform: translateX(40rpx);
      }
    }

    &--disabled {
      .app-switch__track {
        background-color: $color-bg-tertiary;
      }
    }
  }

  &__track {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: $color-border-secondary;
    border-radius: $radius-full;
    transition: background-color $duration-fast $ease-out;
  }

  &__thumb {
    position: absolute;
    top: 4rpx;
    left: 4rpx;
    width: 48rpx;
    height: 48rpx;
    background-color: #fff;
    border-radius: 50%;
    box-shadow: $shadow-sm;
    transition: transform $duration-fast $ease-out;
  }

  &__label {
    margin-left: $spacing-md;
    font-size: $font-size-md;
    color: $color-text-primary;
  }
}
</style>
