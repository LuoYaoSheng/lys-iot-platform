/// Minimal Text Field - 文本输入框
/// 作者: 罗耀生
/// 版本: 3.0.0
///
/// 遵循 MINIMAL_UI.md 规范:
/// - 高度: 44px
/// - 圆角: 8px
/// - 聚焦边框: 2px #007AFF

library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/color_tokens.dart';
import '../../tokens/spacing_tokens.dart';
import '../../tokens/radius_tokens.dart';

/// 标准文本输入框
class MinimalTextField extends StatefulWidget {
  const MinimalTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.isEnabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final bool isEnabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? maxLength;

  @override
  State<MinimalTextField> createState() => _MinimalTextFieldState();
}

class _MinimalTextFieldState extends State<MinimalTextField> {
  bool _obscureText = false;
  late bool _hasError;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _hasError = widget.errorText != null;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(MinimalTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _hasError = widget.errorText != null;
    if (widget.obscureText != oldWidget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      if (widget.validator != null) {
        _hasError = widget.validator!(widget.controller.text) != null;
      }
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveError = _hasError ? widget.errorText : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标签
        Text(
          widget.label,
          style: TextStyle(
            fontSize: MinimalTokens.fontSizeBodySmall,
            fontWeight: MinimalTokens.fontWeightMedium,
            color: effectiveError != null
                ? MinimalTokens.error
                : MinimalTokens.gray700,
          ),
        ),
        const SizedBox(height: MinimalSpacing.xs),
        // 输入框
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          enabled: widget.isEnabled,
          onTap: widget.onTap,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          validator: widget.validator,
          style: TextStyle(
            fontSize: MinimalTokens.fontSizeBody,
            color: widget.isEnabled ? MinimalTokens.gray900 : MinimalTokens.gray500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: MinimalTokens.gray500,
              fontSize: MinimalTokens.fontSizeBody,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: MinimalTokens.gray500, size: 20)
                : null,
            suffixIcon: _buildSuffixIcon(),
            errorText: effectiveError,
            filled: true,
            fillColor: widget.isEnabled ? MinimalTokens.gray50 : MinimalTokens.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MinimalRadius.md),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MinimalRadius.md),
              borderSide: const BorderSide(color: MinimalTokens.gray200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MinimalRadius.md),
              borderSide: const BorderSide(color: MinimalTokens.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MinimalRadius.md),
              borderSide: const BorderSide(color: MinimalTokens.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MinimalRadius.md),
              borderSide: const BorderSide(color: MinimalTokens.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: MinimalSpacing.md,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: MinimalTokens.gray500,
          size: 20,
        ),
        onPressed: widget.isEnabled ? _toggleObscureText : null,
      );
    }
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon, color: MinimalTokens.gray500, size: 20),
        onPressed: widget.isEnabled ? widget.onSuffixIconPressed : null,
      );
    }
    return null;
  }
}
