/// Open IoT Platform - Design System
/// 作者: 罗耀生
/// 版本: 3.0.0
/// 设计风格: 简洁、单色、专业
///
/// 遵循 design-system/MINIMAL_UI.md 规范
///
/// 使用示例:
/// ```dart
/// import 'package:open_iot_app/design_system/design_system.dart';
///
/// // 使用按钮
/// MinimalPrimaryButton(
///   label: '登录',
///   onPressed: () {},
/// )
///
/// // 使用卡片
/// MinimalCard(
///   child: Text('内容'),
/// )
///
/// // 使用Toast
/// MinimalToast.showSuccess(context, '操作成功');
///
/// // 使用令牌
/// Container(
///   color: MinimalTokens.primary,
///   padding: MinimalEdgeInsets.md,
/// )
/// ```

library;

// ==================== 设计令牌 ====================
export 'tokens/color_tokens.dart';
export 'tokens/spacing_tokens.dart';
export 'tokens/radius_tokens.dart';

// ==================== 按钮 ====================
export 'components/buttons/minimal_buttons.dart';

// ==================== 输入框 ====================
export 'components/inputs/minimal_text_field.dart';

// ==================== 卡片 ====================
export 'components/cards/minimal_card.dart';

// ==================== 指示器 ====================
export 'components/indicators/minimal_indicators.dart';

// ==================== 布局 ====================
export 'components/layout/minimal_layout.dart';

// ==================== 反馈 ====================
export 'components/feedback/minimal_feedback.dart';

// ==================== 设备组件 ====================
export 'components/devices/minimal_device_card.dart';
export 'components/devices/minimal_device_rename.dart';

// ==================== 导航组件 ====================
export 'components/navigation/minimal_tabbar.dart';
export 'components/navigation/minimal_fab.dart';

// ==================== 设计系统版本信息 ====================
class DesignSystem {
  DesignSystem._();

  /// 设计系统版本号
  static const String version = '3.0.0';

  /// 设计系统名称
  static const String name = 'Minimal UI';

  /// 设计系统描述
  static const String description = '简洁、专业、高效的 IoT 设备控制应用设计系统';
}
