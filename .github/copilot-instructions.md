# Copilot Instructions for xiaozhi_client_flutter

## 项目概述
这是一个基于 Flutter 的 AI 聊天应用，主要面向 Android 和 iOS 移动端。应用支持多模态交互（文字、图片、音频），采用智能体（Agent）管理模式，用户可以配置多个 AI 智能体并进行对话。

**核心功能：**
- 智能体列表管理（添加、编辑、删除智能体配置）
- 多模态消息发送/接收（文字、图片、音频）
- 底部导航栏：对话、设置两个主页面
- 智能体配置（URL、Token 等参数）

**技术栈：** Dart 3.9.2+, Flutter SDK, 主要目标平台 Android/iOS

---

## 项目架构设计

### 目录结构规范
```
lib/
├── main.dart                          # 应用入口
├── app/
│   ├── routes/                        # 路由配置
│   │   ├── app_routes.dart           # 路由常量定义
│   │   └── app_pages.dart            # 路由页面映射
│   ├── themes/                        # 主题配置
│   │   ├── app_theme.dart            # 主题定义
│   │   ├── app_colors.dart           # 颜色常量
│   │   └── app_text_styles.dart      # 文本样式
│   └── config/
│       └── app_config.dart           # 应用配置常量
├── core/
│   ├── network/                       # 网络层
│   │   ├── dio_client.dart           # Dio 客户端封装
│   │   ├── api_interceptor.dart      # 拦截器
│   │   └── api_exception.dart        # 异常处理
│   ├── storage/                       # 本地存储
│   │   └── storage_service.dart      # 封装 shared_preferences/hive
│   ├── utils/                         # 工具类
│   │   ├── logger.dart               # 日志工具
│   │   ├── toast_util.dart           # 提示工具
│   │   └── permission_util.dart      # 权限工具
│   └── constants/
│       └── api_constants.dart        # API 常量
├── data/
│   ├── models/                        # 数据模型
│   │   ├── agent_model.dart          # 智能体模型
│   │   ├── message_model.dart        # 消息模型
│   │   └── user_model.dart           # 用户模型
│   ├── repositories/                  # 数据仓库层
│   │   ├── agent_repository.dart     # 智能体数据仓库
│   │   └── chat_repository.dart      # 聊天数据仓库
│   └── providers/                     # 数据源
│       ├── remote/                    # 远程数据源（API）
│       │   ├── agent_api.dart
│       │   └── chat_api.dart
│       └── local/                     # 本地数据源
│           └── agent_local_storage.dart
├── presentation/
│   ├── pages/                         # 页面
│   │   ├── main/                      # 主页面（底部导航）
│   │   │   ├── main_page.dart
│   │   │   └── main_controller.dart
│   │   ├── conversation/              # 对话页面
│   │   │   ├── conversation_page.dart
│   │   │   ├── conversation_controller.dart
│   │   │   └── widgets/              # 对话页面组件
│   │   │       ├── agent_card.dart
│   │   │       └── agent_list.dart
│   │   ├── chat/                      # 聊天详情页
│   │   │   ├── chat_page.dart
│   │   │   ├── chat_controller.dart
│   │   │   └── widgets/
│   │   │       ├── message_bubble.dart
│   │   │       ├── input_bar.dart
│   │   │       ├── voice_recorder.dart
│   │   │       └── image_picker_widget.dart
│   │   ├── agent_config/              # 智能体配置页
│   │   │   ├── agent_config_page.dart
│   │   │   └── agent_config_controller.dart
│   │   └── settings/                  # 设置页面
│   │       ├── settings_page.dart
│   │       └── settings_controller.dart
│   └── widgets/                       # 全局共享组件
│       ├── common_button.dart
│       ├── loading_widget.dart
│       └── empty_state.dart
└── l10n/                              # 国际化（可选）
    └── app_localizations.dart
```

### 架构模式：Clean Architecture + MVVM + Repository Pattern
- **Presentation Layer**: 页面 + Controller（使用 GetX/Riverpod 管理状态）
- **Domain Layer**: 业务逻辑（可选，简单应用可省略）
- **Data Layer**: Repository + Data Source（Remote/Local）

---

## 核心依赖包（主流选型）

