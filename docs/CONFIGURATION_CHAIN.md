# 配置链路说明

## 目标

这份文档只说明一件事：当前仓库里 API、MQTT、数据库和 EMQX 的配置是如何从默认值一路传递到 Flutter App、Go 后端和 Docker Compose 的。

重点是“优先级”和“真实生效位置”，避免只看某一个文件就误判系统是否已经支持自定义。

## 一、后端配置链路（Go）

后端入口配置在 `server/internal/config/config.go`。

读取优先级：

1. 运行时环境变量
2. `server/.env`
3. 代码默认值

当前默认端口：

- API: `48080`
- MySQL: `48306`
- Redis: `48379`
- MQTT: `48883`
- EMQX API: `http://localhost:48884`

注意：

- `MQTT_BROKER` 是后端自己连 MQTT 用的地址。
- `MQTT_BROKER_EXTERNAL` 是设备拿到后用于外连的地址。
- 这两个值不是同一个概念。

## 二、Docker Compose 配置链路

主文件是 `server/docker-compose.yml`。

宿主机端口映射：

- `48080 -> 48080` 后端 API
- `48306 -> 3306` MySQL
- `48379 -> 6379` Redis
- `48883 -> 1883` MQTT
- `48803 -> 8083` MQTT WebSocket
- `48884 -> 18083` EMQX Dashboard / API

容器内通信仍使用容器端口：

- MySQL: `3306`
- Redis: `6379`
- MQTT: `1883`
- EMQX API: `http://emqx:18083`

所以不要把“宿主机映射端口”和“容器内服务端口”混为一谈。

## 三、Flutter SDK 配置链路

SDK 配置在 `iot-libs-common/flutter-sdk/lib/src/utils/config.dart`。

SDK 有三层来源：

1. `--dart-define`
2. SDK 预设环境（development / natapp / production）
3. `IoTConfig(...)` 显式传入

当前开发默认值：

- API: `http://localhost:48080`
- MQTT Host: `localhost`
- MQTT Port: `48883`
- MQTT WS Port: `48803`

## 四、Flutter App 配置链路

App 启动逻辑在 `mobile-app/lib/main.dart`。

真实优先级是：

1. `SharedPreferences` 里的本地配置
   - `custom_api_url`
   - `custom_mqtt_host`
   - `custom_mqtt_port`
2. SDK 的 `IoTConfig.fromEnvironment()`

这说明 Flutter 端不是只能吃默认值，启动时已经优先支持本地覆盖。

## 五、登录页配置弹窗的真实行为

配置 UI 在 `mobile-app/lib/pages/login_page.dart`。

当前页面只让用户输入 `API URL`，保存时会：

1. 存 `custom_api_url`
2. 从 `API URL` 解析 host，写入 `custom_mqtt_host`
3. 把 `custom_mqtt_port` 写成默认端口 `48883`

所以当前结论是：

- 自定义 API 地址：已支持
- 自定义 MQTT Host：已支持，但通常由 API URL 推导
- 自定义 MQTT Port：底层支持，但当前 UI 没有单独输入项，保存时会写默认值

## 六、安卓模拟器怎么访问本机

Android Emulator 里访问宿主机，不能用 `localhost`，要用 `10.0.2.2`。

本地联调建议：

- API URL: `http://10.0.2.2:48080`
- MQTT Host: `10.0.2.2`
- MQTT Port: `48883`

如果只通过当前登录页配置弹窗填写 `API URL`，它会自动把 MQTT Host 推导成 `10.0.2.2`，这点是兼容的。

## 七、当前最重要的判断

这个仓库当前已经具备“默认值 + 可覆盖”的完整能力，但覆盖入口不是完全对称的：

- Go 侧：环境变量能力完整
- Compose 侧：宿主机映射和容器内地址已分离
- Flutter SDK：环境变量和显式传入都支持
- Flutter App：本地持久化支持完整
- Flutter UI：目前主要暴露了 API URL，而不是完整的 MQTT Host/Port 表单

因此，后续讨论配置问题时，应该先分清是：

1. 底层不支持
2. 启动链路未接上
3. UI 没暴露对应配置项

这三类问题不是一回事。
