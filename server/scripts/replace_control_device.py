#!/usr/bin/env python3
# -*- coding: utf-8 -*-

def replace_control_device():
    src_file = "E:/project/xf/IOT/iot-platform-core/internal/service/device_service.go"
    new_impl_file = "E:/project/xf/IOT/iot-platform-core/scripts/new_control_device.go.txt"

    # Read new implementation
    with open(new_impl_file, 'r', encoding='utf-8') as f:
        new_impl = f.read()

    # Read source file
    with open(src_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # Find ControlDevice method
    start_idx = -1
    end_idx = -1
    for i, line in enumerate(lines):
        if '// ControlDevice ' in line and 'MQTT' in line:
            start_idx = i
        if start_idx != -1 and end_idx == -1:
            if line.strip() == '}' and i > start_idx + 5:
                # Check if this is the end of ControlDevice
                # Look ahead to see if next function starts
                if i + 1 < len(lines):
                    next_line = lines[i+1].strip()
                    if next_line == '' or next_line.startswith('//') or next_line.startswith('func'):
                        end_idx = i
                        break

    if start_idx == -1 or end_idx == -1:
        print("ERROR: Could not find ControlDevice method boundaries")
        return

    # Replace
    new_lines = lines[:start_idx] + [new_impl + '\n'] + lines[end_idx+1:]

    # Write back
    with open(src_file, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

    print("SUCCESS: ControlDevice method replaced with Thing Model support")
    print(f"Replaced lines {start_idx+1} to {end_idx+1}")

if __name__ == '__main__':
    replace_control_device()
