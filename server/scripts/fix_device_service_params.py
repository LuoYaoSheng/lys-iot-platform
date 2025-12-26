#!/usr/bin/env python3
# -*- coding: utf-8 -*-

def fix_device_service_params():
    file_path = "E:/project/xf/IOT/iot-platform-core/internal/service/device_service.go"

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 旧的函数签名
    old_signature = '''func NewDeviceService(
    deviceRepo *repository.DeviceRepository,
    productRepo *repository.ProductRepository,
    mqttBroker string,
	thingModelService *ThingModelService,
	db *gorm.DB,
    mqttBrokerExternal string,
    mqttPort int,
) *DeviceService {
    return &DeviceService{
        deviceRepo:         deviceRepo,
        productRepo:        productRepo,
        mqttBroker:         mqttBroker,
        mqttBrokerExternal: mqttBrokerExternal,
		thingModelService:  thingModelService,
		db:                 db,
        mqttPort:           mqttPort,
    }
}'''

    # 新的函数签名（正确顺序）
    new_signature = '''func NewDeviceService(
    deviceRepo *repository.DeviceRepository,
    productRepo *repository.ProductRepository,
    mqttBroker string,
    mqttBrokerExternal string,
    mqttPort int,
	thingModelService *ThingModelService,
	db *gorm.DB,
) *DeviceService {
    return &DeviceService{
        deviceRepo:         deviceRepo,
        productRepo:        productRepo,
        mqttBroker:         mqttBroker,
        mqttBrokerExternal: mqttBrokerExternal,
        mqttPort:           mqttPort,
		thingModelService:  thingModelService,
		db:                 db,
    }
}'''

    # 替换
    content = content.replace(old_signature, new_signature)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print("SUCCESS: NewDeviceService parameter order fixed")

if __name__ == '__main__':
    fix_device_service_params()
