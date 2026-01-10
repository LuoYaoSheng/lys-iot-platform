# ========================================
# IoT Platform Core - Multi-stage Dockerfile
# 作者: 罗耀生
# 日期: 2025-12-16
# ========================================

# ==================== 构建阶段 ====================
FROM golang:1.24-alpine AS builder

# 安装编译依赖
RUN apk add --no-cache git gcc musl-dev

# 设置工作目录
WORKDIR /build

# 复制依赖文件（利用Docker缓存层）
COPY go.mod go.sum ./

# 设置 Go 代理，使用本地 toolchain
ENV GOTOOLCHAIN=auto
ENV GOPROXY=https://goproxy.cn,direct

RUN go mod download

# 复制源码
COPY . .

# 编译二进制文件
# CGO_ENABLED=0: 静态编译，无外部依赖
# -ldflags="-s -w": 去除调试信息，减小体积
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-s -w" \
    -o iot-platform-core \
    cmd/server/main.go

# ==================== 运行阶段 ====================
FROM alpine:latest

# 安装运行时依赖
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    wget

# 设置时区
ENV TZ=Asia/Shanghai

# 创建非root用户
RUN addgroup -g 1000 iotuser && \
    adduser -D -u 1000 -G iotuser iotuser

# 设置工作目录
WORKDIR /app

# 从构建阶段复制二进制文件
COPY --from=builder /build/iot-platform-core .

# 修改权限
RUN chown -R iotuser:iotuser /app

# 切换到非root用户
USER iotuser

# 暴露端口
EXPOSE 48080

# 健康检查
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:48080/health || exit 1

# 启动服务
CMD ["./iot-platform-core"]
