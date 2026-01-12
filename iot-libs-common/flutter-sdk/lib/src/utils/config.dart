/// SDK 配置
/// 作�? 罗耀�?
/// 日期: 2025-12-14
/// 更新: 2025-12-15 - 添加构建时配置支�?

/// 环境配置常量
/// 使用方法: flutter run --dart-define=ENV=natapp
class Env {
  static const String env = String.fromEnvironment('ENV', defaultValue: 'natapp');
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String mqttHost = String.fromEnvironment('MQTT_HOST');
  static const int mqttPort = int.fromEnvironment('MQTT_PORT', defaultValue: 1883);
}

class IoTConfig {
  /// API 服务器地址
  final String apiBaseUrl;

  /// MQTT 服务器地址
  final String mqttHost;

  /// MQTT 端口
  final int mqttPort;

  /// MQTT WebSocket 端口 (用于 Web 平台)
  final int mqttWsPort;

  /// 是否使用 SSL
  final bool useSSL;

  /// 连接超时时间 (�?
  final int connectTimeout;

  /// 接收超时时间 (�?
  final int receiveTimeout;

  /// 是否启用日志
  final bool enableLogging;

  const IoTConfig({
    required this.apiBaseUrl,
    required this.mqttHost,
    this.mqttPort = 1883,
    this.mqttWsPort = 8083,
    this.useSSL = false,
    this.connectTimeout = 30,
    this.receiveTimeout = 30,
    this.enableLogging = true,
  });

  /// 开发环境配置（本机�?
  factory IoTConfig.development() {
    return const IoTConfig(
      apiBaseUrl: 'http://117.50.216.173:48080',
      mqttHost: '117.50.216.173',
      mqttPort: 1883,
      mqttWsPort: 8083,
      enableLogging: true,
    );
  }

  /// 开发环境配置（局域网，用于真机测试）
  factory IoTConfig.developmentLan({
    required String serverIp,
  }) {
    return IoTConfig(
      apiBaseUrl: 'http://$serverIp:48080',
      mqttHost: serverIp,
      mqttPort: 1883,
      mqttWsPort: 8083,
      enableLogging: true,
    );
  }

  /// 生产环境配置
  factory IoTConfig.production({
    required String apiBaseUrl,
    required String mqttHost,
  }) {
    return IoTConfig(
      apiBaseUrl: apiBaseUrl,
      mqttHost: mqttHost,
      mqttPort: 8883,
      mqttWsPort: 8084,
      useSSL: true,
      enableLogging: false,
    );
  }

  /// Natapp 内网穿透配置（真机调试用）
  /// 已弃用：现在使用本地IP直连
  factory IoTConfig.natapp() {
    return const IoTConfig(
      apiBaseUrl: 'http://117.50.216.173:48080',
      mqttHost: '117.50.216.173',
      mqttPort: 1883,
      mqttWsPort: 8083,
      enableLogging: true,
    );
  }

  /// 从环境变量自动选择配置
  /// 使用方法: flutter run --dart-define=ENV=natapp
  /// 支持的环�? development, natapp, production
  /// 也可以通过 --dart-define=API_BASE_URL=xxx 等直接指�?
  factory IoTConfig.fromEnvironment() {
    // 如果指定了具体的 URL，优先使�?
    if (Env.apiBaseUrl.isNotEmpty && Env.mqttHost.isNotEmpty) {
      return IoTConfig(
        apiBaseUrl: Env.apiBaseUrl,
        mqttHost: Env.mqttHost,
        mqttPort: Env.mqttPort,
        enableLogging: true,
      );
    }

    // 根据 ENV 变量选择预设配置
    switch (Env.env) {
      case 'development':
      case 'dev':
        return IoTConfig.development();
      case 'natapp':
        return IoTConfig.natapp();
      case 'production':
      case 'prod':
        // 生产环境必须指定 URL
        throw ArgumentError(
          '生产环境必须通过 --dart-define 指定 API_BASE_URL �?MQTT_HOST',
        );
      default:
        // 默认使用 natapp 配置（方便真机调试）
        return IoTConfig.natapp();
    }
  }
}
