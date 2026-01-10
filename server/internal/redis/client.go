// Redis 客户端 - 设备在线状态管理
// 作者: 罗耀生
// 日期: 2026-01-06

package redis

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/redis/go-redis/v9"
)

// Client Redis 客户端封装
type Client struct {
	rdb             *redis.Client
	ctx             context.Context
	deviceOnlineTTL int // 设备在线状态TTL（秒）
}

// Config Redis 配置
type Config struct {
	Host     string
	Port     string
	Password string
	DB       int
}

// NewClient 创建 Redis 客户端
func NewClient(cfg *Config, deviceOnlineTTL int) (*Client, error) {
	rdb := redis.NewClient(&redis.Options{
		Addr:     fmt.Sprintf("%s:%s", cfg.Host, cfg.Port),
		Password: cfg.Password,
		DB:       cfg.DB,
	})

	ctx := context.Background()

	// 测试连接
	if err := rdb.Ping(ctx).Err(); err != nil {
		return nil, fmt.Errorf("redis ping failed: %w", err)
	}

	log.Printf("[Redis] Connected to %s:%s (device TTL=%ds)", cfg.Host, cfg.Port, deviceOnlineTTL)

	return &Client{
		rdb:              rdb,
		ctx:              ctx,
		deviceOnlineTTL:  deviceOnlineTTL,
	}, nil
}

// Close 关闭连接
func (c *Client) Close() error {
	if c.rdb != nil {
		return c.rdb.Close()
	}
	return nil
}

// 设备状态相关的 Redis Key
const (
	// Key 格式: iot:device:online:{deviceID}
	// 值: "1" 表示在线
	// TTL: 120 秒，自动过期表示离线
	deviceOnlinePrefix = "iot:device:online:"
)

// deviceOnlineKey 生成设备在线状态的 Redis Key
func deviceOnlineKey(deviceID string) string {
	return deviceOnlinePrefix + deviceID
}

// SetDeviceOnline 设置设备在线（带 TTL 自动过期）
func (c *Client) SetDeviceOnline(deviceID string) error {
	key := deviceOnlineKey(deviceID)
	// 设置为在线，TTL 120 秒（大于 MQTT keep-alive 60 秒的 2 倍）
	if err := c.rdb.Set(c.ctx, key, "1", time.Duration(c.deviceOnlineTTL)*time.Second).Err(); err != nil {
		return fmt.Errorf("failed to set device online: %w", err)
	}
	log.Printf("[Redis] Device %s marked online (TTL=%ds)", deviceID, c.deviceOnlineTTL)
	return nil
}

// SetDeviceOffline 设置设备离线
func (c *Client) SetDeviceOffline(deviceID string) error {
	key := deviceOnlineKey(deviceID)
	if err := c.rdb.Del(c.ctx, key).Err(); err != nil {
		return fmt.Errorf("failed to set device offline: %w", err)
	}
	log.Printf("[Redis] Device %s marked offline", deviceID)
	return nil
}

// IsDeviceOnline 检查设备是否在线
func (c *Client) IsDeviceOnline(deviceID string) bool {
	key := deviceOnlineKey(deviceID)
	exists, err := c.rdb.Exists(c.ctx, key).Result()
	if err != nil {
		log.Printf("[Redis] Failed to check device online: %v", err)
		return false
	}
	return exists > 0
}

// RefreshDeviceOnline 刷新设备在线状态（重置 TTL）
func (c *Client) RefreshDeviceOnline(deviceID string) error {
	key := deviceOnlineKey(deviceID)
	// 只有当 key 存在时才刷新 TTL
	exists, err := c.rdb.Exists(c.ctx, key).Result()
	if err != nil {
		return fmt.Errorf("failed to check device: %w", err)
	}
	if exists > 0 {
		if err := c.rdb.Expire(c.ctx, key, time.Duration(c.deviceOnlineTTL)*time.Second).Err(); err != nil {
			return fmt.Errorf("failed to refresh device online: %w", err)
		}
	}
	return nil
}

// GetAllOnlineDevices 获取所有在线设备的 deviceID 列表
func (c *Client) GetAllOnlineDevices() ([]string, error) {
	keys, err := c.rdb.Keys(c.ctx, deviceOnlinePrefix+"*").Result()
	if err != nil {
		return nil, fmt.Errorf("failed to get online devices: %w", err)
	}

	// 从 key 中提取 deviceID
	deviceIDs := make([]string, 0, len(keys))
	prefixLen := len(deviceOnlinePrefix)
	for _, key := range keys {
		if len(key) > prefixLen {
			deviceIDs = append(deviceIDs, key[prefixLen:])
		}
	}

	return deviceIDs, nil
}