### 必需依赖
```yaml
dependencies:
  # 状态管理（选择其一，推荐 Riverpod 或 GetX）
  flutter_riverpod: ^2.5.0          # 推荐：类型安全，性能优秀
  # get: ^4.6.6                      # 备选：简单易用，路由+状态一体

  # 网络请求
  dio: ^5.4.0                        # HTTP 客户端
  retrofit: ^4.0.0                   # 类型安全的 API 定义（可选）
  retrofit_generator: ^8.0.0         # retrofit 代码生成
  
  # 本地存储
  shared_preferences: ^2.2.2         # 轻量键值存储
  hive: ^2.2.3                       # 高性能 NoSQL 数据库
  hive_flutter: ^1.1.0
  path_provider: ^2.1.2              # 文件路径

  # 路由导航
  go_router: ^13.0.0                 # 声明式路由（推荐）
  # get: ^4.6.6                      # 或使用 GetX 路由

  # JSON 序列化
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1         # 不可变数据类（推荐）

  # UI 组件
  cached_network_image: ^3.3.1       # 图片缓存
  flutter_svg: ^2.0.10               # SVG 支持
  shimmer: ^3.0.0                    # 加载骨架屏
  
  # 多媒体
  image_picker: ^1.0.7               # 图片选择
  # record: ^5.0.4                   # 音频录制（暂时移除，存在 Linux 平台兼容性问题）
  audioplayers: ^5.2.1               # 音频播放
  permission_handler: ^11.3.0        # 权限管理
  
  # 工具类
  logger: ^2.0.2                     # 日志
  fluttertoast: ^8.2.4               # Toast 提示
  intl: ^0.19.0                      # 国际化和日期格式化
  uuid: ^4.3.3                       # UUID 生成

dev_dependencies:
  # 代码生成
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  freezed: ^2.4.7
  hive_generator: ^2.0.1
  retrofit_generator: ^8.0.0
  
  # 测试
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4                    # Mock 测试
  
  # 代码质量
  flutter_lints: ^5.0.0
```

---

## 代码规范

### 命名规范
- **文件名**: `lowercase_with_underscores.dart`
- **类名**: `PascalCase` (例如: `AgentModel`, `ChatController`)
- **变量/方法**: `lowerCamelCase` (例如: `agentList`, `sendMessage()`)
- **常量**: `lowerCamelCase` 或 `SCREAMING_SNAKE_CASE`
- **私有成员**: 前缀 `_` (例如: `_counter`, `_initState()`)

### Widget 编写规范
```dart
// ✅ 推荐：使用 const 构造函数
class AgentCard extends StatelessWidget {
  const AgentCard({
    super.key,
    required this.agent,
    this.onTap,
  });

  final AgentModel agent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(agent.name),
        subtitle: Text(agent.url),
        onTap: onTap,
      ),
    );
  }
}

// ✅ StatefulWidget 状态管理
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose(); // 必须释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(/* ... */);
  }
}
```

### 数据模型规范（使用 Freezed）
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_model.freezed.dart';
part 'agent_model.g.dart';

@freezed
class AgentModel with _$AgentModel {
  const factory AgentModel({
    required String id,
    required String name,
    required String url,
    required String token,
    String? avatar,
    @Default('') String description,
  }) = _AgentModel;

  factory AgentModel.fromJson(Map<String, dynamic> json) =>
      _$AgentModelFromJson(json);
}
```

### 网络请求规范（Dio + Retrofit）
```dart
// core/network/dio_client.dart
class DioClient {
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.addAll([
      ApiInterceptor(),  // 自定义拦截器
      LogInterceptor(responseBody: true), // 日志
    ]);

    return dio;
  }
}

// data/providers/remote/chat_api.dart (使用 Retrofit)
@RestApi()
abstract class ChatApi {
  factory ChatApi(Dio dio) = _ChatApi;

  @POST('/chat/send')
  Future<MessageResponse> sendMessage(@Body() MessageRequest request);

  @GET('/agents')
  Future<List<AgentModel>> getAgents();
}
```

### 状态管理规范（Riverpod 示例）
```dart
// presentation/pages/conversation/conversation_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final agentListProvider = StateNotifierProvider<AgentListController, AsyncValue<List<AgentModel>>>(
  (ref) => AgentListController(ref.read(agentRepositoryProvider)),
);

class AgentListController extends StateNotifier<AsyncValue<List<AgentModel>>> {
  AgentListController(this._repository) : super(const AsyncValue.loading()) {
    loadAgents();
  }

  final AgentRepository _repository;

  Future<void> loadAgents() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAgents());
  }

  Future<void> addAgent(AgentModel agent) async {
    await _repository.saveAgent(agent);
    await loadAgents();
  }
}

// 页面中使用
class ConversationPage extends ConsumerWidget {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentListAsync = ref.watch(agentListProvider);

