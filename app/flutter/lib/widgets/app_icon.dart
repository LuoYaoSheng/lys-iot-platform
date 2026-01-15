/// 应用图标组件
/// 统一的图标系统，与 UniApp 保持一致
/// 作者: 罗耀生
/// 日期: 2026-01-13

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 图标名称常量 - 与 UniApp AppIcons.vue 保持一致
class AppIcons {
  // 底部导航
  static const String home = 'home';
  static const String profile = 'profile';

  // 设备相关
  static const String device = 'device';
  static const String switchIcon = 'switch';  // switch 是关键字，用 switchIcon
  static const String servo = 'servo';

  // 操作
  static const String add = 'add';
  static const String edit = 'edit';
  static const String delete = 'delete';
  static const String close = 'close';
  static const String copy = 'copy';

  // 导航
  static const String arrowBack = 'arrow_back';
  static const String arrowRight = 'arrow_right';

  // 设置
  static const String settings = 'settings';
  static const String server = 'server';

  // 信息
  static const String info = 'info';

  // 网络和连接
  static const String wifi = 'wifi';
  static const String bluetooth = 'bluetooth';
  static const String scan = 'scan';
  static const String chat = 'chat';

  // 其他
  static const String user = 'user';
  static const String more = 'more';

  // 密码显隐
  static const String eye = 'eye';
  static const String eyeOff = 'eye_off';

  // 状态图标
  static const String bolt = 'bolt';
  static const String check = 'check';
  static const String warning = 'warning';
  static const String error = 'error';

  // 导航箭头
  static const String chevronRight = 'chevron_right';

  // 电源和设备
  static const String power = 'power';
  static const String plug = 'plug';

  // 用户相关
  static const String person = 'person';

  // 其他操作
  static const String refresh = 'refresh';
  static const String link = 'link';
  static const String document = 'document';
  static const String license = 'license';
  static const String inbox = 'inbox';
  static const String menu = 'menu';
  static const String checkCircle = 'check_circle';
}

/// 应用图标组件
class AppIcon extends StatelessWidget {
  final String iconName;
  final double? size;
  final Color? color;

  const AppIcon(
    this.iconName, {
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.iconTheme.color;
    final iconSize = size ?? theme.iconTheme.size ?? 24;

    return SvgPicture.asset(
      'assets/icons/$iconName.svg',
      width: iconSize,
      height: iconSize,
      colorFilter: iconColor != null
          ? ColorFilter.mode(iconColor, BlendMode.srcIn)
          : null,
    );
  }
}

/// 图标按钮辅助组件（用于 AppBar leading 等）
class AppIconButton extends StatelessWidget {
  final String iconName;
  final double? size;
  final VoidCallback? onPressed;

  const AppIconButton(
    this.iconName, {
    super.key,
    this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: (size ?? 24) + 16,
        height: (size ?? 24) + 16,
        alignment: Alignment.center,
        child: AppIcon(iconName, size: size),
      ),
    );
  }
}
