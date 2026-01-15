<!-- 关于页 -->
<!-- 作者: 罗耀生 -->

<template>
  <view class="about">
    <!-- Logo -->
    <view class="logo-section">
      <view class="logo">
        <AppIcon name="bolt" :size="64" color="#FFFFFF" />
      </view>
      <text class="app-name">Open IoT Platform</text>
      <text class="app-desc">轻量级开源 IoT 设备管理平台</text>
    </view>

    <!-- 版本信息 -->
    <view class="card">
      <view class="info-item">
        <text class="info-label">版本号</text>
        <text class="info-value">v1.0.0</text>
      </view>
      <view class="info-item">
        <text class="info-label">构建日期</text>
        <text class="info-value">2026-01-14</text>
      </view>
    </view>

    <!-- 相关链接 -->
    <text class="group-title">相关链接</text>
    <view class="card">
      <view class="link-item" @click="openLink('github')">
        <AppIcon name="link" :size="32" color="#8E8E93" />
        <text class="link-label">GitHub</text>
        <text class="link-arrow">›</text>
      </view>
      <view class="link-item" @click="openLink('changelog')">
        <AppIcon name="document" :size="32" color="#8E8E93" />
        <text class="link-label">更新日志</text>
        <text class="link-arrow">›</text>
      </view>
      <view class="link-item" @click="openLink('license')">
        <AppIcon name="license" :size="32" color="#8E8E93" />
        <text class="link-label">开源协议</text>
        <text class="link-value">GPL v3</text>
        <text class="link-arrow">›</text>
      </view>
    </view>

    <!-- 作者信息 -->
    <text class="group-title">作者</text>
    <view class="card">
      <view class="info-item">
        <text class="info-label">作者</text>
        <text class="info-value">罗耀生</text>
      </view>
      <view class="info-item">
        <text class="info-label">邮箱</text>
        <text class="info-value email">contact@i2kai.com</text>
      </view>
    </view>

    <!-- 技术栈 -->
    <text class="group-title">技术栈</text>
    <view class="card">
      <view class="tech-list">
        <text class="tech-chip">Flutter</text>
        <text class="tech-chip">UniApp</text>
        <text class="tech-chip">Go</text>
        <text class="tech-chip">MQTT</text>
        <text class="tech-chip">MySQL</text>
      </view>
    </view>

    <!-- 底部版权 -->
    <view class="footer">
      <text class="copyright">© 2026 Open IoT Platform</text>
      <text class="copyright">All rights reserved</text>
    </view>
  </view>
</template>

<script>
import AppIcon from '@/components/AppIcon.vue'

export default {
  components: { AppIcon },
  methods: {
    openLink(type) {
      const urls = {
        github: 'https://github.com/user/open-iot-platform',
        changelog: 'https://github.com/user/open-iot-platform/blob/main/CHANGELOG.md',
        license: 'https://github.com/user/open-iot-platform/blob/main/LICENSE'
      }
      // #ifdef APP-PLUS
      plus.runtime.openURL(urls[type])
      // #endif
      // #ifdef H5
      window.open(urls[type])
      // #endif
    }
  }
}
</script>

<style lang="scss">
@import '@/styles/tokens.scss';

.about {
  min-height: 100vh;
  background: $color-bg;
  padding: $spacing-lg;
  box-sizing: border-box;
}

.logo-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: $spacing-2xl 0;
}

.logo {
  width: 128rpx;
  height: 128rpx;
  background: linear-gradient(135deg, $color-primary 0%, #5856D6 100%);
  border-radius: $radius-lg;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: $spacing-lg;
}

.logo-icon {
  font-size: 64rpx;
}

.app-name {
  font-size: $font-xl;
  font-weight: 600;
  color: $color-text;
  margin-bottom: $spacing-sm;
}

.app-desc {
  font-size: $font-sm;
  color: $color-text-secondary;
}

.group-title {
  display: block;
  font-size: $font-xs;
  color: $color-text-secondary;
  margin: $spacing-lg 0 $spacing-sm $spacing-sm;
}

.card {
  background: $color-card;
  border-radius: $radius-lg;
  overflow: hidden;
  margin-bottom: $spacing-md;
}

.info-item, .link-item {
  display: flex;
  align-items: center;
  padding: $spacing-lg;
  border-bottom: 1rpx solid $color-border;
  &:last-child { border-bottom: none; }
}

.info-label, .link-label {
  flex: 1;
  font-size: $font-md;
  color: $color-text;
}

.info-value {
  font-size: $font-md;
  color: $color-text-secondary;
  &.email { color: $color-primary; }
}

.link-icon {
  font-size: 32rpx;
  margin-right: $spacing-md;
}

.link-value {
  font-size: $font-sm;
  color: $color-text-secondary;
  margin-right: $spacing-sm;
}

.link-arrow {
  font-size: 32rpx;
  color: $color-placeholder;
}

.tech-list {
  display: flex;
  flex-wrap: wrap;
  gap: $spacing-sm;
  padding: $spacing-lg;
}

.tech-chip {
  padding: $spacing-sm $spacing-md;
  background: $color-bg;
  border-radius: $radius-sm;
  font-size: $font-xs;
  color: $color-text-secondary;
}

.footer {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: $spacing-2xl 0;
}

.copyright {
  font-size: $font-xs;
  color: $color-placeholder;
  margin-bottom: $spacing-xs;
}
</style>
