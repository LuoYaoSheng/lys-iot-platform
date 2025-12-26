// 项目处理器
// 作者: 罗耀生
// 日期: 2025-12-14

package handler

import (
	"strconv"

	"iot-platform-core/internal/service"
	"iot-platform-core/pkg/response"

	"github.com/gin-gonic/gin"
)

// ProjectHandler 项目处理器
type ProjectHandler struct {
	projectService *service.ProjectService
}

func NewProjectHandler(projectService *service.ProjectService) *ProjectHandler {
	return &ProjectHandler{
		projectService: projectService,
	}
}

// CreateProject 创建项目
// POST /api/v1/projects
func (h *ProjectHandler) CreateProject(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		response.Unauthorized(c, "unauthorized")
		return
	}

	var req service.CreateProjectRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "invalid_request: "+err.Error())
		return
	}

	project, err := h.projectService.CreateProject(userID, &req)
	if err != nil {
		response.InternalError(c, err.Error())
		return
	}

	response.Created(c, project)
}

// GetProjectList 获取项目列表
// GET /api/v1/projects
func (h *ProjectHandler) GetProjectList(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		response.Unauthorized(c, "unauthorized")
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	size, _ := strconv.Atoi(c.DefaultQuery("size", "20"))

	result, err := h.projectService.GetProjectList(userID, page, size)
	if err != nil {
		response.InternalError(c, err.Error())
		return
	}

	response.Success(c, result)
}

// GetProject 获取项目详情
// GET /api/v1/projects/:projectId
func (h *ProjectHandler) GetProject(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		response.Unauthorized(c, "unauthorized")
		return
	}

	projectID := c.Param("projectId")
	if projectID == "" {
		response.BadRequest(c, "project_id_required")
		return
	}

	project, err := h.projectService.GetProject(userID, projectID)
	if err != nil {
		switch err.Error() {
		case "project_not_found":
			response.NotFound(c, "project_not_found")
		case "forbidden":
			response.Forbidden(c, "forbidden")
		default:
			response.InternalError(c, err.Error())
		}
		return
	}

	response.Success(c, project)
}

// UpdateProject 更新项目
// PUT /api/v1/projects/:projectId
func (h *ProjectHandler) UpdateProject(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		response.Unauthorized(c, "unauthorized")
		return
	}

	projectID := c.Param("projectId")
	if projectID == "" {
		response.BadRequest(c, "project_id_required")
		return
	}

	var req service.UpdateProjectRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "invalid_request: "+err.Error())
		return
	}

	project, err := h.projectService.UpdateProject(userID, projectID, &req)
	if err != nil {
		switch err.Error() {
		case "project_not_found":
			response.NotFound(c, "project_not_found")
		case "forbidden":
			response.Forbidden(c, "forbidden")
		default:
			response.InternalError(c, err.Error())
		}
		return
	}

	response.Success(c, project)
}

// DeleteProject 删除项目
// DELETE /api/v1/projects/:projectId
func (h *ProjectHandler) DeleteProject(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		response.Unauthorized(c, "unauthorized")
		return
	}

	projectID := c.Param("projectId")
	if projectID == "" {
		response.BadRequest(c, "project_id_required")
		return
	}

	err := h.projectService.DeleteProject(userID, projectID)
	if err != nil {
		switch err.Error() {
		case "project_not_found":
			response.NotFound(c, "project_not_found")
		case "forbidden":
			response.Forbidden(c, "forbidden")
		case "project_has_devices":
			response.Conflict(c, "project_has_devices", nil)
		default:
			response.InternalError(c, err.Error())
		}
		return
	}

	response.Success(c, gin.H{"message": "project_deleted"})
}
