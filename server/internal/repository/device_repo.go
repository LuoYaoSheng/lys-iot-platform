// 设备仓库层
// 作者: 罗耀生
// 日期: 2025-12-13

package repository

import (
	"iot-platform-core/internal/model"

	"gorm.io/gorm"
)

type DeviceRepository struct {
	db *gorm.DB
}

func NewDeviceRepository(db *gorm.DB) *DeviceRepository {
	return &DeviceRepository{db: db}
}

// FindByDeviceSN 根据设备序列号查找
func (r *DeviceRepository) FindByDeviceSN(productKey, deviceSN string) (*model.Device, error) {
	var device model.Device
	err := r.db.Where("product_key = ? AND device_sn = ?", productKey, deviceSN).First(&device).Error
	if err != nil {
		return nil, err
	}
	return &device, nil
}

// FindByDeviceID 根据设备ID查找
func (r *DeviceRepository) FindByDeviceID(deviceID string) (*model.Device, error) {
	var device model.Device
	err := r.db.Where("device_id = ?", deviceID).First(&device).Error
	if err != nil {
		return nil, err
	}
	return &device, nil
}

// FindByMQTTUsername 根据MQTT用户名查找
func (r *DeviceRepository) FindByMQTTUsername(username string) (*model.Device, error) {
	var device model.Device
	err := r.db.Where("mqtt_username = ?", username).First(&device).Error
	if err != nil {
		return nil, err
	}
	return &device, nil
}

// FindByProductKeyAndDeviceID 根据产品Key和设备ID查找
func (r *DeviceRepository) FindByProductKeyAndDeviceID(productKey, deviceID string) (*model.Device, error) {
	var device model.Device
	err := r.db.Where("product_key = ? AND device_id = ?", productKey, deviceID).First(&device).Error
	if err != nil {
		return nil, err
	}
	return &device, nil
}

// Create 创建设备
func (r *DeviceRepository) Create(device *model.Device) error {
	return r.db.Create(device).Error
}

// Update 更新设备
func (r *DeviceRepository) Update(device *model.Device) error {
	return r.db.Save(device).Error
}

// UpdateStatus 更新设备状态
func (r *DeviceRepository) UpdateStatus(deviceID string, status model.DeviceStatus) error {
	return r.db.Model(&model.Device{}).
		Where("device_id = ?", deviceID).
		Update("status", status).Error
}

// UpdateLastOnline 更新最后在线时间
func (r *DeviceRepository) UpdateLastOnline(deviceID string) error {
	return r.db.Model(&model.Device{}).
		Where("device_id = ?", deviceID).
		Update("last_online_at", gorm.Expr("NOW()")).Error
}

// FindAll 获取设备列表
func (r *DeviceRepository) FindAll(productKey string, status *model.DeviceStatus, limit, offset int) ([]model.Device, int64, error) {
	var devices []model.Device
	var total int64

	query := r.db.Model(&model.Device{})

	if productKey != "" {
		query = query.Where("product_key = ?", productKey)
	}
	if status != nil {
		query = query.Where("status = ?", *status)
	}

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	if err := query.Order("created_at DESC").Limit(limit).Offset(offset).Find(&devices).Error; err != nil {
		return nil, 0, err
	}

	return devices, total, nil
}

// Delete 删除设备
func (r *DeviceRepository) Delete(id int64) error {
	return r.db.Delete(&model.Device{}, id).Error
}

// GetDeviceProperty 获取设备属性
func (r *DeviceRepository) GetDeviceProperty(deviceID, propertyID string) (*model.DeviceProperty, error) {
	var property model.DeviceProperty
	err := r.db.Where("device_id = ? AND property_id = ?", deviceID, propertyID).First(&property).Error
	if err != nil {
		return nil, err
	}
	return &property, nil
}

// UpdateDeviceProperty 更新设备属性
func (r *DeviceRepository) UpdateDeviceProperty(deviceID, propertyID, value string) error {
	property := &model.DeviceProperty{
		DeviceID:   deviceID,
		PropertyID: propertyID,
		Value:      value,
	}

	// 使用 GORM 的 Upsert 功能
	return r.db.Where("device_id = ? AND property_id = ?", deviceID, propertyID).
		Assign(map[string]interface{}{
			"value":       value,
			"reported_at": gorm.Expr("NOW()"),
		}).
		FirstOrCreate(property).Error
}


// ProductRepository 产品仓库
type ProductRepository struct {
	db *gorm.DB
}

func NewProductRepository(db *gorm.DB) *ProductRepository {
	return &ProductRepository{db: db}
}

// FindByProductKey 根据产品标识查找
func (r *ProductRepository) FindByProductKey(productKey string) (*model.Product, error) {
	var product model.Product
	err := r.db.Where("product_key = ?", productKey).First(&product).Error
	if err != nil {
		return nil, err
	}
	return &product, nil
}

// FindAll 获取产品列表
func (r *ProductRepository) FindAll(category string, status *int, limit, offset int) ([]model.Product, int64, error) {
	var products []model.Product
	var total int64

	query := r.db.Model(&model.Product{})

	if category != "" {
		query = query.Where("category = ?", category)
	}
	if status != nil {
		query = query.Where("status = ?", *status)
	}

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	if err := query.Order("created_at DESC").Limit(limit).Offset(offset).Find(&products).Error; err != nil {
		return nil, 0, err
	}

	return products, total, nil
}

// Create 创建产品
func (r *ProductRepository) Create(product *model.Product) error {
	return r.db.Create(product).Error
}

// Update 更新产品
func (r *ProductRepository) Update(product *model.Product) error {
	return r.db.Save(product).Error
}

// Delete 删除产品
func (r *ProductRepository) Delete(productKey string) error {
	return r.db.Where("product_key = ?", productKey).Delete(&model.Product{}).Error
}

// CountDevices 统计产品下的设备数量
func (r *ProductRepository) CountDevices(productKey string) (int64, error) {
	var count int64
	err := r.db.Model(&model.Device{}).Where("product_key = ?", productKey).Count(&count).Error
	return count, err
}

// MQTTAuthLogRepository MQTT认证日志仓库
type MQTTAuthLogRepository struct {
	db *gorm.DB
}

func NewMQTTAuthLogRepository(db *gorm.DB) *MQTTAuthLogRepository {
	return &MQTTAuthLogRepository{db: db}
}

// Create 创建日志
func (r *MQTTAuthLogRepository) Create(log *model.MQTTAuthLog) error {
	return r.db.Create(log).Error
}
