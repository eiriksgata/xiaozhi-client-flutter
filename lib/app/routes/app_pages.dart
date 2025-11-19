import 'package:go_router/go_router.dart';
import '../../presentation/pages/main/main_page.dart';
import '../../presentation/pages/conversation/conversation_page.dart';
import '../../presentation/pages/chat/chat_page.dart';
import '../../presentation/pages/agent_config/agent_config_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import 'app_routes.dart';

/// 应用路由配置
class AppPages {
  AppPages._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.main,
    routes: [
      // 主页面（包含底部导航）
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => const MainPage(),
      ),

      // 聊天详情页
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final agentId = state.uri.queryParameters['agentId'] ?? '';
          final agentName = state.uri.queryParameters['agentName'] ?? '';
          return ChatPage(
            agentId: agentId,
            agentName: agentName,
          );
        },
      ),

      // 智能体配置页
      GoRoute(
        path: AppRoutes.agentConfig,
        builder: (context, state) {
          final agentId = state.uri.queryParameters['agentId'];
          return AgentConfigPage(agentId: agentId);
        },
      ),
    ],
  );
}
