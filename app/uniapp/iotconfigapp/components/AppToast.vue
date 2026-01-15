<template>
  <view v-if="visible" :class="classList" :style="positionStyle">
    <view v-if="type === 'loading'" class="app-toast__spinner" />
    <view v-else-if="type !== 'info'" class="app-toast__icon" :class="iconClass" />
    <view v-if="message" class="app-toast__message">{{ message }}</view>
  </view>
</template>

<script>
let toastInstance = null;

export default {
  name: 'AppToast',
  props: {
    message: String,
    type: {
      type: String,
      default: 'info', // info | success | error | warning | loading
      validator: (val) => ['info', 'success', 'error', 'warning', 'loading'].includes(val)
    },
    duration: {
      type: Number,
      default: 2000
    },
    position: {
      type: String,
      default: 'center', // top | center | bottom
      validator: (val) => ['top', 'center', 'bottom'].includes(val)
    }
  },
  data() {
    return {
      visible: false,
      timer: null
    };
  },
  computed: {
    classList() {
      return [
        'app-toast',
        `app-toast--${this.type}`,
        `app-toast--${this.position}`
      ];
    },
    iconClass() {
      switch (this.type) {
        case 'success':
          return 'app-icon--success';
        case 'error':
          return 'app-icon--error';
        case 'warning':
          return 'app-icon--warning';
        default:
          return '';
      }
    },
    positionStyle() {
      switch (this.position) {
        case 'top':
          return 'top: 15%';
        case 'center':
          return 'top: 50%';
        case 'bottom':
          return 'bottom: 15%';
        default:
          return '';
      }
    }
  },
  methods: {
    show() {
      this.visible = true;
      if (this.type !== 'loading') {
        this.timer = setTimeout(() => {
          this.hide();
        }, this.duration);
      }
    },
    hide() {
      this.visible = false;
      if (this.timer) {
        clearTimeout(this.timer);
        this.timer = null;
      }
    }
  }
};

// 单例方法
export function showToast(options) {
  if (typeof options === 'string') {
    options = { message: options };
  }

  uni.showToast({
    title: options.message || '',
    icon: getIconType(options.type),
    duration: options.duration || 2000,
    mask: options.mask || false
  });
}

export function showSuccess(message, options = {}) {
  showToast({ ...options, message, type: 'success' });
}

export function showError(message, options = {}) {
  showToast({ ...options, message, type: 'error' });
}

export function showWarning(message, options = {}) {
  showToast({ ...options, message, type: 'warning' });
}

export function showLoading(message = '加载中...', options = {}) {
  uni.showLoading({
    title: message,
    mask: options.mask || true
  });
}

export function hideLoading() {
  uni.hideLoading();
}

export function hideToast() {
  uni.hideToast();
}

function getIconType(type) {
  switch (type) {
    case 'success':
      return 'success';
    case 'error':
      return 'error';
    case 'warning':
      return 'none';
    case 'loading':
      return 'loading';
    default:
      return 'none';
  }
}
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.app-toast {
  position: fixed;
  left: 50%;
  transform: translateX(-50%);
  max-width: 70%;
  padding: $spacing-md $spacing-lg;
  background-color: rgba(0, 0, 0, 0.8);
  border-radius: $radius-lg;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: $z-index-tooltip;

  &--center {
    transform: translate(-50%, -50%);
  }

  &--bottom {
    transform: translateX(-50%);
  }

  &__spinner {
    width: 40rpx;
    height: 40rpx;
    border: 3px solid #fff;
    border-top-color: transparent;
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin-bottom: $spacing-sm;
  }

  &__icon {
    width: 40rpx;
    height: 40rpx;
    margin-bottom: $spacing-sm;
  }

  &__message {
    font-size: $font-size-md;
    color: #fff;
    text-align: center;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
}

// 自定义图标样式
.app-icon--success,
.app-icon--error,
.app-icon--warning {
  position: relative;
}

.app-icon--success::before {
  content: '✓';
  font-size: 40rpx;
  color: $color-success;
}

.app-icon--error::before {
  content: '✕';
  font-size: 40rpx;
  color: $color-error;
}

.app-icon--warning::before {
  content: '!';
  font-size: 40rpx;
  color: $color-warning;
}
</style>
