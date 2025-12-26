// 配置模块
// 作者: 罗耀生
// 日期: 2025-12-13
// 更新: 2025-12-15 - 添加 .env 文件支持
// 更新: 2025-12-16 - 添加 EMQX API 配置

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

	return &Config{
		Server: ServerConfig{
			Port: getEnv("SERVER_PORT", "48080"),
		},
		Database: DatabaseConfig{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnv("DB_PORT", "44306"),
			User:     getEnv("DB_USER", "iot_user"),
			Password: getEnv("DB_PASSWORD", "iot123456"),
			DBName:   getEnv("DB_NAME", "iot_platform"),
		},
		Redis: RedisConfig{
			Host: getEnv("REDIS_HOST", "localhost"),
			Port: getEnv("REDIS_PORT", "47379"),
		},
		MQTT: MQTTConfig{
            Broker:         getEnv("MQTT_BROKER", "localhost"),
            BrokerExternal: getEnv("MQTT_BROKER_EXTERNAL", "localhost"),
            Port:           getEnvInt("MQTT_PORT", 42883),
		},
		JWT: JWTConfig{
			Secret:      getEnv("JWT_SECRET", "iot-platform-secret-key-2025"),
			ExpireHours: getEnvInt("JWT_EXPIRE_HOURS", 2),
		},
		EMQX: EMQXConfig{
			APIUrl:       getEnv("EMQX_API_URL", "http://localhost:18083"),
			APIUsername:  getEnv("EMQX_API_USERNAME", "admin"),
			APIPassword:  getEnv("EMQX_API_PASSWORD", "public"),
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
