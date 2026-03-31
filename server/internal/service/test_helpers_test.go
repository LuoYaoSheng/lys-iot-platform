package service

import (
	"fmt"
	"testing"
	"time"

	"iot-platform-core/internal/model"
	"iot-platform-core/internal/repository"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func newTestDB(t *testing.T) *gorm.DB {
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
		&model.PasswordResetToken{},
		&model.Project{},
		&model.ProjectMember{},
		&model.Product{},
		&model.Device{},
		&model.DeviceProperty{},
		&model.DeviceEvent{},
		&model.MQTTAuthLog{},
	); err != nil {
		t.Fatalf("auto migrate test db: %v", err)
	}

	return db
}

func newUserServiceForTest(db *gorm.DB) *UserService {
	return NewUserService(
		repository.NewUserRepository(db),
		repository.NewAPIKeyRepository(db),
		repository.NewRefreshTokenRepository(db),
		repository.NewPasswordResetTokenRepository(db),
		"test-jwt-secret",
		2,
	)
}

func newProjectServiceForTest(db *gorm.DB) *ProjectService {
	return NewProjectService(
		repository.NewProjectRepository(db),
		repository.NewDeviceRepository(db),
	)
}

func newDeviceServiceForTest(db *gorm.DB) *DeviceService {
	return NewDeviceService(
		repository.NewDeviceRepository(db),
		repository.NewProductRepository(db),
		"mqtt.internal",
		"mqtt.example.com",
		1883,
	)
}

func seedProduct(t *testing.T, db *gorm.DB, productKey string, status int) {
	t.Helper()

	product := &model.Product{
		ProductKey:  productKey,
		Name:        "Test Product",
		Description: "seeded for tests",
		Category:    "switch",
		Status:      status,
	}

	if err := db.Create(product).Error; err != nil {
		t.Fatalf("seed product: %v", err)
	}
}

func seedProject(t *testing.T, db *gorm.DB, projectID, userID string) *model.Project {
	t.Helper()

	project := &model.Project{
		ProjectID:   projectID,
		UserID:      userID,
		Name:        "Seed Project",
		Description: "seeded project",
		Status:      model.ProjectStatusActive,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	if err := db.Create(project).Error; err != nil {
		t.Fatalf("seed project: %v", err)
	}

	return project
}
