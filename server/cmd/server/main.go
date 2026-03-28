// IoT Platform Core - 主入口
// 作者: 罗耀生
// 日期: 2025-12-13
// 更新: 2025-12-14 - 添加 Project 和 Webhook 支持

package main

import (
	"fmt"
	"log"

	"iot-platform-core/internal/config"
	"iot-platform-core/internal/handler"
	"iot-platform-core/internal/model"
	"iot-platform-core/internal/repository"
	"iot-platform-core/internal/service"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func main() {
	log.Println("Starting IoT Platform Core...")

	// 加载配置
	cfg := config.Load()
	log.Printf("Config loaded: DB=%s:%s, Server=:%s, MQTT=%s:%d",
		cfg.Database.Host, cfg.Database.Port, cfg.Server.Port,
		cfg.MQTT.Broker, cfg.MQTT.Port)

	// 连接数据库
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
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
		cfg.MQTT.Broker,
		cfg.MQTT.BrokerExternal,
		cfg.MQTT.Port,
	)

	userService := service.NewUserService(
		userRepo,
		apiKeyRepo,
		refreshTokenRepo,
		cfg.JWT.Secret,
	)

	productService := service.NewProductService(productRepo)
	projectService := service.NewProjectService(projectRepo, deviceRepo)

	// 初始化 MQTT 服务（用于发布控制指令）
	mqttService := service.NewMQTTService(
		cfg.MQTT.Broker,
		cfg.MQTT.Port,
		"iot-platform-core",
		"", // MQTT 用户名（平台内部使用，可留空）
		"", // MQTT 密码
	)

	// 尝试连接 MQTT Broker
	if err := mqttService.Connect(); err != nil {
		log.Printf("Warning: MQTT connection failed: %v (device control will be unavailable)", err)
	} else {
		log.Println("MQTT connected")
	}

	// 初始化 EMQX API 服务（用于查询在线设备）
	emqxService := service.NewEMQXService(
		cfg.EMQX.APIUrl,
		cfg.EMQX.APIUsername,
		cfg.EMQX.APIPassword,
	)

	// 测试 EMQX API 连接
	if err := emqxService.TestConnection(); err != nil {
		log.Printf("Warning: EMQX API connection failed: %v (device status sync will be unavailable)", err)
	} else {
		log.Println("EMQX API connected")

		// 初始化设备同步服务
		deviceSyncService := service.NewDeviceSyncService(db, deviceRepo, emqxService)

		// 启动时同步设备在线状态
		log.Println("Syncing device online status from EMQX...")
		if err := deviceSyncService.SyncDeviceStatusOnStartup(); err != nil {
			log.Printf("Warning: Device status sync failed: %v", err)
		}

		// 启动定时同步任务
		deviceSyncService.StartHeartbeatMonitor(cfg.EMQX.SyncInterval)
	}

	// 初始化处理器
	deviceHandler := handler.NewDeviceHandler(deviceService, authLogRepo)
	deviceHandler.SetMQTTService(mqttService)
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
			mqtt.GET("/auth", deviceHandler.MQTTAuth)
			mqtt.POST("/auth", deviceHandler.MQTTAuth)
			mqtt.GET("/acl", deviceHandler.MQTTACL)
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

// initDefaultData 初始化默认数据（仅在数据为空时执行）
func initDefaultData(db *gorm.DB) error {
	log.Println("Checking default data...")

	// 检查产品表是否为空
	var productCount int64
	if err := db.Model(&model.Product{}).Count(&productCount).Error; err != nil {
		return fmt.Errorf("failed to count products: %w", err)
	}

	defaultProducts := []model.Product{
		{
			ProductKey:   "SW-SERVO-001",
			Name:         "智能开关(舵机版)",
			Description:  "ESP32智能舵机开关，支持BLE配网和MQTT控制",
			Category:     "switch",
			ControlMode:  "toggle",
			UITemplate:   "switch_toggle",
			IconName:     "power_settings_new",
			IconColor:    "#2F855A",
			NodeType:     "device",
			Capabilities: `{"positions":["up","middle","down"]}`,
			Status:       1,
		},
	}

	if productCount == 0 {
		log.Println("Product table is empty, initializing default products...")
	} else {
		log.Printf("Product table already has %d products, ensuring default product metadata is up to date", productCount)
	}

	for _, defaults := range defaultProducts {
		var product model.Product
		err := db.Where("product_key = ?", defaults.ProductKey).First(&product).Error
		if err != nil {
			if err := db.Create(&defaults).Error; err != nil {
				log.Printf("Failed to create product %s: %v", defaults.ProductKey, err)
			} else {
				log.Printf("✓ Created product: %s (%s)", defaults.ProductKey, defaults.Name)
			}
			continue
		}

		updates := map[string]interface{}{
			"name":         defaults.Name,
			"description":  defaults.Description,
			"category":     defaults.Category,
			"control_mode": defaults.ControlMode,
			"ui_template":  defaults.UITemplate,
			"icon_name":    defaults.IconName,
			"icon_color":   defaults.IconColor,
			"node_type":    defaults.NodeType,
			"capabilities": defaults.Capabilities,
			"status":       defaults.Status,
		}
		if err := db.Model(&product).Updates(updates).Error; err != nil {
			log.Printf("Failed to update product %s metadata: %v", defaults.ProductKey, err)
		} else {
			log.Printf("✓ Ensured product metadata: %s (%s)", defaults.ProductKey, defaults.Name)
		}
	}

	log.Println("Default products initialized successfully")

	return nil
}
