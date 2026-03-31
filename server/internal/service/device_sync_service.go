package service

import (
	"time"

	"iot-platform-core/internal/repository"

	"gorm.io/gorm"
)

// DeviceSyncService is a minimal placeholder used to keep the current server
// entrypoint buildable while the device status sync flow is being consolidated.
type DeviceSyncService struct {
	db         *gorm.DB
	deviceRepo *repository.DeviceRepository
	emqx       *EMQXService
}

func NewDeviceSyncService(db *gorm.DB, deviceRepo *repository.DeviceRepository, emqx *EMQXService) *DeviceSyncService {
	return &DeviceSyncService{
		db:         db,
		deviceRepo: deviceRepo,
		emqx:       emqx,
	}
}

func (s *DeviceSyncService) SyncDeviceStatusOnStartup() error {
	return nil
}

func (s *DeviceSyncService) StartHeartbeatMonitor(intervalMinutes int) {
	_ = intervalMinutes
}

func (s *DeviceSyncService) Stop() {
	_ = time.Second
}
