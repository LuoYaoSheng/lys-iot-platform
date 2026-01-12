// 密码重置模型
// 作者: 罗耀生
// 日期: 2025-01-12

package model

import "time"

// PasswordResetToken 密码重置令牌
type PasswordResetToken struct {
	ID        int64     `gorm:"primaryKey" json:"id"`
	Token     string    `gorm:"uniqueIndex;size:64" json:"token"`
	Email     string    `gorm:"index;size:128" json:"email"`
	ExpiresAt time.Time `json:"expiresAt"`
	UsedAt    *time.Time `json:"usedAt"`
	CreatedAt time.Time `json:"createdAt"`
}

func (PasswordResetToken) TableName() string {
	return "password_reset_tokens"
}
