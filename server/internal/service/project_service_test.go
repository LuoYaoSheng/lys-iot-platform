package service

import (
	"testing"
	"time"

	"iot-platform-core/internal/model"
)

func TestProjectServiceCRUDAndDeleteGuard(t *testing.T) {
	db := newTestDB(t)
	svc := newProjectServiceForTest(db)

	createResp, err := svc.CreateProject("user_owner", &CreateProjectRequest{
		Name:        "Home Lab",
		Description: "primary test project",
	})
	if err != nil {
		t.Fatalf("CreateProject returned error: %v", err)
	}

	project, err := svc.GetProject("user_owner", createResp.ProjectID)
	if err != nil {
		t.Fatalf("GetProject returned error: %v", err)
	}
	if project.Name != "Home Lab" {
		t.Fatalf("unexpected project: %+v", project)
	}

	if _, err := svc.GetProject("user_other", createResp.ProjectID); err == nil || err.Error() != "forbidden" {
		t.Fatalf("expected forbidden for non-owner, got %v", err)
	}

	updated, err := svc.UpdateProject("user_owner", createResp.ProjectID, &UpdateProjectRequest{
		Name:        "Updated Lab",
		Description: "updated description",
	})
	if err != nil {
		t.Fatalf("UpdateProject returned error: %v", err)
	}
	if updated.Name != "Updated Lab" || updated.Description != "updated description" {
		t.Fatalf("unexpected updated project: %+v", updated)
	}

	if err := db.Create(&model.Device{
		DeviceID:   "dev_project_guard",
		DeviceSN:   "SN-PROJ-1",
		ProductKey: "switch_v1",
		ProjectID:  createResp.ProjectID,
		Status:     model.DeviceStatusOffline,
	}).Error; err != nil {
		t.Fatalf("seed project device: %v", err)
	}

	if err := svc.DeleteProject("user_owner", createResp.ProjectID); err == nil || err.Error() != "project_has_devices" {
		t.Fatalf("expected project_has_devices, got %v", err)
	}
}

func TestToProjectResponse(t *testing.T) {
	t.Parallel()

	svc := &ProjectService{}
	project := &model.Project{
		ProjectID:   "proj_12345678",
		Name:        "Home Lab",
		Description: "Internal test project",
		Status:      model.ProjectStatusActive,
		CreatedAt:   time.Date(2025, 12, 13, 8, 30, 0, 0, time.UTC),
		UpdatedAt:   time.Date(2025, 12, 14, 9, 45, 0, 0, time.UTC),
	}

	resp := svc.toProjectResponse(project, 3)

	if resp.ProjectID != "proj_12345678" || resp.Name != "Home Lab" {
		t.Fatalf("unexpected project identity fields: %+v", resp)
	}
	if resp.DeviceCount != 3 {
		t.Fatalf("expected device count 3, got %d", resp.DeviceCount)
	}
	if resp.CreatedAt != "2025-12-13 08:30:00" || resp.UpdatedAt != "2025-12-14 09:45:00" {
		t.Fatalf("unexpected time formatting: %+v", resp)
	}
}
