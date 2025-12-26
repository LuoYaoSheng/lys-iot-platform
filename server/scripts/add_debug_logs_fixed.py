#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 临时添加调试日志到 ControlDevice 方法 - 修复版

def add_debug_logs():
    file_path = "E:/project/xf/IOT/iot-platform-core/internal/service/device_service.go"

    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # 在 line 453 后添加调试日志（进入物模型服务调用分支时）
    insert_positions = []

    for i, line in enumerate(lines):
        # 在 "if req.Service != nil && *req.Service != \"\"" 后添加日志
        if 'if req.Service != nil && *req.Service != ""' in line:
            insert_positions.append((i+1, '\t\tfmt.Printf("[DEBUG] Entering thing model service branch, Service=%v, Params=%v' + chr(92) + 'n", req.Service, req.Params)' + chr(10)))

        # 在 "params = req.Params" 前添加日志
        if 'params = req.Params' in line and '_:=' not in line:
            insert_positions.append((i, '\t\tfmt.Printf("[DEBUG] Before params assignment, req.Params=%v, len=%d' + chr(92) + 'n", req.Params, len(req.Params))' + chr(10)))

        # 在 "if len(params) == 0" 前添加日志
        if 'if len(params) == 0' in line:
            insert_positions.append((i, '\tfmt.Printf("[DEBUG] Final params check, params=%v, len=%d' + chr(92) + 'n", params, len(params))' + chr(10)))

    # 从后往前插入，避免行号变化
    for pos, debug_line in reversed(insert_positions):
        lines.insert(pos, debug_line)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)

    print(f"SUCCESS: Added {len(insert_positions)} debug log statements")

if __name__ == '__main__':
    add_debug_logs()
