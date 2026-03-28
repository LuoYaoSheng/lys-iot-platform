package handler

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"iot-platform-core/internal/model"
	"iot-platform-core/internal/repository"
	"iot-platform-core/internal/service"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type responseEnvelope struct {
	Code    int                    `json:"code"`
	Message string                 `json:"message"`
	Data    map[string]interface{} `json:"data"`
}

func newHandlerTestDB(t *testing.T) *gorm.DB {
	t.Helper()

	dsn := fmt.Sprintf("file:%s?mode=memory&cache=shared", t.Name())
	db, err := gorm.Open(sqlite.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	})
	if err != nil {
		t.Fatalf("open sqlite db: %v", err)
	}

	if err := db.AutoMigrate(
		&model.User{},
		&model.APIKey{},
		&model.RefreshToken{},
		&model.Project{},
		&model.ProjectMember{},
		&model.Product{},
		&model.Device{},
		&model.DeviceProperty{},
		&model.DeviceEvent{},
		&model.MQTTAuthLog{},
	); err != nil {
		t.Fatalf("auto migrate: %v", err)
	}

	return db
}

func newUserServiceForHandlerTests(db *gorm.DB) *service.UserService {
	return service.NewUserService(
		repository.NewUserRepository(db),
		repository.NewAPIKeyRepository(db),
		repository.NewRefreshTokenRepository(db),
		"handler-test-secret",
	)
}

func newProjectServiceForHandlerTests(db *gorm.DB) *service.ProjectService {
	return service.NewProjectService(
		repository.NewProjectRepository(db),
		repository.NewDeviceRepository(db),
	)
}

func newDeviceServiceForHandlerTests(db *gorm.DB) *service.DeviceService {
	return service.NewDeviceService(
		repository.NewDeviceRepository(db),
		repository.NewProductRepository(db),
		"mqtt.internal",
		"mqtt.example.com",
		1883,
	)
}

func performJSONRequest(t *testing.T, router http.Handler, method, path string, body interface{}, headers map[string]string) *httptest.ResponseRecorder {
	t.Helper()

	var payload []byte
	var err error
	if body != nil {
		payload, err = json.Marshal(body)
		if err != nil {
			t.Fatalf("marshal request body: %v", err)
		}
	}

	req := httptest.NewRequest(method, path, bytes.NewReader(payload))
	req.Header.Set("Content-Type", "application/json")
	for k, v := range headers {
		req.Header.Set(k, v)
	}

	rec := httptest.NewRecorder()
	router.ServeHTTP(rec, req)
	return rec
}

func decodeResponseEnvelope(t *testing.T, rec *httptest.ResponseRecorder) responseEnvelope {
	t.Helper()

	var resp responseEnvelope
	if err := json.Unmarshal(rec.Body.Bytes(), &resp); err != nil {
		t.Fatalf("decode response: %v; body=%s", err, rec.Body.String())
	}
	return resp
}

func registerAndLoginTestUser(t *testing.T, userService *service.UserService) (*service.RegisterResponse, *service.LoginResponse) {
	t.Helper()

	registerResp, err := userService.Register(&service.RegisterRequest{
		Email:    "handler@example.com",
		Password: "StrongPass1",
		Name:     "Handler User",
	})
	if err != nil {
		t.Fatalf("register test user: %v", err)
	}

	loginResp, err := userService.Login(&service.LoginRequest{
		Email:    "handler@example.com",
		Password: "StrongPass1",
	})
	if err != nil {
		t.Fatalf("login test user: %v", err)
	}

	return registerResp, loginResp
}

func seedHandlerTestProduct(t *testing.T, db *gorm.DB, productKey string, status int) {
	t.Helper()

	if err := db.Create(&model.Product{
		ProductKey:  productKey,
		Name:        "Handler Test Product",
		Description: "seeded for handler tests",
		Category:    "switch",
		Status:      status,
	}).Error; err != nil {
		t.Fatalf("seed product: %v", err)
	}
}