    return agentListAsync.when(
      data: (agents) => ListView.builder(
        itemCount: agents.length,
        itemBuilder: (context, index) => AgentCard(agent: agents[index]),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

---

## UI/UX 设计规范

### 主题配置（Material 3）
```dart
// app/themes/app_theme.dart
class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }
}

// app/themes/app_colors.dart
class AppColors {
  // 主色调
  static const Color primary = Color(0xFF6750A4);
  static const Color secondary = Color(0xFF625B71);
  
  // 背景色
  static const Color background = Color(0xFFFFFBFE);
  static const Color backgroundDark = Color(0xFF1C1B1F);
  
  // 消息气泡
  static const Color userMessageBg = Color(0xFFE8DEF8);
  static const Color aiMessageBg = Color(0xFFE7E0EC);
  
  // 功能色
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
}
```

### 底部导航栏实现
```dart
// presentation/pages/main/main_page.dart
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ConversationPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '对话',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
```

### 聊天气泡组件设计
```dart
// presentation/pages/chat/widgets/message_bubble.dart
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  final MessageModel message;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isUser ? AppColors.userMessageBg : AppColors.aiMessageBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _buildMessageContent(),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return Text(message.content);
      case MessageType.image:
        return CachedNetworkImage(imageUrl: message.content);
      case MessageType.audio:
        return AudioPlayerWidget(audioUrl: message.content);
      default:
        return const SizedBox.shrink();
    }
  }
}
```

---

## 关键功能实现指南

### 1. 图片选择和上传
```dart
// 使用 image_picker
Future<void> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1920,
    maxHeight: 1080,
    imageQuality: 85,
  );
  
  if (image != null) {
    // 上传图片到服务器
    await _uploadImage(File(image.path));
  }
}
```

### 2. 音频录制和播放
```dart
// 使用 record 和 audioplayers
class VoiceRecorder {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  Future<void> startRecording() async {
    if (await _recorder.hasPermission()) {
      await _recorder.start(const RecordConfig(), path: 'audio.m4a');
    }
  }

  Future<String?> stopRecording() async {
    return await _recorder.stop();
  }

  Future<void> playAudio(String path) async {
    await _player.play(DeviceFileSource(path));
  }
}
```

### 3. 权限管理
```dart
// 使用 permission_handler
Future<bool> requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
  ].request();

  return statuses.values.every((status) => status.isGranted);
}
```

---

## 测试规范

### Widget 测试
```dart
// test/presentation/pages/conversation/conversation_page_test.dart
void main() {
  testWidgets('AgentCard displays agent information', (WidgetTester tester) async {
    final agent = AgentModel(
      id: '1',
      name: 'Test Agent',
      url: 'https://api.example.com',
      token: 'test_token',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentCard(agent: agent),
        ),
      ),
    );

    expect(find.text('Test Agent'), findsOneWidget);
    expect(find.text('https://api.example.com'), findsOneWidget);
  });
}
```

---

## 开发工作流

### 首次运行前的准备
```bash
# 1. 安装依赖
flutter pub get

# 2. 生成代码（Freezed, JSON）
dart run build_runner build --delete-conflicting-outputs

# 3. 运行应用
flutter run -d android
flutter run -d ios
```

### 常用命令
```bash
# 安装依赖
flutter pub get

# 代码生成（Freezed, JSON, Retrofit）
dart run build_runner build --delete-conflicting-outputs

# 监听模式代码生成（开发时推荐）
dart run build_runner watch --delete-conflicting-outputs

# 代码格式化
dart format lib/ test/

# 静态分析
flutter analyze

# 运行应用
flutter run -d android
flutter run -d ios

# 运行测试
flutter test
flutter test --coverage

# 构建 APK/IPA
flutter build apk --release
flutter build ios --release
```

### Git Commit 规范（约定式提交）
```
feat: 添加智能体配置页面
fix: 修复消息发送失败问题
style: 统一聊天气泡样式
refactor: 重构网络请求层
test: 添加 AgentCard 单元测试
docs: 更新 README 文档
```

---

## 性能优化建议

1. **使用 `const` 构造函数**：提高 Widget 复用性
2. **图片缓存**：使用 `cached_network_image`
3. **列表优化**：使用 `ListView.builder` 而非 `ListView`
4. **避免不必要的重建**：使用 `Key`、`const`、`ValueListenableBuilder`
5. **异步操作**：使用 `async/await` 而非 `then()`
6. **资源释放**：在 `dispose()` 中释放 `TextEditingController`、`AnimationController` 等

---

## 项目当前状态

### ✅ 已实现
- [x] 项目基础架构（Clean Architecture + MVVM）
- [x] 主题配置系统（浅色/深色主题）
- [x] 路由配置（GoRouter）
- [x] 网络层基础（Dio + 拦截器 + 异常处理）
- [x] 本地存储服务（SharedPreferences + Hive）
- [x] 工具类（Logger, Toast, Permission）
- [x] 数据模型（Agent, Message, User - 使用 Freezed）
- [x] 基础页面结构：
  - 主页面（底部导航：对话、设置）
  - 对话页面（智能体列表）
  - 聊天页面（基础 UI）
  - 智能体配置页面
  - 设置页面
- [x] Android 配置（权限声明、应用 ID）

### 🚧 待完善功能
- [ ] 运行代码生成器生成 Freezed 模型代码
- [ ] 实现智能体 CRUD 完整逻辑（使用 Riverpod）
- [ ] 实现多模态消息发送/接收
- [ ] 集成图片选择和上传
- [ ] 集成音频录制和播放
- [ ] 实现消息历史持久化
- [ ] 添加消息重发机制
- [ ] 实现网络状态监听
- [ ] 添加加载状态和错误处理 UI
- [ ] 实现主题切换功能
- [ ] iOS 配置和权限适配

### 📝 下一步操作
1. 运行 `flutter pub get` 安装所有依赖
2. 运行 `dart run build_runner build --delete-conflicting-outputs` 生成模型代码
3. 解决编译错误（主要是 Freezed 生成的代码）
4. 实现 Riverpod 状态管理 Provider
5. 测试基础页面导航
6. 逐步完善各个功能模块
