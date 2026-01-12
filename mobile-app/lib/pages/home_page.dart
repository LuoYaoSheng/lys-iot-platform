/// 主页面 - 带 TabBar 导航
/// 作者: 罗耀生
/// 版本: 1.0.0
///
/// 包含两个 Tab：设备列表、个人中心

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iot_platform_sdk/iot_platform_sdk.dart';
import '../design_system/design_system.dart';
import '../providers/device_provider.dart';
import '../services/api_service.dart';
import '../widgets/stats_card.dart';
import '../widgets/control_panels/control_panel_factory.dart';
import 'profile_page.dart';
import 'settings_page.dart';

/// 主页面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _DeviceTab(),
    _ProfileTab(),
  ];

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _BottomTabBar(
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
    );
  }
}

/// 设备 Tab（带 AppBar）
class _DeviceTab extends StatelessWidget {
  const _DeviceTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _DeviceAppBar(),
      body: const DeviceListContent(),
    );
  }
}

/// 设备 AppBar（带标题和设置按钮）
class _DeviceAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('我的设备'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }
}

/// 个人中心 Tab（无 AppBar）
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}

/// 底部 TabBar
class _BottomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomTabBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: MinimalTokens.white,
        border: Border(
          top: BorderSide(color: MinimalTokens.gray100, width: 1),
        ),
      ),
      child: Row(
        children: [
          _TabItem(
            icon: Icons.devices_outlined,
            activeIcon: Icons.devices,
            label: '设备',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _TabItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: '我的',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
        ],
      ),
    );
  }
}

/// 单个 Tab 项
class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? MinimalTokens.primary : MinimalTokens.gray300,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? MinimalTokens.primary : MinimalTokens.gray300,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 设备列表内容（不含 AppBar，用于 Tab 内）
class DeviceListContent extends StatefulWidget {
  const DeviceListContent({super.key});

  @override
  State<DeviceListContent> createState() => _DeviceListContentState();
}

class _DeviceListContentState extends State<DeviceListContent> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadAPICredentials();
      await context.read<DeviceProvider>().loadDevices();
    });
  }

  Future<void> _loadAPICredentials() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载自定义 API 地址（如果有）
    final customApiUrl = prefs.getString('custom_api_url');
    if (customApiUrl != null && customApiUrl.isNotEmpty) {
      _apiService.setBaseUrl(customApiUrl);
    }

    // 优先使用 Bearer Token
    final token = prefs.getString('iot_token');
    if (token != null && token.isNotEmpty) {
      _apiService.setBearerToken(token);
    } else {
      // 降级使用 API Key
      final apiKey = prefs.getString('api_key');
      final apiSecret = prefs.getString('api_secret');
      if (apiKey != null && apiSecret != null) {
        _apiService.setAPIKey(apiKey, apiSecret);
      }
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.loadDevices(),
          child: CustomScrollView(
            slivers: [
              // 统计卡片
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _StatsSection(provider: provider),
                ),
              ),

              // 设备列表
              _DeviceListSliver(
                provider: provider,
                apiService: _apiService,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 统计区域（渐变卡片 + 设备数量）
class _StatsSection extends StatelessWidget {
  final DeviceProvider provider;

  const _StatsSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final totalDevices = provider.devices.length;
    final onlineDevices = provider.devices.where((d) => d.isOnline).length;

    return StatsCard(
      stats: [
        StatItem(value: '$totalDevices 台', label: '我的设备'),
        StatItem(value: '$onlineDevices 台', label: '在线'),
      ],
    );
  }
}

/// 设备列表 Sliver
class _DeviceListSliver extends StatelessWidget {
  final DeviceProvider provider;
  final ApiService apiService;

  const _DeviceListSliver({
    required this.provider,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.devices.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null && provider.devices.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: MinimalTokens.gray300),
              const SizedBox(height: 16),
              Text('加载失败', style: TextStyle(fontSize: 16, color: MinimalTokens.gray700)),
              const SizedBox(height: 8),
              Text(
                provider.error!,
                style: TextStyle(fontSize: 12, color: MinimalTokens.gray500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.loadDevices(),
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.devices.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.devices, size: 64, color: MinimalTokens.gray300),
              const SizedBox(height: 16),
              Text('暂无设备', style: TextStyle(fontSize: 16, color: MinimalTokens.gray700)),
              const SizedBox(height: 8),
              Text('点击右下角按钮添加设备', style: TextStyle(fontSize: 14, color: MinimalTokens.gray500)),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final device = provider.devices[index];
            return _DeviceCard(
              device: device,
              apiService: apiService,
            );
          },
          childCount: provider.devices.length,
        ),
      ),
    );
  }
}

