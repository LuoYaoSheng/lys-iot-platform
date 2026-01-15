import 'package:flutter/material.dart';
import '../app_icon.dart';
import 'dart:async';
import '../../theme/app_tokens.dart';

/// Toast 类型
enum AppToastType {
  /// 成功
  success,
  /// 错误
  error,
  /// 警告
  warning,
  /// 信息
  info,
  /// 加载中
  loading,
}

/// Toast 位置
enum AppToastPosition {
  /// 顶部
  top,
  /// 居中
  center,
  /// 底部
  bottom,
}

/// 统一 Toast 组件
class AppToast {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  /// 显示 Toast
  static void show(
    BuildContext context,
    String message, {
    AppToastType type = AppToastType.info,
    AppToastPosition position = AppToastPosition.center,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    // 移除已有的 Toast
    remove();

    // 获取 Overlay
    final OverlayState overlay = Overlay.of(context);

    // 创建新的 Toast
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        position: position,
      ),
    );

    // 添加到 Overlay
    overlay.insert(_overlayEntry!);

    // 自动移除
    _timer = Timer(duration, remove);
  }

  /// 显示成功提示
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    show(context, message, type: AppToastType.success, duration: duration);
  }

  /// 显示错误提示
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    show(context, message, type: AppToastType.error, duration: duration);
  }

  /// 显示警告提示
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    show(context, message, type: AppToastType.warning, duration: duration);
  }

  /// 显示加载提示
  static void loading(BuildContext context, String message) {
    show(
      context,
      message,
      type: AppToastType.loading,
      duration: const Duration(days: 1),
    );
  }

  /// 移除 Toast
  static void remove() {
    _timer?.cancel();
    _timer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// Toast 组件
class _ToastWidget extends StatelessWidget {
  final String message;
  final AppToastType type;
  final AppToastPosition position;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Positioned(
      top: _getTopPosition(screenSize.height),
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: AppColors.overlay,
              borderRadius: AppRadius.borderRadiusLG,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._getIconIfNeeded(),
                Flexible(
                  child: Text(
                    message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getTopPosition(double screenHeight) {
    switch (position) {
      case AppToastPosition.top:
        return screenHeight * 0.15;
      case AppToastPosition.center:
        return screenHeight * 0.4;
      case AppToastPosition.bottom:
        return screenHeight * 0.7;
    }
  }

  List<Widget> _getIconIfNeeded() {
    switch (type) {
      case AppToastType.success:
        return [
          const AppIcon(AppIcons.checkCircle, size: 20, color: AppColors.success),
          const SizedBox(width: 12),
        ];
      case AppToastType.error:
        return [
          const AppIcon(AppIcons.error, size: 20, color: AppColors.error),
          const SizedBox(width: 12),
        ];
      case AppToastType.warning:
        return [
          const AppIcon(AppIcons.warning, size: 20, color: AppColors.warning),
          const SizedBox(width: 12),
        ];
      case AppToastType.loading:
        return [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
        ];
      case AppToastType.info:
        return [];
    }
  }
}
