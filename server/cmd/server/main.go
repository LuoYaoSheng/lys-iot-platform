// IoT Platform Core - 主入口 (简化版 - 内置MQTT Broker)
// 作者: 罗耀生
// 日期: 2025-12-13
// 更新: 2026-01-06 - 内置MQTT Broker，移除EMQX依赖

package main

import (
	"fmt"
	"log"

	"iot-platform-core/internal/config"
	"iot-platform-core/internal/handler"
	"iot-platform-core/internal/model"
	"iot-platform-core/internal/mqtt"
	"iot-platform-core/internal/repository"
	"iot-platform-core/internal/service"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func main() {
	log.Println("Starting IoT Platform Core (Embedded MQTT)...")

	// 加载配置
	cfg := config.Load()
	log.Printf("Config loaded: DB=%s:%s, Server=:%s, MQTT Port=%d",
		cfg.Database.Host, cfg.Database.Port, cfg.Server.Port, cfg.MQTT.Port)

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

// initDefaultData 初始化默认数据（仅在数据为空时执行）
func initDefaultData(db *gorm.DB) error {
	log.Println("Checking default data...")

	// 检查产品表是否为空
	var productCount int64
	if err := db.Model(&model.Product{}).Count(&productCount).Error; err != nil {
		return fmt.Errorf("failed to count products: %w", err)
	}

	// 如果产品表为空，插入默认产品
	if productCount == 0 {
		log.Println("Product table is empty, initializing default products...")

		defaultProducts := []model.Product{
			{
				ProductKey:  "SW-SERVO-001",
				Name:        "智能开关(舵机版)",
				Description: "ESP32智能舵机开关，支持BLE配网和MQTT控制",
				Category:    "switch",
				Status:      1,
			},
		}

		for _, product := range defaultProducts {
			if err := db.Create(&product).Error; err != nil {
				log.Printf("Failed to create product %s: %v", product.ProductKey, err)
			} else {
				log.Printf("✓ Created product: %s (%s)", product.ProductKey, product.Name)
			}
		}

		log.Println("Default products initialized successfully")
	} else {
		log.Printf("Product table already has %d products, skipping initialization", productCount)
	}

	return nil
}
