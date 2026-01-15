<template>
  <view class="app-list-item" @click="handleClick" @longpress="handleLongPress">
    <view class="app-list-item__content" :class="{ 'app-list-item__content--clickable': clickable }">
      <slot name="leading">
        <view v-if="leading" class="app-list-item__leading">
          <image v-if="leading.avatar" :src="leading.avatar" class="app-list-item__avatar" />
          <view v-else-if="leading.icon" class="app-list-item__icon" :class="leading.icon" />
        </view>
      </slot>

      <view class="app-list-item__body">
        <slot>
          <view v-if="title" class="app-list-item__title">
            {{ title }}
          </view>
          <view v-if="subtitle" class="app-list-item__subtitle">
            {{ subtitle }}
          </view>
          <view v-if="extra" class="app-list-item__extra">
            {{ extra }}
          </view>
        </slot>
      </view>

      <slot name="trailing">
        <view v-if="trailing" class="app-list-item__trailing">
          <text v-if="typeof trailing === 'string'" class="app-list-item__trailing-text">
            {{ trailing }}
          </text>
          <view v-else class="app-icon--arrow-right" />
        </view>
      </slot>
    </view>
    <view v-if="showDivider && !isLast" class="app-list-item__divider" />
  </view>
</template>

<script>
export default {
  name: 'AppListItem',
  props: {
    // 标题
    title: String,
    // 副标题
    subtitle: String,
    // 额外信息
    extra: String,
    // 前置内容
    leading: {
      type: [Object, String],
      default: null
    },
    // 后置内容
    trailing: {
      type: [String, Boolean],
      default: null
    },
    // 是否可点击
    clickable: {
      type: Boolean,
      default: false
    },
    // 是否显示分割线
    showDivider: {
      type: Boolean,
      default: true
    },
    // 是否是最后一项
    isLast: {
      type: Boolean,
      default: false
    }
  },
  emits: ['click', 'longpress'],
  methods: {
    handleClick(e) {
      if (this.clickable) {
        this.$emit('click', e);
      }
    },
    handleLongPress(e) {
      if (this.clickable) {
        this.$emit('longpress', e);
      }
    }
  }
};
</script>

<style lang="scss" scoped>
@import '@/styles/app-tokens.scss';

.app-list-item {
  background-color: $color-bg-primary;

  &__content {
    display: flex;
    align-items: center;
    padding: $spacing-md $spacing-md;
    min-height: 88rpx;
    box-sizing: border-box;

    &--clickable {
      cursor: pointer;
      transition: background-color $duration-fast $ease-out;

      &:active {
        background-color: $color-bg-secondary;
      }
    }
  }

  &__leading {
    display: flex;
    align-items: center;
    margin-right: $spacing-md;
    flex-shrink: 0;
  }

  &__avatar {
    width: 80rpx;
    height: 80rpx;
    border-radius: $radius-lg;
  }

  &__icon {
    width: 72rpx;
    height: 72rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 40rpx;
    color: $color-text-secondary;
    background-color: $color-bg-secondary;
    border-radius: $radius-md;
  }

  &__body {
    flex: 1;
    min-width: 0;
  }

  &__title {
    font-size: $font-size-md;
    font-weight: $font-weight-normal;
    color: $color-text-primary;
    @include text-ellipsis;
  }

  &__subtitle {
    font-size: $font-size-sm;
    color: $color-text-secondary;
    margin-top: 4rpx;
    @include text-ellipsis;
  }

  &__extra {
    font-size: $font-size-sm;
    color: $color-text-tertiary;
    margin-top: 4rpx;
    @include text-ellipsis;
  }

  &__trailing {
    display: flex;
    align-items: center;
    margin-left: $spacing-md;
    flex-shrink: 0;
  }

  &__trailing-text {
    font-size: $font-size-md;
    color: $color-text-secondary;
  }

  &__divider {
    height: 1px;
    background-color: $color-border-primary;
    margin-left: $spacing-md;
  }
}

// 箭头图标样式
.app-icon--arrow-right {
  width: 32rpx;
  height: 32rpx;
  position: relative;
  opacity: 0.3;

  &::before {
    content: '';
    position: absolute;
    width: 10rpx;
    height: 10rpx;
    border-top: 2px solid $color-text-primary;
    border-right: 2px solid $color-text-primary;
    transform: rotate(45deg);
    right: 4rpx;
  }
}
</style>
