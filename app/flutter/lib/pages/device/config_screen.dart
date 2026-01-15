/// WiFi配置页
/// 作者: 罗耀生

import 'package:flutter/material.dart';
import '../../theme/app_tokens.dart';
import '../../core/app_router.dart';
import '../../widgets/app_icon.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  int _step = 1;
  String _deviceName = 'IoT-Device';
  String _deviceType = '舵机开关';
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _deviceName = args['name'] ?? 'IoT-Device';
      _deviceType = args['type'] ?? '舵机开关';
      _nameController.text = _deviceName;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('WiFi配置'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3A3A3C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStepper(),
            const SizedBox(height: 24),
            _buildDeviceCard(),
            const SizedBox(height: 16),
            if (_step == 1) _buildStep1(),
            if (_step == 2) _buildStep2(),
            if (_step == 3) _buildStep3(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(1, 'WiFi'),
        _buildStepLine(),
        _buildStepCircle(2, '名称'),
        _buildStepLine(),
        _buildStepCircle(3, '完成'),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _step >= step;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFE5E5EA),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text('$step', style: TextStyle(fontSize: 14, color: isActive ? Colors.white : const Color(0xFF8E8E93))),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: isActive ? AppColors.primary : const Color(0xFF8E8E93))),
      ],
    );
  }

  Widget _buildStepLine() {
    return Container(width: 40, height: 2, margin: const EdgeInsets.only(bottom: 20, left: 8, right: 8), color: const Color(0xFFE5E5EA));
  }

  Widget _buildDeviceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          AppIcon(_deviceType == 'USB唤醒' ? AppIcons.bolt : AppIcons.plug, size: 24, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_deviceName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Text(_deviceType, style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WiFi 网络', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
          const SizedBox(height: 8),
          _buildInput('MyHome_5G', enabled: false),
          const SizedBox(height: 16),
          const Text('WiFi 密码', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
          const SizedBox(height: 8),
          _buildInputField(_passwordController, '请输入WiFi密码', obscure: true),
          const SizedBox(height: 24),
          _buildButton('下一步', () {
            if (_passwordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入WiFi密码')));
              return;
            }
            setState(() => _step = 2);
          }),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('设备名称', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
          const SizedBox(height: 8),
          _buildInputField(_nameController, '请输入设备名称'),
          const SizedBox(height: 16),
          const Text('设备位置（可选）', style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93))),
          const SizedBox(height: 8),
          _buildInput('如：客厅、卧室'),
          const SizedBox(height: 24),
          _buildButton('下一步', () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入设备名称')));
              return;
            }
            setState(() => _step = 3);
          }),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle),
            child: const Center(child: AppIcon(AppIcons.check, size: 32, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          const Text('配置成功', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('设备已添加到您的设备列表', style: TextStyle(color: Color(0xFF8E8E93))),
          const SizedBox(height: 24),
          _buildButton('返回设备列表', () => AppRouter.goToMain(context)),
        ],
      ),
    );
  }

  Widget _buildInput(String hint, {bool enabled = true}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(hint, style: TextStyle(fontSize: 16, color: enabled ? const Color(0xFF3A3A3C) : const Color(0xFFC7C7CC))),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, {bool obscure = false}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFC7C7CC)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
