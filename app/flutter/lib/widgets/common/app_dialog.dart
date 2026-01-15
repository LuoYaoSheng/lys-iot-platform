import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';

/// 对话框类型
enum AppDialogType {
  /// 警告对话框
  alert,
  /// 确认对话框
  confirm,
  /// 输入对话框
  prompt,
}

/// 统一对话框组件
class AppDialog {
  /// 显示警告对话框
  static Future<void> alert({
    required BuildContext context,
    required String title,
    String? content,
    String confirmText = '确定',
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLG,
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: content != null
            ? Text(
                content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )
            : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// 显示确认对话框
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? content,
    String confirmText = '确定',
    String cancelText = '取消',
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLG,
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: content != null
            ? Text(
                content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )
            : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// 显示输入对话框
  static Future<String?> prompt({
    required BuildContext context,
    required String title,
    String? hint,
    String? content,
    String confirmText = '确定',
    String cancelText = '取消',
    bool barrierDismissible = true,
    int maxLines = 1,
  }) {
    final controller = TextEditingController(text: content);

    return showDialog<String>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusLG,
          ),
          title: Text(title, textAlign: TextAlign.center),
          content: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: AppRadius.borderRadiusMD,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  /// 显示加载对话框
  static void showLoading({
    required BuildContext context,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AppLoadingDialog(message: message),
    );
  }

  /// 隐藏对话框
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// 加载对话框
class _AppLoadingDialog extends StatelessWidget {
  final String? message;

  const _AppLoadingDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: AppSpacing.paddingLG,
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: AppRadius.borderRadiusLG,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
