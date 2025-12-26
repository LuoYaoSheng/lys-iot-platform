// 用户模型
// 作者: 罗耀生
// 日期: 2025-12-13

package model

import (
	"time"
)

// UserStatus 用户状态
type UserStatus int

const (
	UserStatusPending  UserStatus = 0 // 待激活
	UserStatusActive   UserStatus = 1 // 正常
	UserStatusDisabled UserStatus = 2 // 禁用
)

// User 用户
type User struct {
	ID           int64      `gorm:"primaryKey" json:"id"`
	UserID       string     `gorm:"uniqueIndex;size:64" json:"userId"`
	Email        string     `gorm:"uniqueIndex;size:128" json:"email"`
	PasswordHash string     `gorm:"size:256" json:"-"`
	Name         string     `gorm:"size:64" json:"name"`
	Phone        string     `gorm:"size:32" json:"phone"`
	Avatar       string     `gorm:"size:256" json:"avatar"`
	Status       UserStatus `gorm:"default:1" json:"status"`
	LastLoginAt  *time.Time `json:"lastLoginAt"`
	CreatedAt    time.Time  `json:"createdAt"`
	UpdatedAt    time.Time  `json:"updatedAt"`
}

func (User) TableName() string {
	return "users"
}

// APIKey API密钥
type APIKey struct {
	ID          int64     `gorm:"primaryKey" json:"id"`
	KeyID       string    `gorm:"uniqueIndex;size:64" json:"keyId"`
	UserID      string    `gorm:"index;size:64" json:"userId"`
	APIKey      string    `gorm:"uniqueIndex;size:64" json:"apiKey"`
	APISecret   string    `gorm:"size:128" json:"-"`
	Name        string    `gorm:"size:64" json:"name"`
	Permissions string    `gorm:"type:text" json:"permissions"` // JSON array
	ExpiresAt   *time.Time `json:"expiresAt"`
	LastUsedAt  *time.Time `json:"lastUsedAt"`
	Status      int       `gorm:"default:1" json:"status"`
	CreatedAt   time.Time `json:"createdAt"`
	UpdatedAt   time.Time `json:"updatedAt"`
}

func (APIKey) TableName() string {
	return "api_keys"
}

// RefreshToken 刷新令牌
type RefreshToken struct {
	ID        int64     `gorm:"primaryKey" json:"id"`
	Token     string    `gorm:"uniqueIndex;size:128" json:"token"`
	UserID    string    `gorm:"index;size:64" json:"userId"`
	ExpiresAt time.Time `json:"expiresAt"`
	CreatedAt time.Time `json:"createdAt"`
}

func (RefreshToken) TableName() string {
	return "refresh_tokens"
}
