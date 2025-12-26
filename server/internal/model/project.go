// 项目模型
// 作者: 罗耀生
// 日期: 2025-12-13

package model

import (
	"time"
)

// ProjectStatus 项目状态
type ProjectStatus int

const (
	ProjectStatusActive   ProjectStatus = 1 // 正常
	ProjectStatusDisabled ProjectStatus = 2 // 禁用
	ProjectStatusArchived ProjectStatus = 3 // 归档
)

// Project 项目
type Project struct {
	ID          int64         `gorm:"primaryKey" json:"id"`
	ProjectID   string        `gorm:"uniqueIndex;size:64" json:"projectId"`
	UserID      string        `gorm:"index;size:64" json:"userId"`
	Name        string        `gorm:"size:128" json:"name"`
	Description string        `gorm:"type:text" json:"description"`
	Status      ProjectStatus `gorm:"default:1" json:"status"`
	CreatedAt   time.Time     `json:"createdAt"`
	UpdatedAt   time.Time     `json:"updatedAt"`
}

func (Project) TableName() string {
	return "projects"
}

// ProjectMember 项目成员
type ProjectMember struct {
	ID        int64     `gorm:"primaryKey" json:"id"`
	ProjectID string    `gorm:"index;size:64" json:"projectId"`
	UserID    string    `gorm:"index;size:64" json:"userId"`
	Role      string    `gorm:"size:32" json:"role"` // owner / admin / member
	CreatedAt time.Time `json:"createdAt"`
}

func (ProjectMember) TableName() string {
	return "project_members"
}
