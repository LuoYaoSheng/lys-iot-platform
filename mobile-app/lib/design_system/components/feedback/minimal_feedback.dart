/// Minimal Feedback - 反馈组件
/// 作者: 罗耀生
/// 版本: 3.0.0
///
/// 包含：Toast、Dialog、确认对话框

library;

import 'package:flutter/material.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';

/// ========== Toast 提示 ==========
/// 显示简短的消息提示
class MinimalToast {
  /// 显示成功提示
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: MinimalTokens.success,
      duration: duration,
    );
  }

  /// 显示错误提示
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: MinimalTokens.error,
      duration: duration,
    );
  }

  /// 显示警告提示
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: MinimalTokens.warning,
      duration: duration,
    );
  }

  /// 显示普通提示
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: MinimalTokens.gray700,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Duration duration,
  }) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: MinimalBorderRadius.md,
          ),
          margin: const EdgeInsets.all(MinimalSpacing.md),
        ),
      );
    }
  }
}

/// ========== 对话框 ==========
/// 简单的信息对话框
class MinimalDialog {
  /// 显示确认对话框
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = '确定',
    String cancelText = '取消',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: MinimalBorderRadius.lg,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDangerous
                ? FilledButton.styleFrom(
                    backgroundColor: MinimalTokens.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// 显示简单信息对话框
  static void showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = '确定',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: MinimalBorderRadius.lg,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// 显示加载对话框
  static void showLoading({
    required BuildContext context,
    String message = '加载中...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: MinimalBorderRadius.lg,
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: MinimalSpacing.md),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// 隐藏对话框
  static void hide(BuildContext context) {
    Navigator.pop(context);
  }
}

/// ========== 底部面板 ==========
/// 可拖动的底部面板
class MinimalBottomSheet {
  /// 显示底部面板
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    double initialChildSize = 0.6,
    double minChildSize = 0.4,
    double maxChildSize = 0.9,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        builder: (context, scrollController) => builder(context),
      ),
    );
  }
}
