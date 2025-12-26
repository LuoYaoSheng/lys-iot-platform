/// SDK 日志工具
/// 作者: 罗耀生
/// 日期: 2025-12-14

import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

class IoTLogger {
  static bool _enabled = true;
  static LogLevel _level = LogLevel.debug;

  /// 设置是否启用日志
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// 设置日志级别
  static void setLevel(LogLevel level) {
    _level = level;
  }

  static void debug(String message, [String? tag]) {
    _log(LogLevel.debug, message, tag);
  }

  static void info(String message, [String? tag]) {
    _log(LogLevel.info, message, tag);
  }

  static void warning(String message, [String? tag]) {
    _log(LogLevel.warning, message, tag);
  }

  static void error(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, tag);
    if (error != null) {
      developer.log(
        error.toString(),
        name: 'IoT-SDK',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void _log(LogLevel level, String message, String? tag) {
    if (!_enabled) return;
    if (level.index < _level.index) return;

    final prefix = _getLevelPrefix(level);
    final tagStr = tag != null ? '[$tag] ' : '';
    final logMessage = '$prefix $tagStr$message';

    developer.log(logMessage, name: 'IoT-SDK');
  }

  static String _getLevelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARN]';
      case LogLevel.error:
        return '[ERROR]';
    }
  }
}
