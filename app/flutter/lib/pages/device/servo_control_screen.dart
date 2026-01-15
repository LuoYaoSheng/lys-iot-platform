/// 舵机开关控制页
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import '../../widgets/app_icon.dart';
import '../../theme/app_tokens.dart';

class ServoControlScreen extends StatefulWidget {
  const ServoControlScreen({super.key});

  @override
  State<ServoControlScreen> createState() => _ServoControlScreenState();
}

class _ServoControlScreenState extends State<ServoControlScreen> {
  String position = '上';
  bool isSending = false;
  bool showAdvanced = false;
  double pulseDuration = 500;

  void _sendPulse() {
    if (isSending) return;
    setState(() => isSending = true);
    Future.delayed(Duration(milliseconds: pulseDuration.toInt()), () {
      if (mounted) {
        setState(() => isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('脉冲已发送'), duration: Duration(seconds: 1)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('客厅开关'),
        actions: const [
          IconButton(icon: AppIcon(AppIcons.menu, size: 24), onPressed: null),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPositionPanel(),
              const SizedBox(height: 16),
              _buildPulsePanel(),
              const SizedBox(height: 16),
              _buildStatus(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前位置: $position',
            style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 16),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: position == '上' ? 10 : (position == '中' ? 30 : 50),
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: ['上', '中', '下'].map((p) {
              final isActive = position == p;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: p == '上' ? 0 : 6,
                    right: p == '下' ? 0 : 6,
                  ),
                  child: OutlinedButton(
                    onPressed: () => setState(() => position = p),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isActive ? AppColors.primary : Colors.white,
                      foregroundColor: isActive ? Colors.white : const Color(0xFF3A3A3C),
                      side: BorderSide(
                        color: isActive ? AppColors.primary : const Color(0xFFE5E5EA),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(p),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsePanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '脉冲触发',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          // 高级选项勾选框
          GestureDetector(
            onTap: () => setState(() => showAdvanced = !showAdvanced),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: showAdvanced ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: showAdvanced ? AppColors.primary : const Color(0xFFE5E5EA),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: showAdvanced
                      ? const AppIcon(AppIcons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                const Text(
                  '高级选项',
                  style: TextStyle(fontSize: 14, color: Color(0xFF3A3A3C)),
                ),
              ],
            ),
          ),
          if (showAdvanced) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '脉冲时长',
                        style: TextStyle(fontSize: 14, color: Color(0xFF3A3A3C)),
                      ),
                      Text(
                        '${pulseDuration.toInt()}ms',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: const Color(0xFFE5E5EA),
                      thumbColor: AppColors.primary,
                    ),
                    child: Slider(
                      value: pulseDuration,
                      min: 100,
                      max: 2000,
                      divisions: 19,
                      onChanged: (value) => setState(() => pulseDuration = value),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('100ms', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                      Text('2000ms', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPresetButton('快速', 200),
                      const SizedBox(width: 8),
                      _buildPresetButton('标准', 500),
                      const SizedBox(width: 8),
                      _buildPresetButton('慢速', 1000),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: isSending ? null : _sendPulse,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE5E5EA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      '脉冲触发',
                      style: TextStyle(fontSize: 16, color: Color(0xFF3A3A3C)),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(String label, double value) {
    final isActive = pulseDuration == value;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => pulseDuration = value),
        style: OutlinedButton.styleFrom(
          backgroundColor: isActive ? const Color(0xFFE6F2FF) : Colors.white,
          foregroundColor: isActive ? AppColors.primary : const Color(0xFF8E8E93),
          side: BorderSide(
            color: isActive ? AppColors.primary : const Color(0xFFE5E5EA),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF34C759),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text('在线', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        const Text(
          '最后更新: 2秒前',
          style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
        ),
      ],
    );
  }
}
