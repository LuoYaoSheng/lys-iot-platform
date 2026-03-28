// 控制面板基类
// 作者: 罗耀生
// 日期: 2025-12-19
// v0.2.0: 支持基于产品controlMode的动态面板加载

import 'package:flutter/material.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import '../../services/api_service.dart';

// 控制面板基类
abstract class ControlPanelBase extends StatefulWidget {
  final Device device;
  final ApiService apiService;

  const ControlPanelBase({
    super.key,
    required this.device,
    required this.apiService,
  });
}

/// 控制面板状态基类
abstract class ControlPanelState<T extends ControlPanelBase> extends State<T> {
  bool isControlling = false;

  /// 显示成功消息
  void showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  /// 显示错误消息
  void showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  /// 设置控制状态
  void setControlling(bool controlling) {
    if (mounted) {
      setState(() {
        isControlling = controlling;
      });
    }
  }
}
