#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 逐步应用物模型服务调用支持的修改
# 作者: 罗耀生

def main():
    # 1. 读取目标文件
    target_file = "E:/project/xf/IOT/iot-platform-core/internal/service/device_service.go"
    with open(target_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # 2. 添加 encoding/json 导入 (在 line 9)
    for i, line in enumerate(lines):
        if line.strip() == '"encoding/hex"':
            lines.insert(i+1, '\t"encoding/json"\n')
            print("Step 1: Added encoding/json import")
            break

    # 3. 更新 DeviceService 结构体 (在 mqttBroker 之前添加两个字段)
    for i, line in enumerate(lines):
        if 'mqttBroker         string // 内部地址' in line:
            lines.insert(i, '    thingModelService  *ThingModelService\n')
            lines.insert(i+1, '    db                 *gorm.DB\n')
            print("Step 2: Updated DeviceService struct")
            break

    # 4. 更新 NewDeviceService 构造函数
    # 查找构造函数
    for i, line in enumerate(lines):
        if 'func NewDeviceService(' in line:
            # 找到参数列表结束
            j = i
            while j < len(lines) and ') *DeviceService {' not in lines[j]:
                j += 1
            # 在 mqttBroker 参数之前插入新参数
            for k in range(i, j+1):
                if 'mqttBroker string' in lines[k]:
                    lines.insert(k, '    thingModelService *ThingModelService,\n')
                    lines.insert(k+1, '    db *gorm.DB,\n')
                    print("Step 3a: Added parameters to NewDeviceService")
                    break
            # 更新构造函数体
            for k in range(j, min(j+15, len(lines))):
                if 'mqttBroker:         mqttBroker' in lines[k]:
                    lines.insert(k, '        thingModelService:  thingModelService,\n')
                    lines.insert(k+1, '        db:                 db,\n')
                    print("Step 3b: Updated NewDeviceService body")
                    break
            break

    # 5. 更新 ControlRequest 结构体 (在 Action 之前添加字段)
    for i, line in enumerate(lines):
        if 'type ControlRequest struct {' in line:
            # 找到 Action 字段
            for j in range(i, min(i+20, len(lines))):
                if 'Action   *string' in lines[j] and 'json:"action"' in lines[j]:
                    # 在 Action 之前插入新字段和注释
                    lines.insert(j, '\t// v0.3.0: 物模型服务调用\n')
                    lines.insert(j+1, '\tService *string                `json:"service"` // 服务标识符\n')
                    lines.insert(j+2, '\tParams  map[string]interface{} `json:"params"`  // 服务参数\n')
                    lines.insert(j+3, '\n')
                    # 更新原有注释
                    if j+4 < len(lines) and '// 新协议' in lines[j+4]:
                        lines[j+4] = '\t// v0.2.0: action 参数\n'
                    print("Step 4: Updated ControlRequest struct")
                    break
            break

    # 6. 读取新的 ControlDevice 实现
    new_method_file = "E:/project/xf/IOT/iot-platform-core/scripts/new_control_device.go.txt"
    with open(new_method_file, 'r', encoding='utf-8') as f:
        new_method_lines = f.readlines()

    # 7. 替换 ControlDevice 方法 (417-477 行，实际索引 416-476)
    # 找到方法开始
    start_idx = None
    for i, line in enumerate(lines):
        if '// ControlDevice 控制设备（通过 MQTT 发布指令）' in line and i >= 400:
            start_idx = i
            break

    if start_idx:
        # 找到方法结束（下一个方法的注释）
        end_idx = None
        for i in range(start_idx + 1, len(lines)):
            if lines[i].startswith('// Get') or lines[i].startswith('// Update') or lines[i].startswith('// Delete'):
                end_idx = i
                break

        if end_idx:
            # 替换整个方法
            lines[start_idx:end_idx] = new_method_lines
            print(f"Step 5: Replaced ControlDevice method (lines {start_idx+1}-{end_idx})")

    # 8. 写回文件
    with open(target_file, 'w', encoding='utf-8') as f:
        f.writelines(lines)

    print("\n=== All steps completed successfully! ===")
    print(f"File updated: {target_file}")

if __name__ == '__main__':
    main()
