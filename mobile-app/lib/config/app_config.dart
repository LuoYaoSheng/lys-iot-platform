/// 应用配置
/// 作者: 罗耀生
/// 版本: 1.0.0
///
/// 统一管理应用版本号等全局配置

class AppConfig {
  /// 应用版本号（需与 pubspec.yaml 保持一致）
  static const String appVersion = '1.0.0';

  /// 应用构建号
  static const String buildNumber = '1';

  /// 完整版本号（版本+构建号）
  static String get fullVersion => '$appVersion+$buildNumber';

  /// 显示版本号（v前缀）
  static String get displayVersion => 'v$appVersion';

  /// 应用名称
  static const String appName = 'Open IoT Platform';

  /// 作者信息
  static const String author = '罗耀生';
  static const String email = '121912336@qq.com';

  /// 网址
  static const String website = 'https://i2kai.com';
  static const String projectWebsite = 'https://open.iot.i2kai.com';
  static const String gitUrl = 'https://github.com/i2kai/Open-IoT-Platform';
}
