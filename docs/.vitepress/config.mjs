import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'Open IoT Platform',
  description: '从设备接入、配网到控制管理的一体化 IoT 平台',
  lang: 'zh-CN',
  base: '/',
  cleanUrls: true,
  ignoreDeadLinks: [/^https?:\/\/localhost/],
  lastUpdated: true,

  // ═══ SEO 与社交元数据 ═══
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' }],
    ['meta', { name: 'author', content: 'LuoYaoSheng' }],
    ['meta', { name: 'keywords', content: 'IoT平台,设备配网,MQTT,BLE配网,智能家居,开源IoT,物联网,Open IoT Platform,Docker部署,ESP32' }],
    ['meta', { property: 'og:type',        content: 'website' }],
    ['meta', { property: 'og:site_name',   content: 'Open IoT Platform' }],
    ['meta', { property: 'og:title',       content: 'Open IoT Platform — 一体化 IoT 平台' }],
    ['meta', { property: 'og:description', content: '从设备接入、BLE 配网、MQTT 通信到服务端管理的完整 IoT 解决方案。' }],
    ['meta', { property: 'og:url',         content: 'https://iot.open.i2kai.com/' }],
    ['meta', { property: 'og:locale',      content: 'zh_CN' }],
    ['meta', { name: 'twitter:card',        content: 'summary_large_image' }],
    ['meta', { name: 'twitter:title',       content: 'Open IoT Platform — 一体化 IoT 平台' }],
    ['meta', { name: 'twitter:description', content: '从设备接入到控制管理的完整 IoT 解决方案。' }],
    ['meta', { name: 'theme-color', content: '#646cff' }],
  ],

  themeConfig: {
    search: {
      provider: 'local',
    },
    editLink: {
      pattern: 'https://github.com/LuoYaoSheng/lys-iot-platform/edit/master/docs/:path',
      text: '在 GitHub 上编辑此页',
    },
    lastUpdated: {
      text: '最后更新于',
    },
    nav: [
      { text: '首页', link: '/' },
      { text: '快速开始', link: '/START_HERE' },
      { text: '架构', link: '/REPOSITORY_ARCHITECTURE' },
      { text: 'API', link: '/API_REFERENCE' },
    ],
    sidebar: [
      {
        text: '入门',
        items: [
          { text: '快速开始', link: '/START_HERE' },
          { text: 'Docker 一键部署', link: '/QUICK_START_DOCKER' },
          { text: '仓库架构', link: '/REPOSITORY_ARCHITECTURE' },
          { text: '数据流架构', link: '/ARCHITECTURE_DATA_FLOW' },
        ],
      },
      {
        text: '设计文档',
        items: [
          { text: '产品需求 PRD', link: '/PRD' },
          { text: '服务端 PRD', link: '/PRD_SERVER' },
          { text: '移动端 PRD', link: '/PRD_MOBILE' },
          { text: '设备统一规范', link: '/DEVICE_UNIFIED_SPEC' },
          { text: '配置链路', link: '/CONFIGURATION_CHAIN' },
        ],
      },
      {
        text: '运维与发布',
        items: [
          { text: '本地模拟器 Runbook', link: '/LOCAL_EMULATOR_RUNBOOK' },
          { text: '发布指南', link: '/RELEASE_GUIDE' },
          { text: '发布记录', link: '/RELEASE_NOTES' },
          { text: 'v0.2.0 发布', link: '/release-v0.2.0' },
        ],
      },
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/LuoYaoSheng/lys-iot-platform' },
      { icon: 'github', link: 'https://gitee.com/luoyaosheng/lys-iot-platform', ariaLabel: 'Gitee' },
    ],
  },
});
