import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'Open IoT Platform',
  description: '从设备接入、配网到控制管理的一体化 IoT 平台',
  lang: 'zh-CN',
  cleanUrls: true,
  ignoreDeadLinks: true,
  head: [['link', { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' }]],
  themeConfig: {
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
          { text: '仓库架构', link: '/REPOSITORY_ARCHITECTURE' },
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
        ],
      },
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/LuoYaoSheng/lys-iot-platform' },
      { icon: 'github', link: 'https://gitee.com/luoyaosheng/lys-iot-platform', ariaLabel: 'Gitee' },
    ],
  },
});
