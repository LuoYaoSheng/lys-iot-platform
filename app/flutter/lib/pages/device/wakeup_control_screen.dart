import 'package:flutter/material.dart';
import '../../widgets/app_icon.dart';

class WakeupControlScreen extends StatefulWidget {
  const WakeupControlScreen({super.key});
  @override
  State<WakeupControlScreen> createState() => _WakeupControlScreenState();
}

class _WakeupControlScreenState extends State<WakeupControlScreen> {
  bool isSending = false;
  bool isSuccess = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('电脑唤醒'),
        actions: const [
          IconButton(icon: AppIcon(AppIcons.menu, size: 24), onPressed: null),
        ],
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            width: 200,
            height: 200,
            child: ElevatedButton(
              onPressed: isSending ? null : () {
                setState(() => isSending = true);
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (mounted) {
                    setState(() => isSending = false);
                    setState(() => isSuccess = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => isSuccess = false);
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? Colors.green : Colors.blue,
                shape: const CircleBorder(),
              ),
              child: isSending
                  ? const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: Colors.white))
                  : isSuccess
                      ? const AppIcon(AppIcons.check, size: 80, color: Colors.white)
                      : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [AppIcon(AppIcons.bolt, size: 80, color: Colors.white), Text('唤醒', style: TextStyle(color: Colors.white, fontSize: 24))]),
            ),
          ),
          const SizedBox(height: 48),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)), const SizedBox(width: 8), const Text('在线'), const Text('  最后更新: 5秒前', style: TextStyle(color: Colors.grey))]),
          const SizedBox(height: 48),
          Column(children: [const Text('设备信息', style: TextStyle(color: Colors.grey, fontSize: 12)), const Text('USB-WAKEUP-S3'), const Text('固件: 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12))]),
        ]),
      ),
    );
  }
}
