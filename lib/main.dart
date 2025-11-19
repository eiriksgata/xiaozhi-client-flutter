import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:opus_dart/opus_dart.dart';
import 'app/themes/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'core/storage/storage_service.dart';
import 'core/providers/theme_provider.dart';
import 'package:logging/logging.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地存储
  await StorageService.instance.init();

  // 配置 Logger - 添加这部分代码
  Logger.root.level = Level.ALL; // 设置日志级别
  Logger.root.onRecord.listen((record) {
    // 使用 debugPrint 替代 print，避免警告
    debugPrint(
      '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
    );
  });

  // 初始化 Hive（日程映射存储）
  await Hive.initFlutter();

  initOpus(await opus_flutter.load());
  debugPrint('Opus初始化成功: ${getOpusVersion()}');
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: '小智助手',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: AppPages.router,
    );
  }
}
