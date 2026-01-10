// IoT Platform Core - 主入口 (简化版 - 内置MQTT Broker)
// 作者: 罗耀生
// 日期: 2025-12-13
// 更新: 2026-01-06 - 内置MQTT Broker，移除EMQX依赖

package main

import (
	"fmt"
	"log"
	"time"

	"iot-platform-core/internal/config"
	"iot-platform-core/internal/handler"
	"iot-platform-core/internal/model"
	"iot-platform-core/internal/mqtt"
	"iot-platform-core/internal/redis"
	"iot-platform-core/internal/repository"
	"iot-platform-core/internal/service"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func main() {
	log.Println("Starting IoT Platform Core (Embedded MQTT + Redis)...")

	// 加载配置
	cfg := config.Load()
	log.Printf("Config loaded: DB=%s:%s, Server=:%s, MQTT Port=%d, Redis=%s:%s",
		cfg.Database.Host, cfg.Database.Port, cfg.Server.Port, cfg.MQTT.Port, cfg.Redis.Host, cfg.Redis.Port)

	// 连接数据库
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&collation=utf8mb4_unicode_ci",
		cfg.Database.User,
		cfg.Database.Password,
		cfg.Database.Host,
		cfg.Database.Port,
		cfg.Database.DBName,
	)

	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	log.Println("Database connected")

	// 设置连接字符集为 utf8mb4
	sqlDB, _ := db.DB()
	sqlDB.Exec("SET NAMES utf8mb4")

	// 自动迁移数据库表
	if err := autoMigrate(db); err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}
	log.Println("Database migrated")

	// 初始化默认数据
	if err := initDefaultData(db); err != nil {
		log.Printf("Warning: Failed to initialize default data: %v", err)
	}

	// 初始化仓库
	deviceRepo := repository.NewDeviceRepository(db)
	productRepo := repository.NewProductRepository(db)
	authLogRepo := repository.NewMQTTAuthLogRepository(db)
	userRepo := repository.NewUserRepository(db)
	apiKeyRepo := repository.NewAPIKeyRepository(db)
	refreshTokenRepo := repository.NewRefreshTokenRepository(db)
	projectRepo := repository.NewProjectRepository(db)

	// 初始化服务
	deviceService := service.NewDeviceService(
		deviceRepo,
		productRepo,
		cfg.MQTT.Port,
	)

	userService := service.NewUserService(
		userRepo,
		apiKeyRepo,
		refreshTokenRepo,
		cfg.JWT.Secret,
		cfg.JWT.ExpireHours,
	)

	productService := service.NewProductService(productRepo)
	projectService := service.NewProjectService(projectRepo, deviceRepo)

	// 初始化 Redis 客户端
	redisClient, err := redis.NewClient(&redis.Config{
		Host: cfg.Redis.Host,
		Port: cfg.Redis.Port,
	}, cfg.Redis.DeviceOnlineTTL)
	if err != nil {
		log.Printf("[Redis] Failed to connect: %v (continuing without Redis)", err)
		redisClient = nil
	}
	defer func() {
		if redisClient != nil {
			redisClient.Close()
		}
	}()

