package service

import (
	"strings"
	"testing"
	"time"

	"iot-platform-core/internal/model"
	"iot-platform-core/internal/repository"
)

func TestActivateValidateAuthAndGetStatus(t *testing.T) {
	db := newTestDB(t)
	seedProduct(t, db, "switch_v1", 1)
	svc := newDeviceServiceForTest(db)

	activationResp, alreadyActivated, err := svc.Activate(&ActivationRequest{
		ProductKey:      "switch_v1",
		DeviceSN:        "SN001",
		FirmwareVersion: "1.0.0",
		ChipModel:       "ESP32",
	})
	if err != nil {
		t.Fatalf("Activate returned error: %v", err)
	}
	if alreadyActivated {
		t.Fatal("expected first activation to create device")
	}
	if activationResp.MQTT.Server != "mqtt.example.com" {
		t.Fatalf("expected external mqtt broker, got %q", activationResp.MQTT.Server)
	}

	deviceRepo := repository.NewDeviceRepository(db)
	device, err := deviceRepo.FindByDeviceID(activationResp.DeviceID)
	if err != nil {
		t.Fatalf("FindByDeviceID returned error: %v", err)
	}
	if device.Status != model.DeviceStatusOffline {
		t.Fatalf("expected offline status after activation, got %v", device.Status)
	}

	if _, alreadyActivated, err := svc.Activate(&ActivationRequest{
		ProductKey:      "switch_v1",
		DeviceSN:        "SN001",
		FirmwareVersion: "1.0.1",
		ChipModel:       "ESP32",
	}); err != nil || !alreadyActivated {
		t.Fatalf("expected second activation to return already activated, got already=%v err=%v", alreadyActivated, err)
	}

	if _, err := svc.ValidateMQTTAuth(device.MQTTUsername, device.MQTTPassword, device.MQTTClientID); err != nil {
		t.Fatalf("ValidateMQTTAuth returned error: %v", err)
	}
	if _, err := svc.ValidateMQTTAuth(device.MQTTUsername, "bad-password", device.MQTTClientID); err == nil || err.Error() != "invalid_password" {
		t.Fatalf("expected invalid_password, got %v", err)
	}

	if err := svc.UpdateDeviceOnline(device.DeviceID, true); err != nil {
		t.Fatalf("UpdateDeviceOnline returned error: %v", err)
	}
	if err := svc.UpdateDeviceProperty(device.DeviceID, "position", "up"); err != nil {
		t.Fatalf("UpdateDeviceProperty returned error: %v", err)
	}

	status, err := svc.GetDeviceStatus(device.DeviceID)
	if err != nil {
		t.Fatalf("GetDeviceStatus returned error: %v", err)
	}
	if status["status"] != "online" || status["position"] != "up" {
		t.Fatalf("unexpected device status payload: %+v", status)
	}
}

func TestBuildActivationResponseUsesExternalBroker(t *testing.T) {
	t.Parallel()

	svc := &DeviceService{
		mqttBroker:         "mqtt.internal",
		mqttBrokerExternal: "mqtt.example.com",
		mqttPort:           1883,
	}
	device := &model.Device{
		DeviceID:     "dev_12345678",
		DeviceSecret: "sk_secret",
		ProductKey:   "switch_v1",
		MQTTUsername: "switch_v1&dev_12345678",
		MQTTPassword: "tk_secret",
		MQTTClientID: "switch_v1&dev_12345678",
	}

	resp := svc.buildActivationResponse(device)

	if resp.MQTT.Server != "mqtt.example.com" {
		t.Fatalf("expected external broker, got %q", resp.MQTT.Server)
	}
	if resp.MQTT.Port != 1883 || resp.MQTT.PortTLS != 8883 {
		t.Fatalf("unexpected mqtt ports: %+v", resp.MQTT)
	}
	if !strings.Contains(resp.Topics.PropertyPost, "/sys/switch_v1/dev_12345678/") {
		t.Fatalf("unexpected property post topic: %q", resp.Topics.PropertyPost)
	}
	if !strings.Contains(resp.Topics.PropertySet, "/thing/service/property/set") {
		t.Fatalf("unexpected property set topic: %q", resp.Topics.PropertySet)
	}
}

