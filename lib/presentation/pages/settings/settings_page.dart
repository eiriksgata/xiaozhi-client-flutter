import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xiaozhi_client_flutter/core/utils/xiaozhi_device_info_util.dart';
import '../../../core/providers/theme_provider.dart';

/// 设置页面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeNotifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          _buildSection(
            title: '设备信息',
            children: [
              ListTile(
                leading: const Icon(Icons.confirmation_num_outlined),
                title: const Text('虚拟MAC地址'),
                subtitle: Text('02:00:00:00:00:00'),
                onTap: () {
                  //点击复制文本
                  XiaozhiDeviceInfoUtil.instance.getDeviceMacAddress();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outlined),
                title: const Text('虚拟Client ID'),
                subtitle: Text('flutter_client_123456'),
                onTap: () {
                  //点击复制文本
                  Clipboard.setData(
                    const ClipboardData(text: 'flutter_client_123456'),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_android_outlined),
                title: const Text('设备名称'),
                subtitle: Text('flutter_client_123456'),
                onTap: () {
                  //点击复制文本
                  Clipboard.setData(
                    const ClipboardData(text: 'flutter_client_123456'),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: '外观',
            children: [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('主题模式'),
                subtitle: Text(themeModeNotifier.getThemeModeName()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showThemeDialog(context, ref);
                },
              ),
            ],
          ),
          _buildSection(
            title: '通用',
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('语言'),
                subtitle: const Text('简体中文'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 切换语言
                },
              ),
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('清除缓存'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 清除缓存
                },
              ),
            ],
          ),
          _buildSection(
            title: '关于',
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('版本'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('用户协议'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 显示用户协议
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('隐私政策'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 显示隐私政策
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  /// 显示主题选择对话框
  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final themeModeNotifier = ref.read(themeModeProvider.notifier);
    final currentThemeMode = ref.read(themeModeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('浅色'),
              value: ThemeMode.light,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  themeModeNotifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('深色'),
              value: ThemeMode.dark,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  themeModeNotifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('跟随系统'),
              value: ThemeMode.system,
              groupValue: currentThemeMode,
              onChanged: (value) {
                if (value != null) {
                  themeModeNotifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
