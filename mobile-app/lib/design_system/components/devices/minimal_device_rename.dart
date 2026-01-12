/// 设备重命名功能组件
/// 作者: 罗耀生
/// 版本: 3.1.0
///
/// 提供设备重命名弹窗和相关功能

library;

import 'package:flutter/material.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';

/// ========== 带重命名功能的设备控制面板底部弹窗 ==========
class MinimalDeviceControlSheetWithRename extends StatefulWidget {
  const MinimalDeviceControlSheetWithRename({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isOnline,
    required this.child,
    this.onClose,
    this.onRename,
    this.deviceId,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isOnline;
  final Widget child;
  final VoidCallback? onClose;
  final ValueChanged<String>? onRename;
  final String? deviceId;

  @override
  State<MinimalDeviceControlSheetWithRename> createState() =>
      _MinimalDeviceControlSheetWithRenameState();
}

class _MinimalDeviceControlSheetWithRenameState
    extends State<MinimalDeviceControlSheetWithRename> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: MinimalTokens.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(MinimalSpacing.md),
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 12),
        decoration: BoxDecoration(
          color: MinimalTokens.gray200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: MinimalTokens.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.isOnline
                            ? MinimalTokens.success
                            : MinimalTokens.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isOnline ? '在线' : '离线',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isOnline
                            ? MinimalTokens.success
                            : MinimalTokens.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildMenuButton(),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'rename') {
          _showRenameDialog();
        } else if (value == 'close') {
          widget.onClose?.call();
          Navigator.pop(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20),
              SizedBox(width: 12),
              Text('重命名'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'close',
          child: Row(
            children: [
              Icon(Icons.close, size: 20),
              SizedBox(width: 12),
              Text('关闭'),
            ],
          ),
        ),
      ],
    );
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: widget.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名设备'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: '请输入设备名称',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            final newName = value.trim();
            if (newName.isNotEmpty) {
              Navigator.pop(context);
              widget.onRename?.call(newName);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(context);
                widget.onRename?.call(newName);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
