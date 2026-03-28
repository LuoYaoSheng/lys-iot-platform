# IoT Platform Core - Makefile
# 作者: 罗耀生
# 日期: 2025-12-13

.PHONY: help build run docker-up docker-down docker-logs test clean dev-infra-up dev-infra-down run-device-sim

# 默认目标
help:
	@echo "IoT Platform Core - Available commands:"
	@echo "  make build       - Build the Go binary"
	@echo "  make run         - Run locally (requires MySQL/Redis)"
	@echo "  make docker-up   - Start all services with Docker Compose"
	@echo "  make docker-down - Stop all services"
	@echo "  make docker-logs - View service logs"
	@echo "  make test        - Run tests"
	@echo "  make dev-infra-up   - Start local MySQL/Redis/EMQX only"
	@echo "  make dev-infra-down - Stop local MySQL/Redis/EMQX only"
	@echo "  make run-device-sim - Activate and run a local simulated device"
	@echo "  make clean       - Clean build artifacts"

# 构建
build:
	go build -o bin/iot-core ./cmd/server

# 本地运行
run:
	go run ./cmd/server

# Docker 启动
docker-up:
	docker-compose up -d --build

# Docker 停止
docker-down:
	docker-compose down

# Docker 日志
docker-logs:
	docker-compose logs -f

# 本地开发基础设施
dev-infra-up:
	docker-compose -f docker-compose.dev.yml up -d

dev-infra-down:
	docker-compose -f docker-compose.dev.yml down

# 测试
test:
	go test -v ./...

# 启动本地模拟设备
run-device-sim:
	bash ./scripts/run-device-sim.sh

# 清理
clean:
	rm -rf bin/
	docker-compose down -v