func TestGetStatusMappings(t *testing.T) {
	t.Parallel()

	svc := &DeviceService{}

	if got := svc.getStatusString(model.DeviceStatusOnline); got != "online" {
		t.Fatalf("expected online, got %q", got)
	}
	if got := svc.getStatusString(99); got != "inactive" {
		t.Fatalf("expected fallback inactive, got %q", got)
	}
	if got := svc.getStatusText(model.DeviceStatusDisabled); got != "已禁用" {
		t.Fatalf("expected 已禁用, got %q", got)
	}
	if got := svc.getStatusText(99); got != "未知" {
		t.Fatalf("expected 未知, got %q", got)
	}
}

func TestToDeviceInfoFormatsOptionalTimes(t *testing.T) {
	t.Parallel()

	svc := &DeviceService{}
	lastOnlineAt := time.Date(2026, 1, 2, 3, 4, 5, 0, time.UTC)
	activatedAt := time.Date(2026, 1, 1, 1, 2, 3, 0, time.UTC)
	device := &model.Device{
		DeviceID:        "dev_12345678",
		DeviceSN:        "SN001",
		ProductKey:      "switch_v1",
		Name:            "Living Room Switch",
		Status:          model.DeviceStatusOffline,
		FirmwareVersion: "1.0.0",
		ChipModel:       "ESP32",
		LastOnlineAt:    &lastOnlineAt,
		ActivatedAt:     &activatedAt,
		CreatedAt:       time.Date(2025, 12, 30, 10, 0, 0, 0, time.UTC),
	}

	info := svc.toDeviceInfo(device)

	if info.Status != "offline" || info.StatusText != "离线" {
		t.Fatalf("unexpected status mapping: %+v", info)
	}
	if info.LastOnlineAt == nil || *info.LastOnlineAt != "2026-01-02 03:04:05" {
		t.Fatalf("unexpected lastOnlineAt: %+v", info.LastOnlineAt)
	}
	if info.ActivatedAt == nil || *info.ActivatedAt != "2026-01-01 01:02:03" {
		t.Fatalf("unexpected activatedAt: %+v", info.ActivatedAt)
	}
}

func TestGenerateCredentialFormats(t *testing.T) {
	t.Parallel()

	svc := &DeviceService{}

	deviceID := svc.generateDeviceID()
	if !strings.HasPrefix(deviceID, "dev_") {
		t.Fatalf("unexpected device id: %q", deviceID)
	}

	secret := svc.generateSecret()
	if !strings.HasPrefix(secret, "sk_") || len(secret) != 35 {
		t.Fatalf("unexpected secret format: %q", secret)
	}

	token := svc.generateToken()
	if !strings.HasPrefix(token, "tk_") || len(token) != 51 {
		t.Fatalf("unexpected token format: %q", token)
	}
}

func TestGetDeviceStatusDecodesJSONStringPropertyValue(t *testing.T) {
	db := newTestDB(t)
	seedProduct(t, db, "switch_v1", 1)
	svc := newDeviceServiceForTest(db)

	device := &model.Device{
		DeviceID:   "dev_json_value",
		DeviceSN:   "SN-JSON-1",
		ProductKey: "switch_v1",
		Status:     model.DeviceStatusOnline,
	}
	if err := db.Create(device).Error; err != nil {
		t.Fatalf("seed device: %v", err)
	}
	if err := db.Create(&model.DeviceProperty{
		DeviceID:   device.DeviceID,
		PropertyID: "position",
		Value:      `"up"`,
		ReportedAt: time.Now(),
	}).Error; err != nil {
		t.Fatalf("seed device property: %v", err)
	}

	status, err := svc.GetDeviceStatus(device.DeviceID)
	if err != nil {
		t.Fatalf("GetDeviceStatus returned error: %v", err)
	}
	if status["position"] != "up" {
		t.Fatalf("expected decoded position 'up', got %+v", status["position"])
	}
}
