/// Open IoT Platform - 品牌 Logo Widget
/// 作者: 罗耀生
/// 版本: 1.0.0
///
/// 使用方式:
/// ```dart
/// BrandLogo()                          // 默认尺寸 (80x80)
/// BrandLogo(size: 48)                  // 自定义尺寸
/// BrandLogo(size: 32, showText: true)  // 带文字
/// ```

import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class BrandLogo extends StatelessWidget {
  /// Logo 尺寸
  final double size;

  /// 是否显示文字
  final bool showText;

  /// 文字样式
  final TextStyle? textStyle;

  const BrandLogo({
    super.key,
    this.size = 80,
    this.showText = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo 图标
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _BrandLogoPainter(),
            size: Size(size, size),
          ),
        ),

        // 可选的文字
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'Open IoT',
            style: textStyle ??
                TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: MinimalTokens.gray900,
                ),
          ),
        ],
      ],
    );
  }
}

/// 品牌 Logo 绘制器
class _BrandLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 背景圆角矩形
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      Radius.circular(size.width * 0.25), // 圆角为宽度的 25%
    );

    final bgPaint = Paint()
      ..color = MinimalTokens.primary
      ..style = PaintingStyle.fill;

    canvas.drawRRect(bgRect, bgPaint);

    // 向上箭头 (白色)
    final arrowPaint = Paint()
      ..color = MinimalTokens.white
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    final arrowSize = size.width * 0.3; // 箭头尺寸
    final arrowTop = size.height * 0.32; // 箭头顶部位置

    // 箭头形状
    arrowPath.moveTo(center.dx, arrowTop); // 顶点
    arrowPath.lineTo(center.dx + arrowSize / 2, arrowTop + arrowSize * 0.6); // 右下
    arrowPath.lineTo(center.dx + arrowSize * 0.15, arrowTop + arrowSize * 0.6); // 右内凹
    arrowPath.lineTo(center.dx + arrowSize * 0.15, arrowTop + arrowSize); // 右下延伸
    arrowPath.lineTo(center.dx - arrowSize * 0.15, arrowTop + arrowSize); // 左下延伸
    arrowPath.lineTo(center.dx - arrowSize * 0.15, arrowTop + arrowSize * 0.6); // 左内凹
    arrowPath.lineTo(center.dx - arrowSize / 2, arrowTop + arrowSize * 0.6); // 左下
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);

    // 底部小方块 (白色圆角)
    final boxSize = size.width * 0.125; // 小方块尺寸
    final boxRadius = boxSize * 0.25; // 小方块圆角
    final boxTop = size.height * 0.67; // 小方块顶部位置

    final boxRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, boxTop + boxSize / 2),
        width: boxSize,
        height: boxSize,
      ),
      Radius.circular(boxRadius),
    );

    canvas.drawRRect(boxRect, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 品牌 Logo 方形按钮样式
class BrandLogoButton extends StatelessWidget {
  /// 按钮尺寸
  final double size;

  /// 点击回调
  final VoidCallback? onTap;

  /// 是否显示涟漪效果
  final bool enableFeedback;

  const BrandLogoButton({
    super.key,
    this.size = 56,
    this.onTap,
    this.enableFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final logo = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrandLogoPainter(),
        size: Size(size, size),
      ),
    );

    if (onTap == null) {
      return logo;
    }

    return InkWell(
      onTap: onTap,
      enableFeedback: enableFeedback,
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: logo,
    );
  }
}
