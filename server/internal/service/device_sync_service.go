// 设备状态同步服务
// 作者: 罗耀生
// 日期: 2025-12-16
// 用于同步EMQX在线状态到数据库

package service

import (
	"iot-platform-core/internal/model"
	"iot-platform-core/internal/repository"
	"log"
	"strings"
	"time"

	"gorm.io/gorm"
)

// DeviceSyncService 设备同步服务
type DeviceSyncService struct {
	db          *gorm.DB
	deviceRepo  *repository.DeviceRepository
	emqxService *EMQXService
}

// NewDeviceSyncService 创建设备同步服务
func NewDeviceSyncService(
	db *gorm.DB,
	deviceRepo *repository.DeviceRepository,
	emqxService *EMQXService,
) *DeviceSyncService {
	return &DeviceSyncService{
		db:          db,
		deviceRepo:  deviceRepo,
		emqxService: emqxService,
	}
}

// SyncDeviceStatusOnStartup 启动时同步设备在线状态
func (s *DeviceSyncService) SyncDeviceStatusOnStartup() error {
	log.Println("[DeviceSync] 开始同步设备在线状态...")

	// 1. 获取EMQX所有在线客户端
	onlineClients, err := s.emqxService.GetOnlineClients()
	if err != nil {
		log.Printf("[DeviceSync] 获取在线客户端失败: %v", err)
		return err
	}

	// 2. 提取在线设备ID集合
	onlineDeviceMap := make(map[string]bool)
	platformClientCount := 0

	for _, client := range onlineClients {
		// 跳过平台内部客户端
		if client.ClientID == "iot-platform-core" {
			platformClientCount++
			continue
		}

		// 解析 username 获取设备信息 (格式: productKey&deviceId)
		parts := strings.Split(client.Username, "&")
		if len(parts) == 2 {
			deviceID := parts[1]
			onlineDeviceMap[deviceID] = true
		}
	}

	log.Printf("[DeviceSync] EMQX在线: 设备=%d, 平台客户端=%d", len(onlineDeviceMap), platformClientCount)

	// 3. 查询数据库所有激活设备
	var devices []model.Device
	if err := s.db.Where("status != ?", model.DeviceStatusInactive).Find(&devices).Error; err != nil {
		log.Printf("[DeviceSync] 查询设备失败: %v", err)
		return err
	}

	// 4. 同步设备状态
	onlineCount := 0
	offlineCount := 0
	now := time.Now()

	for _, device := range devices {
		// 跳过已禁用设备
		if device.Status == model.DeviceStatusDisabled {
			continue
		}

		isOnline := onlineDeviceMap[device.DeviceID]
		expectedStatus := model.DeviceStatusOffline
		if isOnline {
			expectedStatus = model.DeviceStatusOnline
		}

		// 如果状态不一致，更新数据库
		if device.Status != expectedStatus {
			updates := map[string]interface{}{
				"status": expectedStatus,
			}
			if isOnline {
				updates["last_online_at"] = &now
				onlineCount++
			} else {
				offlineCount++
			}

			if err := s.db.Model(&device).Updates(updates).Error; err != nil {
				log.Printf("[DeviceSync] 更新设备状态失败: deviceId=%s, err=%v", device.DeviceID, err)
				continue
			}

			statusText := "离线"
			if isOnline {
				statusText = "在线"
			}
			log.Printf("[DeviceSync] 设备状态更新: %s -> %s", device.DeviceID, statusText)
		}
	}

	log.Printf("[DeviceSync] 同步完成: 在线=%d, 离线=%d, 总计=%d", onlineCount, offlineCount, len(devices))
	return nil
}

// StartHeartbeatMonitor 启动心跳监控（定时检查设备状态）
// 定期同步EMQX在线状态，作为Webhook的补充
func (s *DeviceSyncService) StartHeartbeatMonitor(intervalMinutes int) {
	if intervalMinutes <= 0 {
		intervalMinutes = 5 // 默认5分钟
	}

	ticker := time.NewTicker(time.Duration(intervalMinutes) * time.Minute)
	log.Printf("[DeviceSync] 启动心跳监控，间隔: %d分钟", intervalMinutes)

	go func() {
		for range ticker.C {
			log.Println("[DeviceSync] 执行定时设备状态同步...")
			if err := s.SyncDeviceStatusOnStartup(); err != nil {
				log.Printf("[DeviceSync] 定时同步失败: %v", err)
			}
		}
	}()
}
