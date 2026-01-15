/// 关于页
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import '../../widgets/app_icon.dart';
import '../../theme/app_tokens.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('关于'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3A3A3C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF007AFF), Color(0xFF5856D6)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: AppIcon(AppIcons.bolt, size: 32, color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  const Text('Open IoT Platform', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('轻量级开源 IoT 设备管理平台', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // 版本信息
            _buildCard([
              _buildInfoRow('版本号', 'v1.0.0'),
              _buildInfoRow('构建日期', '2026-01-14'),
            ]),
            const SizedBox(height: 16),

            // 相关链接
            const Text('相关链接', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
            const SizedBox(height: 8),
            _buildCard([
              _buildLinkRow(AppIcons.link, 'GitHub', null),
              _buildLinkRow(AppIcons.document, '更新日志', null),
              _buildLinkRow(AppIcons.license, '开源协议', 'GPL v3'),
            ]),
            const SizedBox(height: 16),

            // 作者
            const Text('作者', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
            const SizedBox(height: 8),
            _buildCard([
              _buildInfoRow('作者', '罗耀生'),
              _buildInfoRow('邮箱', 'contact@i2kai.com', isLink: true),
            ]),
            const SizedBox(height: 16),

            // 技术栈
            const Text('技术栈', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Flutter', 'UniApp', 'Go', 'MQTT', 'MySQL'].map((tech) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(8)),
                    child: Text(tech, style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // 版权
            const Center(
              child: Column(
                children: [
                  Text('© 2026 Open IoT Platform', style: TextStyle(fontSize: 12, color: Color(0xFFC7C7CC))),
                  Text('All rights reserved', style: TextStyle(fontSize: 12, color: Color(0xFFC7C7CC))),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Column(
            children: [
              child,
              if (index < children.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, color: isLink ? AppColors.primary : const Color(0xFF8E8E93))),
        ],
      ),
    );
  }

  Widget _buildLinkRow(String iconName, String label, String? trailing) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AppIcon(iconName, size: 20, color: const Color(0xFF3A3A3C)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          if (trailing != null) ...[
            Text(trailing, style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
            const SizedBox(width: 8),
          ],
          const AppIcon(AppIcons.chevronRight, size: 20, color: Color(0xFFC7C7CC)),
        ],
      ),
    );
  }
}
