<template>
  <view class="app-empty">
    <view class="app-empty__icon">
      <slot name="icon">
        <view class="app-empty__default-icon">
          <text class="app-icon--empty" />
        </view>
      </slot>
    </view>
    <view v-if="message" class="app-empty__message">
      {{ message }}
    </view>
    <view v-if="actionText" class="app-empty__action" @click="handleAction">
      <slot name="action">
        <view class="app-empty__button">{{ actionText }}</view>
      </slot>
    </view>
  </view>
</template>

<script>
export default {
  name: 'AppEmpty',
  props: {
    message: {
      type: String,
      default: '暂无数据'
    },
    actionText: String
  },
  emits: ['action'],
  methods: {
    handleAction() {
      this.$emit('action');
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.app-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: $spacing-xxl $spacing-xl;

  &__icon {
    margin-bottom: $spacing-lg;
  }

  &__default-icon {
    width: 240rpx;
    height: 240rpx;
    background-color: $color-bg-secondary;
    border-radius: $radius-xxl;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  &__message {
    font-size: $font-size-md;
    color: $color-text-secondary;
    text-align: center;
    margin-bottom: $spacing-md;
  }

  &__action {
    margin-top: $spacing-sm;
  }

  &__button {
    padding: 0 $spacing-lg;
    height: 72rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: $color-primary;
    color: #fff;
    font-size: $font-size-md;
    border-radius: $radius-lg;
  }
}

// 空状态图标
.app-icon--empty {
  font-size: 120rpx;
  color: $color-text-tertiary;

  &::before {
    content: '📭';
  }
}
</style>
