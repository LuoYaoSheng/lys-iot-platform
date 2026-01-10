-- ========================================
-- IoT Platform Core - Database Schema
-- 作者: 罗耀生
-- 日期: 2025-12-13
-- 更新: 2026-01-10 - 补充 device_properties 和 device_events 表
-- ========================================

-- 使用数据库
USE iot_platform;

-- ==================== 产品表 ====================
CREATE TABLE IF NOT EXISTS products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_key VARCHAR(64) NOT NULL UNIQUE COMMENT '产品标识',
    name VARCHAR(128) NOT NULL COMMENT '产品名称',
    description TEXT COMMENT '产品描述',
    category VARCHAR(64) COMMENT '产品类别',

    -- v0.2.0 UI控制相关字段
    control_mode VARCHAR(32) COMMENT 'toggle/pulse/dimmer/readonly/generic',
    ui_template VARCHAR(64) COMMENT 'UI模板名称',
    icon_name VARCHAR(64) COMMENT '图标名称(Material Icons)',
    icon_color VARCHAR(16) COMMENT '图标颜色(HEX)',
    capabilities TEXT COMMENT '产品能力定义(JSON)',
    mqtt_topics TEXT COMMENT 'MQTT主题配置(JSON)',
    manufacturer VARCHAR(128) COMMENT '制造商',
    model VARCHAR(64) COMMENT '硬件型号',

    status TINYINT DEFAULT 1 COMMENT '状态: 0=禁用, 1=启用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product_key (product_key),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='产品表';

-- ==================== 设备表 ====================
CREATE TABLE IF NOT EXISTS devices (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id VARCHAR(64) NOT NULL UNIQUE COMMENT '设备ID',
    device_sn VARCHAR(64) NOT NULL COMMENT '设备序列号(MAC)',
    device_secret VARCHAR(128) COMMENT '设备密钥',
    product_key VARCHAR(64) NOT NULL COMMENT '产品标识',
    project_id VARCHAR(64) COMMENT '所属项目',
    name VARCHAR(128) COMMENT '设备名称',
    status TINYINT DEFAULT 0 COMMENT '状态: 0=未激活, 1=在线, 2=离线, 3=禁用',
    firmware_version VARCHAR(32) COMMENT '固件版本',
    chip_model VARCHAR(32) COMMENT '芯片型号',
    mqtt_username VARCHAR(128) COMMENT 'MQTT用户名',
    mqtt_password VARCHAR(256) COMMENT 'MQTT密码',
    mqtt_client_id VARCHAR(128) COMMENT 'MQTT客户端ID',
    last_online_at TIMESTAMP NULL COMMENT '最后在线时间',
    activated_at TIMESTAMP NULL COMMENT '激活时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_device_id (device_id),
    INDEX idx_device_sn (device_sn),
    INDEX idx_product_key (product_key),
    INDEX idx_status (status),
    UNIQUE INDEX idx_product_device (product_key, device_sn),
    FOREIGN KEY (product_key) REFERENCES products(product_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备表';

-- ==================== 设备属性表 ====================
CREATE TABLE IF NOT EXISTS device_properties (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id VARCHAR(64) NOT NULL COMMENT '设备ID',
    property_id VARCHAR(64) NOT NULL COMMENT '属性标识符',
    value TEXT COMMENT '属性值(JSON)',
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '上报时间',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX idx_device_property (device_id, property_id),
    INDEX idx_reported_at (reported_at),
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备属性表';

-- ==================== 设备事件表 ====================
CREATE TABLE IF NOT EXISTS device_events (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id VARCHAR(64) NOT NULL COMMENT '设备ID',
    event_type VARCHAR(64) COMMENT '事件类型: online/offline/alert/property_report',
    payload TEXT COMMENT '事件数据(JSON)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_device_id (device_id),
    INDEX idx_event_type (event_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备事件表';

-- ==================== MQTT 认证日志表 ====================
CREATE TABLE IF NOT EXISTS mqtt_auth_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    client_id VARCHAR(128) NOT NULL,
    username VARCHAR(128),
    ip_address VARCHAR(64),
    action VARCHAR(32) COMMENT 'connect/publish/subscribe',
    topic VARCHAR(256),
    result VARCHAR(32) COMMENT 'allow/deny',
    reason VARCHAR(256),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_client_id (client_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='MQTT认证日志';

-- ==================== 初始化数据 ====================
INSERT INTO products (
    product_key,
    name,
    description,
    category,
    control_mode,
    ui_template,
    icon_name,
    icon_color
) VALUES
(
    'SW-SERVO-001',
    '智能舵机开关',
    'ESP32智能舵机开关，支持BLE配网和MQTT控制',
    'switch',
    'toggle',
    'servo_switch',
    'settings_remote',
    '#FF6B35'
) ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    description = VALUES(description),
    control_mode = VALUES(control_mode),
    ui_template = VALUES(ui_template),
    icon_name = VALUES(icon_name),
    icon_color = VALUES(icon_color);

-- 打印初始化完成信息
SELECT 'Database initialized successfully!' AS message;
