<template>
  <view v-if="visible" class="app-dialog-overlay" @click="handleOverlayClick">
    <view class="app-dialog" @click.stop>
      <!-- 标题 -->
      <view v-if="title" class="app-dialog__header">
        <view class="app-dialog__title">{{ title }}</view>
      </view>

      <!-- 内容 -->
      <view class="app-dialog__body">
        <slot>
          <view v-if="message" class="app-dialog__message">{{ message }}</view>
          <input
            v-if="showInput"
            v-model="inputValue"
            class="app-dialog__input"
            :placeholder="inputPlaceholder"
            @confirm="handleConfirm"
          />
        </slot>
      </view>

      <!-- 按钮 -->
      <view class="app-dialog__footer">
        <view
          v-if="showCancel"
          class="app-dialog__button app-dialog__button--cancel"
          @click="handleCancel"
        >
          {{ cancelText }}
        </view>
        <view class="app-dialog__divider" v-if="showCancel" />
        <view
          class="app-dialog__button app-dialog__button--confirm"
          @click="handleConfirm"
        >
          {{ confirmText }}
        </view>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  name: 'AppDialog',
  props: {
    title: String,
    message: String,
    confirmText: {
      type: String,
      default: '确定'
    },
    cancelText: {
      type: String,
      default: '取消'
    },
    showCancel: {
      type: Boolean,
      default: true
    },
    closeOnClickOverlay: {
      type: Boolean,
      default: true
    },
    showInput: Boolean,
    inputPlaceholder: String,
    inputModelValue: String
  },
  emits: ['confirm', 'cancel', 'update:inputModelValue', 'update:visible'],
  data() {
    return {
      visible: false,
      inputValue: ''
    };
  },
  watch: {
    inputModelValue: {
      handler(val) {
        this.inputValue = val;
      },
      immediate: true
    }
  },
  methods: {
    open() {
      this.visible = true;
      this.inputValue = this.inputModelValue || '';
    },
    close() {
      this.visible = false;
    },
    handleConfirm() {
      const result = this.showInput ? this.inputValue : true;
      this.$emit('confirm', result);
      if (!this.showCancel) {
        this.close();
      }
    },
    handleCancel() {
      this.$emit('cancel');
      this.close();
    },
    handleOverlayClick() {
      if (this.closeOnClickOverlay) {
        this.handleCancel();
      }
    }
  }
};

// 单例管理
let dialogInstance = null;

export function showDialog(options) {
  return new Promise((resolve, reject) => {
    // 创建页面实例
    const pages = getCurrentPages();
    const currentPage = pages[pages.length - 1];

    // 动态创建组件
    const dialog = {
      open() {
        // 使用 uni.showModal 代替自定义组件
        const config = {
          title: options.title || '',
          content: options.message || '',
          showCancel: options.showCancel !== false,
          cancelText: options.cancelText || '取消',
          confirmText: options.confirmText || '确定',
          editable: options.showInput || false,
          placeholderText: options.inputPlaceholder || '',
          success: (res) => {
            if (res.confirm) {
              resolve(options.showInput ? res.content : true);
            } else {
              reject('cancel');
            }
          },
          fail: reject
        };
        uni.showModal(config);
      }
    };

    dialog.open();
  });
}

export function showAlert(options) {
  return showDialog({ ...options, showCancel: false });
}

export function showConfirm(options) {
  return showDialog(options);
}

export function showPrompt(options) {
  return showDialog({ ...options, showInput: true });
}
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.app-dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: $color-overlay;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: $z-index-modal;

  &::after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
  }
}

.app-dialog {
  position: relative;
    width: 560rpx;
    background-color: $color-bg-primary;
    border-radius: $radius-xl;
    overflow: hidden;
    z-index: 1;
}

.app-dialog__header {
  padding: $spacing-lg $spacing-md;
    text-align: center;
}

.app-dialog__title {
  font-size: $font-size-lg;
    font-weight: $font-weight-semibold;
    color: $color-text-primary;
}

.app-dialog__body {
  padding: $spacing-md $spacing-lg;
    min-height: 80rpx;
    display: flex;
    align-items: center;
    justify-content: center;
}

.app-dialog__message {
  font-size: $font-size-md;
    color: $color-text-secondary;
    text-align: center;
    line-height: 1.6;
}

.app-dialog__input {
  width: 100%;
    height: 80rpx;
    padding: 0 $spacing-md;
    font-size: $font-size-md;
    color: $color-text-primary;
    background-color: $color-bg-secondary;
    border: 1px solid $color-border-primary;
    border-radius: $radius-md;
    box-sizing: border-box;
}

.app-dialog__footer {
  display: flex;
    border-top: 1px solid $color-border-primary;
}

.app-dialog__button {
  flex: 1;
    height: 96rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: $font-size-md;
    font-weight: $font-weight-medium;
    cursor: pointer;
    transition: background-color $duration-fast $ease-out;

    &:active {
      background-color: $color-bg-secondary;
    }

    &--cancel {
    color: $color-text-secondary;
}

    &--confirm {
    color: $color-primary;
}
}

.app-dialog__divider {
    width: 1px;
    background-color: $color-border-primary;
}
</style>
