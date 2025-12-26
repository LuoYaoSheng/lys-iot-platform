// 项目仓库层
// 作者: 罗耀生
// 日期: 2025-12-13

package repository

import (
	"iot-platform-core/internal/model"

	"gorm.io/gorm"
)

// ProjectRepository 项目仓库
type ProjectRepository struct {
	db *gorm.DB
}

func NewProjectRepository(db *gorm.DB) *ProjectRepository {
	return &ProjectRepository{db: db}
}

// FindByProjectID 根据项目ID查找
func (r *ProjectRepository) FindByProjectID(projectID string) (*model.Project, error) {
	var project model.Project
	err := r.db.Where("project_id = ?", projectID).First(&project).Error
	if err != nil {
		return nil, err
	}
	return &project, nil
}

// FindByUserID 根据用户ID查找项目列表
func (r *ProjectRepository) FindByUserID(userID string, status *model.ProjectStatus, limit, offset int) ([]model.Project, int64, error) {
	var projects []model.Project
	var total int64

	query := r.db.Model(&model.Project{}).Where("user_id = ?", userID)

	if status != nil {
		query = query.Where("status = ?", *status)
	}

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	if err := query.Order("created_at DESC").Limit(limit).Offset(offset).Find(&projects).Error; err != nil {
		return nil, 0, err
	}

	return projects, total, nil
}

// Create 创建项目
func (r *ProjectRepository) Create(project *model.Project) error {
	return r.db.Create(project).Error
}

// Update 更新项目
func (r *ProjectRepository) Update(project *model.Project) error {
	return r.db.Save(project).Error
}

// Delete 删除项目
func (r *ProjectRepository) Delete(projectID string) error {
	return r.db.Where("project_id = ?", projectID).Delete(&model.Project{}).Error
}

// CountDevices 统计项目下的设备数量
func (r *ProjectRepository) CountDevices(projectID string) (int64, error) {
	var count int64
	// 假设 Device 表有 project_id 字段
	err := r.db.Model(&model.Device{}).Where("project_id = ?", projectID).Count(&count).Error
	return count, err
}
