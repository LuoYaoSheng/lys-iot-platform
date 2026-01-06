// 配置模块
// 作者: 罗耀生
// 日期: 2025-12-13
// 更新: 2026-01-06 - 简化配置，移除EMQX依赖

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
	MQTT     MQTTConfig
	JWT      JWTConfig
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

type MQTTConfig struct {
	Port   int // TCP端口
	WSPort int // WebSocket端口
}

// Load 加载配置
func Load() *Config {
	if err := godotenv.Load(); err != nil {
		log.Println("[Config] No .env file found, using defaults")
	} else {
		log.Println("[Config] Loaded .env file")
	}

	dbPassword := getEnv("DB_PASSWORD", "")
	jwtSecret := getEnv("JWT_SECRET", "")

	if dbPassword == "" {
		log.Println("[Config] WARNING: DB_PASSWORD not set, using default")
		dbPassword = "iot123456"
	}
	if jwtSecret == "" {
		log.Println("[Config] WARNING: JWT_SECRET not set, using default")
		jwtSecret = "iot-platform-secret-key-change-me"
	}

	return &Config{
		Server: ServerConfig{
			Port: getEnv("SERVER_PORT", "48080"),
		},
		Database: DatabaseConfig{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnv("DB_PORT", "44306"),
			User:     getEnv("DB_USER", "iot_user"),
			Password: dbPassword,
			DBName:   getEnv("DB_NAME", "iot_platform"),
		},
		MQTT: MQTTConfig{
			Port:   getEnvInt("MQTT_PORT", 1883),
			WSPort: getEnvInt("MQTT_WS_PORT", 8083),
		},
		JWT: JWTConfig{
			Secret:      jwtSecret,
			ExpireHours: getEnvInt("JWT_EXPIRE_HOURS", 2),
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
