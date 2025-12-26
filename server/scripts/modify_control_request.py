#!/usr/bin/env python3
# -*- coding: utf-8 -*-

def modify_control_request():
    file_path = "E:/project/xf/IOT/iot-platform-core/internal/service/device_service.go"

    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    new_lines = []
    in_control_request = False
    control_request_modified = False

    for i, line in enumerate(lines):
        if '// ControlRequest ' in line and 'struct' not in line and not control_request_modified:
            in_control_request = True
            new_lines.append(line)
            continue

        if in_control_request:
            if 'type ControlRequest struct {' in line:
                new_lines.append(line)
                new_lines.append('\t// v0.3.0 Thing Model service invocation protocol\n')
                new_lines.append('\tService *string                `json:"service,omitempty"` // Service identifier\n')
                new_lines.append('\tParams  map[string]interface{} `json:"params,omitempty"`  // Service parameters\n')
                new_lines.append('\n')
                control_request_modified = True
                continue

            if line.strip() == '}':
                new_lines.append(line)
                in_control_request = False
                continue

            if '// ' in line and 'Action' not in line and 'Switch' not in line:
                if 'action' in line.lower():
                    new_lines.append('\t// v0.2.0 Compatible protocol: action parameter\n')
                elif '' in line:
                    new_lines.append('\t// v0.1.0 Compatible old protocol\n')
                else:
                    new_lines.append(line)
                continue

            new_lines.append(line)
        else:
            new_lines.append(line)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

    print("SUCCESS: ControlRequest structure modified")

if __name__ == '__main__':
    modify_control_request()
