/// 底部弹窗组件
/// 作者: 罗耀生
/// 日期: 2026-01-13

import 'package:flutter/material.dart';
import '../app_icon.dart';
import '../../theme/app_tokens.dart';

/// 服务器配置底部弹窗
class ServerConfigSheet extends StatefulWidget {
  final String initialUrl;
  final Function(String)? onSave;

  const ServerConfigSheet({
    super.key,
    this.initialUrl = 'http://192.168.1.100:48080',
    this.onSave,
  });

  @override
  State<ServerConfigSheet> createState() => _ServerConfigSheetState();
}

class _ServerConfigSheetState extends State<ServerConfigSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖动手柄
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.borderSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题
              Stack(
                children: [
                  Center(
                    child: Text(
                      'API 服务器设置',
                      style: AppTextStyles.titleMedium,
                    ),
                  ),
                  // 关闭按钮
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: AppRadius.borderRadiusMD,
                        ),
                        child: const AppIcon(AppIcons.close, size: 18, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // 表单
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API 服务器地址',
                    style: AppTextStyles.labelMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'http://192.168.1.100:48080',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: AppColors.bgSecondary,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.borderRadiusMD,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: AppSpacing.paddingMD,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '请输入服务器地址，如 http://192.168.1.100:48080',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // 保存按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave?.call(_controller.text);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderRadiusMD,
                    ),
                  ),
                  child: const Text('保存配置'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 显示底部弹窗的工具类
class AppBottomSheet {
  /// 显示服务器配置底部弹窗
  static Future<void> showServerConfig({
    required BuildContext context,
    String? initialUrl,
    Function(String)? onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ServerConfigSheet(
        initialUrl: initialUrl ?? 'http://192.168.1.100:48080',
        onSave: onSave,
      ),
    );
  }
}
