# 发布流程指南

**作者**: 罗耀生
**最后更新**: 2026-01-10

---

## 📋 发布检查清单

- [ ] 代码已提交并推送到 master 分支
- [ ] 版本号已更新
- [ ] 固件已构建
- [ ] APK 已构建
- [ ] 压缩包已打包
- [ ] Release Notes 已更新
- [ ] Git Tag 已创建
- [ ] GitHub Release 已发布
- [ ] Gitee Release 已发布

---

## 🔨 发布步骤

### 1. 构建固件

```bash
# ESP32 舵机开关
cd firmware/switch
pio run

# ESP32-S3 USB 唤醒
cd firmware/usb-wakeup
pio run
```

**输出文件位置**:
```
firmware/switch/.pio/build/esp32dev/firmware.bin
firmware/usb-wakeup/.pio/build/esp32-s3-devkitc-1/firmware.bin
```

### 2. 构建 APK

```bash
cd mobile-app
flutter build apk --release
```

**输出文件位置**:
```
mobile-app/build/app/outputs/flutter-apk/app-release.apk
```

> **注意**: 需要签名配置文件 `mobile-app/android/key.properties` 和 keystore 文件

### 3. 执行打包脚本

```bash
./release.sh v0.x.x
```

或使用 Python 脚本（推荐 Windows 环境）:

```bash
python release.py v0.x.x
```

**输出文件位置**:
```
smartlink-hub/releases/open-iot-platform-v0.x.x.zip
```

### 4. 创建 Git Tag

```bash
git tag -a v0.x.x -m "Release v0.x.x"
git push origin v0.x.x
git push gitee v0.x.x
```

### 5. 发布 GitHub Release

1. 访问: https://github.com/LuoYaoSheng/open-iot-platform/releases/new
2. 选择 tag: `v0.x.x`
3. 标题: `Open IoT Platform v0.x.x`
4. 复制 `docs/RELEASE_NOTES.md` 内容到描述
5. 上传 `open-iot-platform-v0.x.x.zip`
6. 点击 "Publish release"

### 6. 发布 Gitee Release

1. 访问: https://gitee.com/luoyaosheng/open-iot-platform/releases/new
2. 选择 tag: `v0.x.x`
3. 标题: `Open IoT Platform v0.x.x`
4. 复制 release notes
5. 上传 `open-iot-platform-v0.x.x.zip`
6. 点击 "发布"

---

## 📦 压缩包结构

```
open-iot-platform-v0.x.x.zip
├── firmware/
│   ├── esp32-servo-firmware.bin       # ESP32 舵机固件
│   ├── bootloader-esp32.bin            # ESP32 Bootloader
│   ├── partitions-esp32.bin            # ESP32 分区表
│   ├── esp32s3-wakeup-firmware.bin     # ESP32-S3 唤醒固件
│   ├── bootloader-esp32s3.bin          # ESP32-S3 Bootloader
│   └── partitions-esp32s3.bin          # ESP32-S3 分区表
├── server/
│   ├── docker-compose.yml              # Docker Compose 配置
│   └── scripts/
│       └── init.sql                    # 数据库初始化脚本
├── iot-config-app.apk                  # Android 配网 APP
└── README.txt                          # 快速开始说明
```

---

## 🔐 签名证书备份

签名证书已备份至 `backup/android-certificates.zip`，包含:

- `key.properties` - 签名配置
- `iot-app-release.jks` - Keystore 文件

⚠️ **此文件不得提交到 Git 仓库**

---

## 📝 更新 Release Notes

发布前编辑 `docs/RELEASE_NOTES.md`:

1. 更新版本号和发布日期
2. 在 `v0.x.x 更新内容` 部分添加:
   - 新增功能
   - 优化改进
   - 问题修复
3. 更新版本历史

---

## 🚨 常见问题

### Q: APK 打包失败
**A**: 检查 `mobile-app/android/key.properties` 是否存在

### Q: 固件路径错误
**A**: 检查 `release.py` 中的固件路径是否与 PlatformIO 输出一致

### Q: init.sql 位置错误
**A**: 确保放在 `server/scripts/` 目录，与 docker-compose.yml 中的 volume 路径一致

---

## 📌 版本号规则

- 格式: `v主版本.次版本.修订号`
- 示例: `v0.3.0`
- 主版本: 架构重大变更
- 次版本: 新功能
- 修订号: Bug 修复

---

## 🔗 相关链接

- GitHub Releases: https://github.com/LuoYaoSheng/open-iot-platform/releases
- Gitee Releases: https://gitee.com/luoyaosheng/open-iot-platform/releases

---

## 📝 版本历史

| 日期 | 版本 | 说明 |
|------|------|------|
| 2026-01-10 | v0.3.0 | 内置 MQTT Broker，动态控制面板 |
| 2026-01-07 | v0.2.0 | 新增 USB 唤醒设备 |
| 2025-12-20 | v0.1.0 | 初始版本 |
