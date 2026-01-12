/// 通用控制面板（降级方案）
/// 作者: 罗耀生
/// 日期: 2025-12-19
/// v0.2.0: 当产品未定义controlMode或无法识别时使用

import 'package:flutter/material.dart';
import 'control_panel_base.dart';
import '../../design_system/design_system.dart';

class GenericPanel extends ControlPanelBase {
  const GenericPanel({
    super.key,
    required super.device,
    required super.apiService,
  });

  @override
  State<GenericPanel> createState() => _GenericPanelState();
}

class _GenericPanelState extends ControlPanelState<GenericPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '设备控制',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MinimalTokens.gray900,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: MinimalTokens.gray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: MinimalTokens.gray300,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无专用控制面板',
                style: TextStyle(
                  fontSize: 16,
                  color: MinimalTokens.gray700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '请联系管理员配置产品控制模式',
                style: TextStyle(
                  fontSize: 14,
                  color: MinimalTokens.gray500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildDeviceInfo(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDeviceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '设备信息',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MinimalTokens.gray700,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('设备ID', widget.device.deviceId),
        _buildInfoRow('设备SN', widget.device.deviceSN),
        _buildInfoRow('产品类型', widget.device.productKey),
        if (widget.device.product?.name != null)
          _buildInfoRow('产品名称', widget.device.product!.name),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: MinimalTokens.gray700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: MinimalTokens.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
