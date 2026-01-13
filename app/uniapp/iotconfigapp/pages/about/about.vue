<!-- 关于页 -->
<!-- 作者: 罗耀生 -->
<!-- 日期: 2026-01-13 -->

<template>
  <view class="about-container">
    <view class="header">
      <view class="back-btn" @click="goBack">
        <text class="back-icon">‹</text>
      </view>
      <text class="title">关于</text>
    </view>

    <view class="content">
      <view class="app-logo">
        <text class="logo-icon">⚡</text>
      </view>
      <text class="app-name">Open IoT Platform</text>
      <text class="app-version">版本 1.0.0</text>

      <view class="link-section">
        <text class="section-title">相关链接</text>
        <view class="link-card">
          <view class="link-item" v-for="link in links" :key="link.label" @click="handleLinkClick(link)">
            <view class="link-left">
              <text class="link-icon">{{ link.icon }}</text>
              <text class="link-label">{{ link.label }}</text>
            </view>
            <text class="arrow-icon">›</text>
          </view>
        </view>
      </view>

      <view class="info-section">
        <view class="info-item" @click="copyText('落落在厦', '公众号')">
          <view class="info-left">
            <text class="info-icon">💬</text>
            <view class="info-text">
              <text class="info-label">公众号</text>
              <text class="info-value">落落在厦</text>
            </view>
          </view>
          <text class="copy-icon">📋</text>
        </view>
      </view>

      <text class="copyright">© 2026 罗耀生</text>
    </view>
  </view>
</template>

<script>
export default {
  name: 'About',
  data() {
    return {
      links: [
        {
          label: '项目落地页',
          url: 'https://open.iot.i2kai.com',
          icon: '🌐'
        },
        {
          label: '个人主页',
          url: 'https://i2kai.com',
          icon: '👤'
        },
        {
          label: 'Gitee 仓库',
          url: 'https://gitee.com/luo-yao-sheng/open-iot-platform',
          icon: '📦'
        },
        {
          label: 'GitHub 仓库',
          url: 'https://github.com/luoyaosheng/open-iot-platform',
          icon: '📦'
        }
      ]
    };
  },
  methods: {
    goBack() {
      uni.navigateBack();
    },

    // 判断是否为小程序环境
    isMiniProgram() {
      // #ifdef MP-WEIXIN
      return true;
      // #endif
      // #ifdef MP-ALIPAY
      return true;
      // #endif
      // #ifdef MP-BAIDU
      return true;
      // #endif
      // #ifdef MP-TOUTIAO
      return true;
      // #endif
      // #ifdef MP-QQ
      return true;
      // #endif
      // #ifdef H5
      return false;
      // #endif
      // #ifdef APP-PLUS
      return false;
      // #endif
      return false;
    },

    handleLinkClick(link) {
      // 小程序环境使用复制，其他环境直接打开链接
      if (this.isMiniProgram()) {
        this.copyText(link.url, link.label);
      } else {
        // App 或 H5 环境直接打开链接
        plus.runtime.openURL(link.url);
      }
    },

    copyText(text, label) {
      uni.setClipboardData({
        data: text,
        success: () => {
          uni.showToast({
            title: `已复制${label}`,
            icon: 'success'
          });
        }
      });
    }
  }
};
</script>

<style scoped>
.about-container {
  min-height: 100vh;
  background: #FFFFFF;
}

.header {
  display: flex;
  align-items: center;
  padding: 32rpx;
  position: relative;
}

.back-btn {
  width: 64rpx;
  height: 64rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}

.back-icon {
  font-size: 64rpx;
  color: #3A3A3C;
  font-weight: 300;
}

.title {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  font-size: 36rpx;
  font-weight: bold;
  color: #3A3A3C;
}

.content {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 80rpx 32rpx 32rpx;
}

.app-logo {
  width: 128rpx;
  height: 128rpx;
  background: #007AFF;
  border-radius: 32rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 32rpx;
}

.logo-icon {
  font-size: 72rpx;
  color: #FFFFFF;
}

.app-name {
  font-size: 36rpx;
  font-weight: bold;
  color: #3A3A3C;
  margin-bottom: 16rpx;
}

.app-version {
  font-size: 28rpx;
  color: #8E8E93;
  margin-bottom: 64rpx;
}

.link-section {
  width: 100%;
  margin-bottom: 32rpx;
}

.section-title {
  font-size: 28rpx;
  color: #8E8E93;
  margin-bottom: 16rpx;
  padding-left: 8rpx;
}

.link-card {
  background: #F5F5F7;
  border-radius: 24rpx;
  overflow: hidden;
}

.link-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx 32rpx;
  border-bottom: 1rpx solid #E5E5EA;
}

.link-item:last-child {
  border-bottom: none;
}

.link-left {
  display: flex;
  align-items: center;
  flex: 1;
}

.link-icon {
  font-size: 32rpx;
  margin-right: 16rpx;
}

.link-label {
  font-size: 32rpx;
  color: #3A3A3C;
}

.arrow-icon {
  font-size: 40rpx;
  color: #C7C7CC;
}

.info-section {
  width: 100%;
  background: #F5F5F7;
  border-radius: 24rpx;
  overflow: hidden;
  margin-bottom: 64rpx;
}

.info-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx 32rpx;
}

.info-left {
  display: flex;
  align-items: center;
  flex: 1;
}

.info-icon {
  font-size: 32rpx;
  margin-right: 16rpx;
}

.info-text {
  display: flex;
  flex-direction: column;
}

.info-label {
  font-size: 24rpx;
  color: #8E8E93;
  margin-bottom: 4rpx;
}

.info-value {
  font-size: 32rpx;
  color: #3A3A3C;
}

.copyright {
  font-size: 24rpx;
  color: #C7C7CC;
}
</style>
