import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_tokens.dart';

/// 输入框尺寸
enum AppInputSize {
  /// 小号 (32px)
  small,
  /// 中号 (40px)
  medium,
  /// 大号 (48px)
  large,
}

/// 统一输入框组件
class AppInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? value;
  final String? errorText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final AppInputSize size;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.size = AppInputSize.medium,
    this.textInputAction,
    this.focusNode,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.value);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(AppInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != _controller.text) {
      _controller.text = widget.value!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  /// 获取输入框高度
  double get _height {
    switch (widget.size) {
      case AppInputSize.small:
        return 32;
      case AppInputSize.medium:
        return 40;
      case AppInputSize.large:
        return 48;
    }
  }

  /// 获取内容内边距
  EdgeInsets get _contentPadding {
    switch (widget.size) {
      case AppInputSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case AppInputSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 10);
      case AppInputSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  /// 获取字体样式
  TextStyle get _textStyle {
    switch (widget.size) {
      case AppInputSize.small:
        return AppTextStyles.bodySmall;
      case AppInputSize.medium:
        return AppTextStyles.bodyMedium;
      case AppInputSize.large:
        return AppTextStyles.bodyLarge;
    }
  }

  /// 获取边框颜色
  Color get _borderColor {
    if (widget.errorText != null) {
      return AppColors.error;
    }
    if (_isFocused) {
      return AppColors.borderFocus;
    }
    return AppColors.borderPrimary;
  }

  /// 获取背景颜色
  Color get _backgroundColor {
    if (!widget.enabled) {
      return AppColors.bgDisabled;
    }
    return AppColors.bgPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: widget.errorText != null
                  ? AppColors.error
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: (widget.maxLines ?? 1) > 1 ? null : _height,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: AppRadius.borderRadiusMD,
            border: Border.all(
              color: _borderColor,
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            style: _textStyle.copyWith(
              color: widget.enabled
                  ? AppColors.textPrimary
                  : AppColors.textDisabled,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: _textStyle.copyWith(
                color: AppColors.textTertiary,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: _contentPadding,
                      child: widget.prefixIcon,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? Padding(
                      padding: _contentPadding,
                      child: widget.suffixIcon,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              contentPadding: _contentPadding,
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              counterText: '',
            ),
          ),
        ),
        if (widget.errorText != null || widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText ?? widget.helperText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: widget.errorText != null
                  ? AppColors.error
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}
