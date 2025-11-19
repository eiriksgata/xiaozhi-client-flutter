import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_service.dart';
import '../../app/config/app_config.dart';

/// 主题模式状态管理
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storage;

  ThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// 加载保存的主题模式
  Future<void> _loadThemeMode() async {
    final themeIndex = _storage.getInt(AppConfig.keyThemeMode);
    if (themeIndex != null) {
      state = ThemeMode.values[themeIndex];
    }
  }

  /// 切换到指定主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _storage.setInt(AppConfig.keyThemeMode, mode.index);
  }

  /// 切换到浅色主题
  Future<void> setLightMode() => setThemeMode(ThemeMode.light);

  /// 切换到深色主题
  Future<void> setDarkMode() => setThemeMode(ThemeMode.dark);

  /// 切换到跟随系统
  Future<void> setSystemMode() => setThemeMode(ThemeMode.system);

  /// 获取主题模式的显示名称
  String getThemeModeName() {
    switch (state) {
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
      case ThemeMode.system:
        return '跟随系统';
    }
  }
}

/// 主题模式 Provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(StorageService.instance);
});
