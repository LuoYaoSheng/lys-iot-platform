// 项目服务层
// 作者: 罗耀生
// 日期: 2025-12-14

package service

import (
	"errors"

	"iot-platform-core/internal/model"
	"iot-platform-core/internal/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ProjectService 项目服务
type ProjectService struct {
	projectRepo *repository.ProjectRepository
	deviceRepo  *repository.DeviceRepository
}

func NewProjectService(projectRepo *repository.ProjectRepository, deviceRepo *repository.DeviceRepository) *ProjectService {
	return &ProjectService{
		projectRepo: projectRepo,
		deviceRepo:  deviceRepo,
	}
}

// ========== 请求/响应结构 ==========

// CreateProjectRequest 创建项目请求
type CreateProjectRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
}

// UpdateProjectRequest 更新项目请求
type UpdateProjectRequest struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

// ProjectResponse 项目响应
type ProjectResponse struct {
	ProjectID   string `json:"projectId"`
	Name        string `json:"name"`
	Description string `json:"description"`
	DeviceCount int64  `json:"deviceCount"`
	Status      int    `json:"status"`
	CreatedAt   string `json:"createdAt"`
	UpdatedAt   string `json:"updatedAt"`
}

// ProjectListResponse 项目列表响应
type ProjectListResponse struct {
	Total    int64             `json:"total"`
	Page     int               `json:"page"`
	Size     int               `json:"size"`
	Projects []ProjectResponse `json:"projects"`
}

// ========== 服务方法 ==========

// CreateProject 创建项目
func (s *ProjectService) CreateProject(userID string, req *CreateProjectRequest) (*ProjectResponse, error) {
	// 生成项目ID
	projectID := "proj_" + uuid.New().String()[:8]

	project := &model.Project{
		ProjectID:   projectID,
		UserID:      userID,
		Name:        req.Name,
		Description: req.Description,
		Status:      model.ProjectStatusActive,
	}

	if err := s.projectRepo.Create(project); err != nil {
		return nil, err
	}

	return s.toProjectResponse(project, 0), nil
}

// GetProject 获取项目详情
func (s *ProjectService) GetProject(userID, projectID string) (*ProjectResponse, error) {
	project, err := s.projectRepo.FindByProjectID(projectID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("project_not_found")
		}
		return nil, err
	}

	// 检查权限
	if project.UserID != userID {
		return nil, errors.New("forbidden")
	}

	// 获取设备数量
	deviceCount, _ := s.projectRepo.CountDevices(projectID)

	return s.toProjectResponse(project, deviceCount), nil
}

// GetProjectList 获取项目列表
func (s *ProjectService) GetProjectList(userID string, page, size int) (*ProjectListResponse, error) {
	if page < 1 {
		page = 1
	}
	if size < 1 || size > 100 {
		size = 20
	}

	offset := (page - 1) * size
	projects, total, err := s.projectRepo.FindByUserID(userID, nil, size, offset)
	if err != nil {
		return nil, err
	}

	// 构建响应
	projectResponses := make([]ProjectResponse, len(projects))
	for i, p := range projects {
		deviceCount, _ := s.projectRepo.CountDevices(p.ProjectID)
		projectResponses[i] = *s.toProjectResponse(&p, deviceCount)
	}

	return &ProjectListResponse{
		Total:    total,
		Page:     page,
		Size:     size,
		Projects: projectResponses,
	}, nil
}

// UpdateProject 更新项目
func (s *ProjectService) UpdateProject(userID, projectID string, req *UpdateProjectRequest) (*ProjectResponse, error) {
	project, err := s.projectRepo.FindByProjectID(projectID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("project_not_found")
		}
		return nil, err
	}

	// 检查权限
	if project.UserID != userID {
		return nil, errors.New("forbidden")
	}

	// 更新字段
	if req.Name != "" {
		project.Name = req.Name
	}
	if req.Description != "" {
		project.Description = req.Description
	}

	if err := s.projectRepo.Update(project); err != nil {
		return nil, err
	}

	deviceCount, _ := s.projectRepo.CountDevices(projectID)
	return s.toProjectResponse(project, deviceCount), nil
}

// DeleteProject 删除项目
func (s *ProjectService) DeleteProject(userID, projectID string) error {
	project, err := s.projectRepo.FindByProjectID(projectID)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("project_not_found")
		}
		return err
	}

	// 检查权限
	if project.UserID != userID {
		return errors.New("forbidden")
	}

	// 检查是否有设备
	deviceCount, _ := s.projectRepo.CountDevices(projectID)
	if deviceCount > 0 {
		return errors.New("project_has_devices")
	}

	return s.projectRepo.Delete(projectID)
}

// toProjectResponse 转换为响应结构
func (s *ProjectService) toProjectResponse(project *model.Project, deviceCount int64) *ProjectResponse {
	return &ProjectResponse{
		ProjectID:   project.ProjectID,
		Name:        project.Name,
		Description: project.Description,
		DeviceCount: deviceCount,
		Status:      int(project.Status),
		CreatedAt:   project.CreatedAt.Format("2006-01-02 15:04:05"),
		UpdatedAt:   project.UpdatedAt.Format("2006-01-02 15:04:05"),
	}
}