/// 设备卡片
class _DeviceCard extends StatelessWidget {
  final Device device;
  final ApiService apiService;

  const _DeviceCard({
    required this.device,
    required this.apiService,
  });

  bool get isOnline => device.isOnline;
  String get deviceId => device.deviceId;

  /// 根据产品信息获取图标
  IconData get _productIcon {
    final iconName = device.product?.iconName;
    if (iconName == null) return Icons.power_settings_new;

    switch (iconName) {
      case 'power_settings_new': return Icons.power_settings_new;
      case 'touch_app': return Icons.touch_app;
      case 'thermostat': return Icons.thermostat;
      case 'lock': return Icons.lock;
      case 'lightbulb': return Icons.lightbulb;
      case 'curtains': return Icons.curtains;
      case 'bolt': return Icons.bolt;
      case 'keyboard': return Icons.keyboard;
      default: return Icons.device_unknown;
    }
  }

  /// 根据产品信息获取颜色
  Color get _productColor {
    final colorHex = device.product?.iconColor;
    if (colorHex == null) return MinimalTokens.primary;

    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return MinimalTokens.primary;
    }
  }

  /// 根据产品信息获取设备名称
  String get _deviceDisplayName {
    if (device.name != null && device.name!.isNotEmpty) {
      return device.name!;
    }
    if (device.product?.name != null) {
      return device.product!.name;
    }
    return '智能设备';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showControlPanel(context),
        borderRadius: BorderRadius.circular(MinimalTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 设备图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _productColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_productIcon, color: _productColor, size: 28),
              ),
              const SizedBox(width: 16),
              // 设备信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _deviceDisplayName,
                      style: TextStyle(
                        fontSize: MinimalTokens.fontSizeBody,
                        fontWeight: FontWeight.w500,
                        color: MinimalTokens.gray700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isOnline ? MinimalTokens.success : MinimalTokens.gray300,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? '在线' : '离线',
                          style: TextStyle(
                            fontSize: MinimalTokens.fontSizeBodySmall,
                            color: isOnline ? MinimalTokens.success : MinimalTokens.gray300,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          deviceId,
                          style: TextStyle(
                            fontSize: 11,
                            color: MinimalTokens.gray500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 箭头图标
              Icon(Icons.chevron_right, color: MinimalTokens.gray300),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示设备控制面板
  void _showControlPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 顶部拖动指示器
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: MinimalTokens.gray200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // 设备标题
                  _buildDeviceHeader(),
                  const Divider(height: 32),
                  // 动态控制面板
                  ControlPanelFactory.createPanel(
                    device: device,
                    apiService: apiService,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建设备标题
  Widget _buildDeviceHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _productColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_productIcon, color: _productColor, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _deviceDisplayName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: MinimalTokens.gray900,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isOnline ? MinimalTokens.success : MinimalTokens.gray300,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? '在线' : '离线',
                    style: TextStyle(
                      fontSize: 14,
                      color: isOnline ? MinimalTokens.success : MinimalTokens.gray300,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    deviceId,
                    style: TextStyle(
                      fontSize: 12,
                      color: MinimalTokens.gray500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