// 启动内置 MQTT Broker
	mqttBroker := mqtt.NewBroker(func(clientID, username, password string) bool {
		// 平台内部客户端直接放行
		if clientID == "iot-platform-core" {
			return true
		}
		// 验证设备认证
		_, err := deviceService.ValidateMQTTAuth(username, password, clientID)
		return err == nil
	})

	// 设置 Redis 客户端到 Broker
	if redisClient != nil {
		mqttBroker.SetRedisClient(redisClient)
	}

	// 设置设备状态更新回调（当设备连接/断开时更新数据库）
	mqttBroker.SetStatusUpdate(func(deviceID string, online bool) {
		if err := deviceService.UpdateDeviceOnline(deviceID, online); err != nil {
			log.Printf("[MQTT] Failed to update device status: %s, %v", deviceID, err)
		} else {
			log.Printf("[MQTT] Device status updated: %s -> %v", deviceID, map[bool]string{true: "online", false: "offline"}[online])
		}
	})
	// 启动定时检查离线设备的任务（每30秒检查一次）
	// 使用 Redis 实时状态对比数据库状态，找出真正离线的设备
	go func() {
		ticker := time.NewTicker(30 * time.Second)
		defer ticker.Stop()
		for range ticker.C {
			checkOfflineDevices(deviceRepo, redisClient)
		}
	}()

	tcpAddr := fmt.Sprintf(":%d", cfg.MQTT.Port)
	wsAddr := fmt.Sprintf(":%d", cfg.MQTT.WSPort)
	if err := mqttBroker.Start(tcpAddr, wsAddr); err != nil {
		log.Fatalf("Failed to start MQTT Broker: %v", err)
	}
	log.Printf("MQTT Broker started on TCP %s, WS %s", tcpAddr, wsAddr)

	// 初始化处理器
	deviceHandler := handler.NewDeviceHandler(deviceService, authLogRepo)
	deviceHandler.SetMQTTBroker(mqttBroker)
	userHandler := handler.NewUserHandler(userService)
	productHandler := handler.NewProductHandler(productService)
	projectHandler := handler.NewProjectHandler(projectService)
	webhookHandler := handler.NewWebhookHandler(db, deviceRepo)

	// 创建 Gin 路由
	r := gin.Default()

	// CORS 中间件（允许 APP 跨域请求）
	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization, X-API-Key, X-API-Secret")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	// 健康检查
	r.GET("/health", deviceHandler.HealthCheck)

	// API v1
	v1 := r.Group("/api/v1")
	{
		// ========== 用户相关（无需认证） ==========
		users := v1.Group("/users")
		{
			users.POST("/register", userHandler.Register)
			users.POST("/login", userHandler.Login)
			users.POST("/refresh-token", userHandler.RefreshToken)
		}

		// ========== 用户相关（需要认证） ==========
		usersAuth := v1.Group("/users")
		usersAuth.Use(userHandler.AuthMiddleware())
		{
			usersAuth.GET("/me", userHandler.GetMe)
			usersAuth.POST("/api-keys", userHandler.CreateAPIKey)
			usersAuth.GET("/api-keys", userHandler.GetAPIKeys)
			usersAuth.DELETE("/api-keys/:keyId", userHandler.DeleteAPIKey)
		}

		// ========== 项目相关（需要认证） ==========
		projects := v1.Group("/projects")
		projects.Use(userHandler.CombinedAuthMiddleware())
		{
			projects.POST("", projectHandler.CreateProject)
			projects.GET("", projectHandler.GetProjectList)
			projects.GET("/:projectId", projectHandler.GetProject)
			projects.PUT("/:projectId", projectHandler.UpdateProject)
			projects.DELETE("/:projectId", projectHandler.DeleteProject)
		}

		// ========== 设备相关（无需认证 - 设备激活） ==========
		devicesPublic := v1.Group("/devices")
		{
			devicesPublic.POST("/activate", deviceHandler.Activate)
		}

		// ========== 设备相关（需要认证） ==========
		devices := v1.Group("/devices")
		devices.Use(userHandler.CombinedAuthMiddleware())
		{
			devices.GET("", deviceHandler.GetDeviceList)
			devices.GET("/:deviceId", deviceHandler.GetDevice)
			devices.GET("/:deviceId/status", deviceHandler.GetDeviceStatus)
			devices.POST("/:deviceId/control", deviceHandler.ControlDevice)
			devices.DELETE("/:deviceId", deviceHandler.DeleteDevice)
			devices.GET("/:deviceId/properties", webhookHandler.GetDeviceProperties)
			devices.GET("/:deviceId/events", webhookHandler.GetDeviceEvents)
		}

		// ========== 产品相关（需要认证） ==========
		products := v1.Group("/products")
		products.Use(userHandler.CombinedAuthMiddleware())
		{
			products.POST("", productHandler.CreateProduct)
			products.GET("", productHandler.GetProductList)
			products.GET("/:productKey", productHandler.GetProduct)
			products.PUT("/:productKey", productHandler.UpdateProduct)
			products.DELETE("/:productKey", productHandler.DeleteProduct)
		}

		// ========== MQTT 认证（内部接口，无需用户认证） ==========
		mqtt := v1.Group("/mqtt")
		{
			mqtt.POST("/auth", deviceHandler.MQTTAuth)
			mqtt.POST("/acl", deviceHandler.MQTTACL)
		}

		// ========== Webhook（EMQX 回调，无需用户认证） ==========
		webhook := v1.Group("/webhook")
		{
			webhook.POST("/client", webhookHandler.HandleClientEvent)
			webhook.POST("/message", webhookHandler.HandleMessageEvent)
		}
	}

	// 启动服务器
	addr := ":" + cfg.Server.Port
	log.Printf("Server starting on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

// autoMigrate 自动迁移数据库表
func autoMigrate(db *gorm.DB) error {
	return db.AutoMigrate(
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
	)
}

// initDefaultData 初始化默认数据（仅在数据为空时执行，或更新缺失字段）
func initDefaultData(db *gorm.DB) error {
	log.Println("Checking default data...")

	// 默认产品配置
	defaultProducts := []model.Product{
		{
			ProductKey:   "SW-SERVO-001",
			Name:         "Smart Servo Switch",
			Description:  "ESP32 Smart Servo Switch with BLE provisioning",
			Category:     "switch",
			ControlMode:  "pulse",     // 脉冲触发模式
			UITemplate:   "servo",     // 舵机UI模板
			IconName:     "bolt",      // 闪电图标
			IconColor:    "#FF6B35",   // 橙色
			Manufacturer: "SmartLink",
			Model:        "ESP32-Servo-Switch-v1",
			Status:       1,
		},
		{
			ProductKey:   "USB-WAKEUP-S3",
			Name:         "USB Wakeup Device",
			Description:  "ESP32-S3 USB HID Wakeup Device with BLE provisioning",
			ControlMode:  "trigger",
			UITemplate:   "wakeup",
			IconName:     "keyboard",
			IconColor:    "#6C63FF",
			Manufacturer: "SmartLink",
			Model:        "ESP32-S3-N16R8",
			Status:       1,
		},
}

	for _, defaultProduct := range defaultProducts {
		var existingProduct model.Product
		if err := db.Where("product_key = ?", defaultProduct.ProductKey).First(&existingProduct).Error; err != nil {
			// 产品不存在，创建新记录
			if err := db.Create(&defaultProduct).Error; err != nil {
				log.Printf("Failed to create product %s: %v", defaultProduct.ProductKey, err)
			} else {
				log.Printf("✓ Created product: %s (%s)", defaultProduct.ProductKey, defaultProduct.Name)
			}
		} else {
			// 产品存在，更新缺失字段
			updated := false
			updates := map[string]interface{}{}

			if existingProduct.ControlMode == "" {
				updates["control_mode"] = defaultProduct.ControlMode
				updated = true
			}
			if existingProduct.UITemplate == "" {
				updates["ui_template"] = defaultProduct.UITemplate
				updated = true
			}
			if existingProduct.IconName == "" {
				updates["icon_name"] = defaultProduct.IconName
				updated = true
			}
			if existingProduct.IconColor == "" {
				updates["icon_color"] = defaultProduct.IconColor
				updated = true
			}
			if existingProduct.Manufacturer == "" {
				updates["manufacturer"] = defaultProduct.Manufacturer
				updated = true
			}
			if existingProduct.Model == "" {
				updates["model"] = defaultProduct.Model
				updated = true
			}

			if updated {
				if err := db.Model(&existingProduct).Updates(updates).Error; err != nil {
					log.Printf("Failed to update product %s: %v", defaultProduct.ProductKey, err)
				} else {
					log.Printf("✓ Updated product fields: %s", defaultProduct.ProductKey)
				}
			} else {
				log.Printf("Product %s already up to date", defaultProduct.ProductKey)
			}
		}
	}

	log.Println("Default products check completed")
	return nil
}

// checkOfflineDevices 检查离线设备
// 逻辑: 查询数据库中状态为在线的设备，对比 Redis 中的实际在线状态
// 如果 Redis 中不存在该设备（TTL 过期），则标记为离线
func checkOfflineDevices(deviceRepo *repository.DeviceRepository, redisClient *redis.Client) {
	// 如果 Redis 未启用，不执行检查
	if redisClient == nil {
		return
	}

	// 获取数据库中所有在线设备
	onlineDevices, err := deviceRepo.FindByStatus(model.DeviceStatusOnline)
	if err != nil {
		log.Printf("[Device] Failed to query online devices: %v", err)
		return
	}

	// 检查每个在线设备在 Redis 中的状态
	offlineCount := 0
	for _, device := range onlineDevices {
		// 如果 Redis 中不存在该设备（TTL 过期或从未连接），说明已离线
		if !redisClient.IsDeviceOnline(device.DeviceID) {
			if err := deviceRepo.UpdateStatus(device.DeviceID, model.DeviceStatusOffline); err != nil {
				log.Printf("[Device] Failed to mark offline: %s, %v", device.DeviceID, err)
			} else {
				log.Printf("[Device] Device %s marked offline (not in Redis)", device.DeviceID)
				offlineCount++
			}
		}
	}

	if offlineCount > 0 {
		log.Printf("[Device] Marked %d device(s) offline", offlineCount)
	}
}
