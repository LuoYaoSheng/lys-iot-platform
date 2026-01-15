/// 设备控制页
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import '../../widgets/app_icon.dart';
import '../../theme/app_tokens.dart';

class DeviceControlScreen extends StatefulWidget {
  final String deviceId;

  const DeviceControlScreen({super.key, required this.deviceId});

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  Map<String, dynamic> _device = {};
  String _position = 'middle';
  bool _pulseSending = false;
  bool _pulseSuccess = false;
  bool _showAdvanced = false;
  double _pulseDuration = 500;

  @override
  void initState() {
    super.initState();
    _loadDevice();
  }

  void _loadDevice() {
    final devices = [
      {'id': '1', 'name': 'IoT-Switch-A1B2', 'type': 'servo', 'status': 'online', 'firmware': 'v1.2.0'},
      {'id': '2', 'name': 'IoT-Wakeup-C3D4', 'type': 'wakeup', 'status': 'online', 'firmware': 'v1.0.0'},
      {'id': '3', 'name': 'IoT-Switch-E5F6', 'type': 'servo', 'status': 'offline', 'firmware': 'v1.1.0'},
    ];
    setState(() {
      _device = devices.firstWhere((d) => d['id'] == widget.deviceId, orElse: () => {'id': '', 'name': '未知设备', 'type': 'servo', 'status': 'offline', 'firmware': 'v1.0.0'});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _device['status'] == 'online';
    final isServo = _device['type'] == 'servo';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('设备控制'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3A3A3C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态卡片
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: isOnline ? const Color(0xFF34C759) : const Color(0xFF8E8E93))),
                  const SizedBox(width: 8),
                  Text(isOnline ? '在线' : '离线', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isOnline ? const Color(0xFF34C759) : const Color(0xFF8E8E93))),
                  const Spacer(),
                  Text('固件: ${_device['firmware'] ?? 'v1.0.0'}', style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (isServo) ...[
              const Text('位置控制', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
              const SizedBox(height: 12),
              _buildPositionControl(),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              const Text('脉冲触发', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
              const SizedBox(height: 12),
              _buildPulseButton(),
            ] else ...[
              const Text('电脑唤醒', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
              const SizedBox(height: 12),
              _buildWakeupCard(),
            ],

            const SizedBox(height: 24),
            const Text('设备信息', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
            const SizedBox(height: 12),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildDeleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionControl() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              const Text('当前位置', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
              const SizedBox(height: 8),
              Text({'up': '上', 'middle': '中', 'down': '下'}[_position] ?? '中', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildPosButton('上', 'up'),
            const SizedBox(width: 12),
            _buildPosButton('中', 'middle'),
            const SizedBox(width: 12),
            _buildPosButton('下', 'down'),
          ],
        ),
      ],
    );
  }

  Widget _buildPosButton(String label, String pos) {
    final isActive = _position == pos;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _position = pos);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已设置到$label')));
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(color: isActive ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(label, style: TextStyle(fontSize: 16, color: isActive ? Colors.white : const Color(0xFF3A3A3C)))),
        ),
      ),
    );
  }

  Widget _buildPulseButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 高级选项勾选框
        GestureDetector(
          onTap: () => setState(() => _showAdvanced = !_showAdvanced),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _showAdvanced ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: _showAdvanced ? AppColors.primary : const Color(0xFFE5E5EA),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _showAdvanced
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
        // 高级选项内容
        if (_showAdvanced) ...[
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
                      '${_pulseDuration.toInt()}ms',
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
                    value: _pulseDuration,
                    min: 100,
                    max: 2000,
                    divisions: 19,
                    onChanged: (value) => setState(() => _pulseDuration = value),
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
          child: ElevatedButton(
            onPressed: _pulseSending ? null : _triggerPulse,
            style: ElevatedButton.styleFrom(
              backgroundColor: _pulseSuccess ? const Color(0xFF34C759) : (_pulseSending ? const Color(0xFFFF9500) : AppColors.primary),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _pulseSending
                ? const Text('发送中...', style: TextStyle(fontSize: 16))
                : _pulseSuccess
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppIcon(AppIcons.check, size: 16, color: Colors.white),
                          SizedBox(width: 8),
                          Text('已触发', style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : const Text('触发脉冲', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 8),
        const Center(child: Text('短暂触发后自动恢复', style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93)))),
      ],
    );
  }

  Widget _buildPresetButton(String label, double value) {
    final isActive = _pulseDuration == value;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => _pulseDuration = value),
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

  void _triggerPulse() async {
    setState(() { _pulseSending = true; _pulseSuccess = false; });
    await Future.delayed(Duration(milliseconds: _pulseDuration.toInt()));
    if (!mounted) return;
    setState(() { _pulseSending = false; _pulseSuccess = true; });
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _pulseSuccess = false); });
  }

  Widget _buildWakeupCard() {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('唤醒信号已发送'))),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Center(child: AppIcon(AppIcons.power, size: 48, color: AppColors.primary)),
            ),
            const SizedBox(height: 24),
            const Text('点击唤醒', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('电脑将立即启动', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // 设备名称 - 可编辑
          GestureDetector(
            onTap: _editDeviceName,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('设备名称', style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      Text(_device['name'] ?? '', style: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93))),
                      const SizedBox(width: 4),
                      const AppIcon(AppIcons.chevronRight, size: 20, color: Color(0xFF8E8E93)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildInfoItem('设备ID', _device['id'] ?? ''),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildInfoItem('设备类型', _device['type'] == 'servo' ? '舵机开关' : 'USB唤醒'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93))),
      ]),
    );
  }

  void _editDeviceName() {
    final controller = TextEditingController(text: _device['name'] ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改设备名称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入设备名称',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('名称不能为空')),
                );
                return;
              }
              setState(() {
                _device['name'] = newName;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('修改成功')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _confirmDelete,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF3B30),
          side: BorderSide.none,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('删除设备', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除设备'),
        content: Text('确定要删除「${_device['name']}」吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已删除')));
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
