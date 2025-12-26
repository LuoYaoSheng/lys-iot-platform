# 🚀 IoT SmartLink Hub

**让你的 ESP32 和舵机秒变智能设备**

[![License](https://img.shields.io/badge/License-Free_to_Use-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-v0.1.0-blue.svg)](releases/v0.1.0)
[![Platform](https://img.shields.io/badge/Platform-ESP32-red.svg)](https://www.espressif.com/en/products/socs/esp32)

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

### v0.1.0 (2025-12-19)

| 文件 | 大小 | 说明 | 下载 |
|------|------|------|------|
| **Android APP** | 51.4 MB | 用于配网和控制设备 | [下载 APK](releases/v0.1.0/iot-config-app-v0.1.0.apk) |
| **ESP32 固件** | 1.7 MB | 烧写到 ESP32 开发板 | [下载 BIN](releases/v0.1.0/esp32-firmware-v0.1.0.bin) |
| **Bootloader** | 18 KB | ESP32 引导程序 | [下载](releases/v0.1.0/bootloader.bin) |
| **Partitions** | 3 KB | ESP32 分区表 | [下载](releases/v0.1.0/partitions.bin) |

**历史版本**: [查看所有版本](releases/)

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
iot-smartlink-hub/
├── landing-page/           # 产品落地页
│   ├── index.html         # 主页面
│   ├── README.md          # 落地页文档
│   ├── CHANGELOG.md       # 更新日志
│   ├── deploy.sh          # 部署脚本
│   └── preview.bat        # 本地预览工具
│
├── releases/              # 下载资源
│   └── v0.1.0/           # v0.1.0 版本
│       ├── iot-config-app-v0.1.0.apk    # Android APP
│       ├── esp32-firmware-v0.1.0.bin    # ESP32 固件
│       ├── bootloader.bin               # 引导程序
│       ├── partitions.bin               # 分区表
│       └── README.md                    # 版本说明
│
├── README.md              # 本文档
└── LICENSE                # 许可协议
```

---

## ☁️ 云端服务

### 选项 1: 使用公共服务器 (推荐新手)

我们提供了免费的公共服务器,APP 中已默认配置,直接使用即可。

### 选项 2: 自己部署服务器 (进阶玩家)

如果你有自己的服务器(VPS/NAS/树莓派),可以自行部署。

**服务端代码为独立项目,需要联系作者获取:**

👉 [提交 Issue 说明部署需求](https://gitee.com/luoyaosheng/iot-smartlink-hub/issues)

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
https://gitee.com/luoyaosheng/iot-smartlink-hub/issues

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
**更新时间**: 2025-12-19
**版本**: v0.1.0

---

## 🌟 Star History

如果这个项目对你有帮助,欢迎 Star ⭐

---

**🎉 开始你的智能硬件之旅吧!**
