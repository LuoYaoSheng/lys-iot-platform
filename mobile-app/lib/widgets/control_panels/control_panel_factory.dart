/// 控制面板工厂
/// 作者: 罗耀生
/// 日期: 2025-12-19
/// v0.2.0: 根据产品controlMode动态创建控制面板

import 'package:flutter/material.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import '../../services/api_service.dart';
import 'control_panel_base.dart';
import 'switch_toggle_panel.dart';
import 'switch_pulse_panel.dart';
import 'sensor_display_panel.dart';
import 'generic_panel.dart';

/// 控制面板工厂
class ControlPanelFactory {
  /// 根据设备产品信息创建控制面板
  static ControlPanelBase createPanel({
    required Device device,
    required ApiService apiService,
  }) {
    // 获取产品的控制模式
    final controlMode = device.product?.controlMode;

    // 根据controlMode选择面板
    switch (controlMode) {
      case 'toggle':
        return SwitchTogglePanel(device: device, apiService: apiService);

      case 'pulse':
        return SwitchPulsePanel(device: device, apiService: apiService);

      case 'readonly':
        return SensorDisplayPanel(device: device, apiService: apiService);

      case 'dimmer':
        // TODO: 实现调光调色面板
        return GenericPanel(device: device, apiService: apiService);

      case 'generic':
      default:
        // 降级到通用面板
        return GenericPanel(device: device, apiService: apiService);
    }
  }

  /// 获取面板标题
  static String getPanelTitle(Device device) {
    // 优先使用设备名称
    if (device.name != null && device.name!.isNotEmpty) {
      return device.name!;
    }

    // 其次使用产品名称
    if (device.product?.name != null) {
      return device.product!.name;
    }

    // 降级使用默认名称
    return '智能设备';
  }

  /// 获取面板图标
  static IconData getPanelIcon(Device device) {
    final iconName = device.product?.iconName;

    if (iconName == null) return Icons.devices;

    switch (iconName) {
      case 'power_settings_new':
        return Icons.power_settings_new;
      case 'touch_app':
        return Icons.touch_app;
      case 'thermostat':
        return Icons.thermostat;
      case 'lock':
        return Icons.lock;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'curtains':
        return Icons.curtains;
      case 'bolt':
        return Icons.bolt;
      default:
        return Icons.devices;
    }
  }

  /// 获取面板颜色
  static Color getPanelColor(Device device) {
    final colorHex = device.product?.iconColor;

    if (colorHex == null) return Colors.blue;

    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}
