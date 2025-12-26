/// IoT Platform Flutter SDK
/// 作者: 罗耀生
/// 日期: 2025-12-14
///
/// 提供 IoT 平台的 Flutter 客户端功能:
/// - 用户认证 (登录/注册)
/// - 设备管理 (绑定/解绑/列表)
/// - MQTT 连接 (实时数据/命令下发)
/// - 数据上报与属性查询

library iot_platform_sdk;

// 导出 API 客户端
export 'src/api/api_client.dart';
export 'src/api/auth_api.dart';
export 'src/api/device_api.dart';
export 'src/api/project_api.dart';

// 导出 MQTT 客户端
export 'src/mqtt/mqtt_client.dart';
export 'src/mqtt/mqtt_message.dart';

// 导出数据模型
export 'src/models/user.dart';
export 'src/models/device.dart';
export 'src/models/project.dart';
export 'src/models/product.dart';
export 'src/models/api_response.dart';

// 导出工具类
export 'src/utils/config.dart';
export 'src/utils/logger.dart';

// 导出 SDK 主入口
export 'src/iot_sdk.dart';
