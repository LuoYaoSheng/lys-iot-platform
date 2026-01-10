# 🚀 IoT SmartLink Hub

**让你的 ESP32 和舵机秒变智能设备**

[![License](https://img.shields.io/badge/License-Free_to_Use-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-v0.2.0-blue.svg)](https://github.com/LuoYaoSheng/open-iot-platform/releases/v0.2.0)
[![Platform](https://img.shields.io/badge/Platform-ESP32-red.svg)](https://www.espressif.com/en/products/socs/esp32)

**📍 仓库地址**:
- [Gitee](https://gitee.com/luoyaosheng/open-iot-platform) - 国内访问推荐
- [GitHub](https://github.com/LuoYaoSheng/open-iot-platform) - 国际访问

---

## 📖 简介

**IoT SmartLink Hub** 是一个面向创客的智能硬件控制平台,让你用最低的成本和最简单的方式,让 ESP32 和舵机实现手机远程控制。

### ✨ 核心特点

- 🎯 **零技术门槛** - 无需编程,无需焊接
- 💰 **超低成本** - 30-60元硬件成本
- ⚡ **快速上手** - 5分钟即可完成配置
- 📱 **手机控制** - Android APP 远程操作
- ☁️ **云端管理** - 支持公共服务器或自己部署

---

## 🌐 在线体验

### 落地页

访问我们的产品落地页,了解详细使用教程:

**本地预览**: 打开 `landing-page/index.html`
**线上地址**: https://luoyaosheng.gitee.io/iot-smartlink-hub/landing-page/

---

## 📦 快速下载

### v0.2.0 (2026-01-10) ✨ 最新

**下载地址**:
- **Gitee Release**: https://gitee.com/luoyaosheng/open-iot-platform/releases/v0.2.0
- **GitHub Release**: https://github.com/LuoYaoSheng/open-iot-platform/releases/v0.2.0

| 文件 | 大小 | 说明 |
|------|------|------|
| **Android APP** | 97 MB | 用于配网和控制设备 |
| **ESP32 舵机固件** | 1.64 MB | ESP32 舵机开关固件 |
| **ESP32-S3 唤醒固件** | 1.46 MB | ESP32-S3 USB 唤醒固件 |
| **Bootloader** | 15-17 KB | ESP32/ESP32-S3 引导程序 |
| **Partitions** | 3 KB | 分区表 |

**更新内容**:
- 🆕 支持 ESP32-S3 USB 唤醒设备
- 🎨 APP 新增 USB 唤醒专用控制面板
- 🐛 修复舵机启动大幅度旋转问题
- 🐛 修复设备列表加载错误

### 历史版本

**v0.1.0** (2025-12-19) - [Gitee](https://gitee.com/luoyaosheng/open-iot-platform/releases/v0.1.0) / [GitHub](https://github.com/LuoYaoSheng/open-iot-platform/releases/v0.1.0)

**更多版本**: [Gitee Releases](https://gitee.com/luoyaosheng/open-iot-platform/releases) / [GitHub Releases](https://github.com/LuoYaoSheng/open-iot-platform/releases)

---

## 🛠️ 快速开始

### 1. 准备材料 (30-60元)

- ESP32-WROOM-32E 开发板 (15-30元)
- SG90 舵机 (5-15元)
- 杜邦线 3-5根 (5元)
- Android 手机 (安装 APP)

### 2. 硬件连接

用 3 根杜邦线连接 ESP32 和舵机:
- 红线 → 5V 供电
- 棕线 → GND 接地
- 橙线 → GPIO 引脚

**不用焊接,插上就行!**

### 3. 烧写固件

下载固件文件,用 USB 线连接电脑,用烧录工具烧写到 ESP32。
详细步骤请查看[视频教程](landing-page/index.html#tutorials)

### 4. 手机配网

1. 安装 APP
2. 打开 APP 点击"添加设备"
3. 输入 WiFi 密码
4. 等待配网成功

### 5. 开始控制

配网成功后,你就可以在 APP 里控制舵机了!
无论在家还是在外,手机一点,设备就动。

---

## 📂 目录结构

```
smartlink-hub/
├── landing-page/           # 产品落地页
│   ├── index.html         # 主页面
│   ├── README.md          # 落地页文档
│   ├── CHANGELOG.md       # 更新日志
│   ├── deploy.sh          # 部署脚本
│   └── preview.bat        # 本地预览工具
│
├── releases/              # 版本说明文档
│   ├── v0.2.0/           # v0.2.0 版本说明
│   └── v0.1.0/           # v0.1.0 版本说明
│
├── README.md              # 本文档
└── LICENSE                # 许可协议
```

**固件和APK下载**: 请访问 [Git Releases](https://github.com/LuoYaoSheng/open-iot-platform/releases)

---

## ☁️ 云端服务

### 选项 1: 使用公共服务器 (推荐新手)

我们提供了免费的公共服务器,APP 中已默认配置,直接使用即可。

### 选项 2: 自己部署服务器 (进阶玩家)

如果你有自己的服务器(VPS/NAS/树莓派),可以自行部署。

**服务端代码为独立项目,需要联系作者获取:**

👉 [提交 Issue 说明部署需求](https://gitee.com/luoyaosheng/open-iot-platform/issues)

详细教程请查看[落地页-部署服务](landing-page/index.html#server)

---

## 📺 视频教程

我们在 B站 提供了完整的视频教程:

- 🎬 [硬件连接教程](https://space.bilibili.com/your-channel)
- 🔥 [固件烧录教程](https://space.bilibili.com/your-channel)
- 📱 [APP 使用教程](https://space.bilibili.com/your-channel)

---

## 🤝 技术支持

### 常见问题

**Q: 配网失败怎么办?**
A: 检查 WiFi 密码是否正确,确保 ESP32 已通电

**Q: 设备离线怎么办?**
A: 确认 ESP32 已连接 WiFi,检查服务器是否正常

**Q: APP 连不上服务器?**
A: 如果使用自建服务器,确认防火墙端口已开放

### 反馈问题

遇到问题或有建议?欢迎提交反馈:
- [Gitee Issues](https://gitee.com/luoyaosheng/open-iot-platform/issues)
- [GitHub Issues](https://github.com/LuoYaoSheng/open-iot-platform/issues)

---

## 🎯 适用场景

- 🏠 智能家居改造(控制灯光、窗帘等)
- 🎓 物联网学习和实验
- 🎨 创客作品展示
- 🔧 DIY 电子项目

---

## 📜 许可协议

本项目允许免费使用。

---

## 👨‍💻 关于作者

**作者**: 罗耀生
**更新时间**: 2026-01-10
**版本**: v0.2.0

---

## 🌟 Star History

如果这个项目对你有帮助,欢迎 Star ⭐

---

**🎉 开始你的智能硬件之旅吧!**
