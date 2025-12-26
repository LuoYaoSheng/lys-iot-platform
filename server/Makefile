# IoT Platform Core - Makefile
# 作者: 罗耀生
# 日期: 2025-12-13

.PHONY: help build run docker-up docker-down docker-logs test clean

# 默认目标
help:
	@echo "IoT Platform Core - Available commands:"
	@echo "  make build       - Build the Go binary"
	@echo "  make run         - Run locally (requires MySQL/Redis)"
	@echo "  make docker-up   - Start all services with Docker Compose"
	@echo "  make docker-down - Stop all services"
	@echo "  make docker-logs - View service logs"
	@echo "  make test        - Run tests"
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

# 测试
test:
	go test -v ./...

# 清理
clean:
	rm -rf bin/
	docker-compose down -v
