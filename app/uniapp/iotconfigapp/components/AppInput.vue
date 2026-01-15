<template>
  <view class="app-input" :class="{ 'app-input--error': errorText, 'app-input--disabled': disabled }">
    <view v-if="label" class="app-input__label">
      {{ label }}
    </view>
    <view
      class="app-input__wrapper"
      :class="{ 'app-input__wrapper--focused': isFocused }"
    >
      <view v-if="prefixIcon" class="app-input__prefix">
        <slot name="prefixIcon">
          <text :class="prefixIcon" />
        </slot>
      </view>
      <input
        :class="inputClass"
        :type="computedType"
        :value="modelValue"
        :placeholder="hint"
        :placeholder-style="placeholderStyle"
        :disabled="disabled"
        :readonly="readOnly"
        :maxlength="maxLength"
        :password="obscureText"
        @focus="handleFocus"
        @blur="handleBlur"
        @input="handleInput"
        @confirm="handleConfirm"
      />
      <view v-if="suffixIcon || showClear" class="app-input__suffix">
        <slot name="suffixIcon">
          <text
            v-if="showClear"
            class="app-icon--close"
            @click.stop="handleClear"
          />
          <text v-else-if="suffixIcon" :class="suffixIcon" />
        </slot>
      </view>
      <view v-if="obscureText && !suffixIcon" class="app-input__suffix" @click="togglePassword">
        <text :class="showPassword ? 'app-icon--eye-open' : 'app-icon--eye-close'" />
      </view>
    </view>
    <view v-if="errorText || helperText" class="app-input__message">
      {{ errorText || helperText }}
    </view>
  </view>
</template>

<script>
export default {
  name: 'AppInput',
  props: {
    // v-model 值
    modelValue: String,
    // 标签
    label: String,
    // 占位符
    hint: String,
    // 错误提示
    errorText: String,
    // 帮助文本
    helperText: String,
    // 前缀图标
    prefixIcon: String,
    // 后缀图标
    suffixIcon: String,
    // 是否密码类型
    obscureText: Boolean,
    // 是否禁用
    disabled: Boolean,
    // 是否只读
    readOnly: Boolean,
    // 最大长度
    maxLength: Number,
    // 尺寸
    size: {
      type: String,
      default: 'medium', // small | medium | large
      validator: (val) => ['small', 'medium', 'large'].includes(val)
    },
    // 输入类型
    inputType: {
      type: String,
      default: 'text'
    },
    // 是否显示清除按钮
    clearable: {
      type: Boolean,
      default: false
    }
  },
  emits: ['update:modelValue', 'focus', 'blur', 'confirm', 'clear'],
  data() {
    return {
      isFocused: false,
      showPassword: false
    };
  },
  computed: {
    computedType() {
      if (this.obscureText) {
        return this.showPassword ? 'text' : 'password';
      }
      return this.inputType;
    },
    inputClass() {
      return [
        'app-input__field',
        `app-input__field--${this.size}`
      ];
    },
    placeholderStyle() {
      return `color: #999;`;
    },
    showClear() {
      return this.clearable && this.modelValue && !this.disabled && !this.readOnly;
    }
  },
  methods: {
    handleFocus(e) {
      this.isFocused = true;
      this.$emit('focus', e);
    },
    handleBlur(e) {
      this.isFocused = false;
      this.$emit('blur', e);
    },
    handleInput(e) {
      this.$emit('update:modelValue', e.detail.value);
    },
    handleConfirm(e) {
      this.$emit('confirm', e);
    },
    handleClear() {
      this.$emit('update:modelValue', '');
      this.$emit('clear');
    },
    togglePassword() {
      this.showPassword = !this.showPassword;
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.app-input {
  width: 100%;

  &__label {
    margin-bottom: 12rpx;
    font-size: $font-size-sm;
    font-weight: $font-weight-medium;
    color: $color-text-primary;

    .app-input--error & {
      color: $color-error;
    }
  }

  &__wrapper {
    display: flex;
    align-items: center;
    background-color: $color-bg-primary;
    border: 1px solid $color-border-primary;
    border-radius: $radius-md;
    transition: all $duration-fast $ease-out;

    &--focused {
      border-color: $color-border-focus;
      border-width: 2px;
    }

    .app-input--error & {
      border-color: $color-error;
    }

    .app-input--disabled & {
      background-color: $color-bg-disabled;
    }
  }

  &__field {
    flex: 1;
    min-height: 0;
    border: none;
    outline: none;
    background: transparent;
    color: $color-text-primary;

    &--small {
      height: $height-input-sm;
      font-size: $font-size-sm;
      padding: 0 24rpx;
    }

    &--medium {
      height: $height-input-md;
      font-size: $font-size-md;
      padding: 0 24rpx;
    }

    &--large {
      height: $height-input-lg;
      font-size: $font-size-lg;
      padding: 0 32rpx;
    }

    .app-input--disabled & {
      color: $color-text-disabled;
    }
  }

  &__prefix,
  &__suffix {
    display: flex;
    align-items: center;
    justify-content: center;
    min-width: 80rpx;
    height: 100%;
    padding: 0 $spacing-sm;
    color: $color-text-secondary;
    flex-shrink: 0;
  }

  &__suffix {
    cursor: pointer;

    &:active {
      opacity: 0.6;
    }
  }

  &__message {
    margin-top: 12rpx;
    font-size: $font-size-sm;
    color: $color-text-tertiary;

    .app-input--error & {
      color: $color-error;
    }
  }
}
</style>
