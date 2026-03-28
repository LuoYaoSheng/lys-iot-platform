// 配置模块
// 作者: 罗耀生
// 日期: 2025-12-13
// 更新: 2025-12-15 - 添加 .env 文件支持
// 更新: 2025-12-16 - 添加 EMQX API 配置
// 更新: 2025-12-30 - 移除硬编码默认密码，增加安全警告

package config

import (
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	Server   ServerConfig
	Database DatabaseConfig
	Redis    RedisConfig
	MQTT     MQTTConfig
	JWT      JWTConfig
	EMQX     EMQXConfig
}

type JWTConfig struct {
	Secret      string
	ExpireHours int
}

type ServerConfig struct {
	Port string
}

type DatabaseConfig struct {
	Host     string
	Port     string
	User     string
	Password string
	DBName   string
}

type RedisConfig struct {
	Host string
	Port string
}

type MQTTConfig struct {
	Broker         string // 内部地址 (后端连接用)
	BrokerExternal string // 外部地址 (设备连接用)
	Port           int
}

type EMQXConfig struct {
	APIUrl       string
	APIUsername  string
	APIPassword  string
	SyncInterval int // 设备状态同步间隔（分钟）
}

// Load 加载配置
// 优先级: 环境变量 > .env 文件 > 默认值
func Load() *Config {
	// 尝试加载 .env 文件（如果存在）
	// godotenv.Load 不会覆盖已存在的环境变量
	if err := godotenv.Load(); err != nil {
		log.Println("[Config] No .env file found, using defaults and environment variables")
	} else {
		log.Println("[Config] Loaded .env file")
	}

	// 检查必需的敏感配置，未设置时使用默认值并警告
	dbPassword := getEnv("DB_PASSWORD", "")
	jwtSecret := getEnv("JWT_SECRET", "")

	if dbPassword == "" {
		log.Println("[Config] WARNING: DB_PASSWORD not set, using default (not recommended for production)")
		dbPassword = "iot123456"
	}
	if jwtSecret == "" {
		log.Println("[Config] WARNING: JWT_SECRET not set, using default (not recommended for production)")
		jwtSecret = "iot-platform-secret-key-change-me"
	}

	return &Config{
		Server: ServerConfig{
			Port: getEnv("SERVER_PORT", "48080"),
		},
		Database: DatabaseConfig{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnv("DB_PORT", "48306"),
			User:     getEnv("DB_USER", "iot_user"),
			Password: dbPassword,
			DBName:   getEnv("DB_NAME", "iot_platform"),
		},
		Redis: RedisConfig{
			Host: getEnv("REDIS_HOST", "localhost"),
			Port: getEnv("REDIS_PORT", "48379"),
		},
		MQTT: MQTTConfig{
			Broker:         getEnv("MQTT_BROKER", "localhost"),
			BrokerExternal: getEnv("MQTT_BROKER_EXTERNAL", "localhost"),
			Port:           getEnvInt("MQTT_PORT", 48883),
		},
		JWT: JWTConfig{
			Secret:      jwtSecret,
			ExpireHours: getEnvInt("JWT_EXPIRE_HOURS", 2),
		},
		EMQX: EMQXConfig{
			APIUrl:       getEnv("EMQX_API_URL", "http://localhost:48884"),
			APIUsername:  getEnv("EMQX_API_USERNAME", ""),
			APIPassword:  getEnv("EMQX_API_PASSWORD", ""),
			SyncInterval: getEnvInt("EMQX_SYNC_INTERVAL", 5),
		},
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intVal, err := strconv.Atoi(value); err == nil {
			return intVal
		}
	}
	return defaultValue
}
