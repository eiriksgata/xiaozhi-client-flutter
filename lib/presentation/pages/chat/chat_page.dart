import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xiaozhi_client_flutter/core/network/xiaozhi_ota_service.dart';
import 'package:xiaozhi_client_flutter/core/network/xiaozhi_websocket_manager.dart';
import 'package:xiaozhi_client_flutter/core/providers/agent_provider.dart';
import 'package:xiaozhi_client_flutter/data/models/agent_model.dart';
import '../../../data/models/message_model.dart';
import '../../../core/utils/toast_util.dart';
import 'widgets/message_list.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/voice_record_button.dart';
import 'package:logging/logging.dart';

/// 聊天页面
class ChatPage extends ConsumerStatefulWidget {
  final String agentId;
  final String agentName;

  const ChatPage({super.key, required this.agentId, required this.agentName});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final Logger logger = Logger('ChatScreen');
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];
  bool _showVoiceButton = false;
  AgentModel? _currentAgent;

  // WebSocket 相关
  XiaozhiWebSocketManager? _wsManager;
  bool _isConnected = false;
  String _connectionStatus = '未连接';

  // OTA 认证信息
  XiaozhiOtaService? _otaService;

  @override
  void initState() {
    super.initState();
    _loadAgent();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _cleanupWebSocket();
    _otaService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.agentName),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: MessageList(
              messages: _messages,
              scrollController: _scrollController,
            ),
          ),

          // 输入区域（根据模式显示不同的组件）
          if (_showVoiceButton)
            _buildVoiceInputArea()
          else
            ChatInputBar(
              textController: _textController,
              onSendText: _sendTextMessage,
              onPickImage: _pickImage,
              onStartVoice: () {
                setState(() {
                  _showVoiceButton = true;
                });
              },
            ),
        ],
      ),
    );
  }

  /// 语音输入区域
  Widget _buildVoiceInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 切换回文本输入按钮
            IconButton(
              icon: const Icon(Icons.keyboard),
              onPressed: () {
                setState(() {
                  _showVoiceButton = false;
                });
              },
              tooltip: '切换到文本输入',
            ),

            // 按住说话按钮
            Expanded(
              child: VoiceRecordButton(
                onRecordStart: _onRecordStart,
                onRecordEnd: _onRecordEnd,
                onRecordCancel: _onRecordCancel,
              ),
            ),

            // 占位，保持对称
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  /// 发送文本消息
  void _sendTextMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      agentId: widget.agentId,
      type: MessageType.text,
      content: text,
      sender: MessageSender.user,
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
    });

    _textController.clear();
    _scrollToBottom();

    // TODO: 调用 API 发送消息
    //_simulateAIResponse();
  }
  
  void _appendOrCreateChatMessage(String role , String content) {
    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      agentId: widget.agentId,
      type: MessageType.text,
      content: content,
      sender: role == 'user' ? MessageSender.user : MessageSender.ai,
      status: MessageStatus.sent,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
    });

    _scrollToBottom();
  }

  /// 选择图片
  void _pickImage() {
    // TODO: 实现图片选择
    ToastUtil.show('图片功能开发中');
  }

  /// 开始录音
  void _onRecordStart() {
    ToastUtil.show('开始录音');
    // TODO: 实现录音功能
  }

  /// 结束录音（发送）
  void _onRecordEnd() {
    ToastUtil.show('录音结束，发送中');
    // TODO: 处理录音文件并发送
  }

  /// 取消录音
  void _onRecordCancel() {
    ToastUtil.show('已取消录音');
    // TODO: 删除录音文件
  }

  /// 显示更多选项
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('清空聊天记录'),
              onTap: () {
                Navigator.pop(context);
                _clearMessages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('智能体设置'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 跳转到智能体配置页面
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 清空消息
  void _clearMessages() {
    setState(() {
      _messages.clear();
    });
    ToastUtil.success('已清空聊天记录');
  }

  /// 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  /// 模拟 AI 回复（用于测试）
  void _simulateAIResponse() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final aiMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        agentId: widget.agentId,
        type: MessageType.text,
        content: '这是来自 ${widget.agentName} 的回复',
        sender: MessageSender.ai,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
      });

      _scrollToBottom();
    });
  }

  /// 加载智能体数据（编辑模式）
  Future<void> _loadAgent() async {
    final agent = await ref
        .read(agentListProvider.notifier)
        .getAgentById(widget.agentId);

    if (agent != null && mounted) {
      _currentAgent = agent;
    }
  }

  /// 清理 WebSocket 连接
  Future<void> _cleanupWebSocket() async {
    if (_wsManager != null) {
      await _wsManager!.disconnect();
      _wsManager = null;
    }
  }

  /// 显示错误提示
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 执行 OTA 认证获取 WebSocket 连接信息
  Future<bool> _performOtaAuthentication() async {
    try {
      setState(() {
        _connectionStatus = '正在认证...';
      });

      logger.info('开始 OTA 认证...');

      // 确保 OTA 服务已初始化
      if (_otaService == null) {
        logger.severe('OTA 服务未初始化');
        _showError('OTA 服务未初始化');
        return false;
      }

      // 调用 OTA API 获取 WebSocket 信息
      final otaResponse = await _otaService!.checkFlutterAppUpdates(
        appName: 'ajb_agent_flutter',
        appVersion: '1.0.0',
        acceptLanguage: 'zh-CN',
      );

      // 检查是否返回了 WebSocket 信息
      if (otaResponse.websocket != null) {
        if (otaResponse.activation != null) {
          final code = otaResponse.activation!.code;
          _appendOrCreateAssistantMessage(
            '设备需要在平台端注册，注册码:[$code]，注册成功后需重新进入对话',
          );
          _showError('认证失败: 设备未注册');
          setState(() {
            _connectionStatus = '认证失败';
          });
          return false;
        }

        logger.info('OTA 认证成功');
        return true;
      } else {
        logger.warning('OTA 响应中没有 WebSocket 信息');
        _showError('认证失败: 服务器未返回连接信息');
        setState(() {
          _connectionStatus = '认证失败';
        });
        return false;
      }
    } on OtaException catch (e) {
      logger.severe('OTA 认证失败: ${e.message}');
      _showError('认证失败: ${e.message}');
      setState(() {
        _connectionStatus = '认证失败';
      });
      return false;
    } catch (e, stackTrace) {
      logger.severe('OTA 认证异常: $e\n$stackTrace');
      _showError('认证异常: $e');
      setState(() {
        _connectionStatus = '认证异常';
      });
      return false;
    }
  }

  /// 初始化 WebSocket 连接
  Future<void> _initializeWebSocket() async {
    if (_currentAgent == null) {
      logger.warning('当前智能体为空，无法初始化 WebSocket');
      return;
    }

    try {
      // 第一步: 执行 OTA 认证
      final authSuccess = await _performOtaAuthentication();
      if (!authSuccess) {
        logger.warning('OTA 认证失败,取消 WebSocket 连接');
        return;
      }

      // 第二步: 获取设备ID
      final deviceId = await DeviceUtil.getDeviceId();

      print(_currentAgent);
      // 第三步: 创建 WebSocket 管理器
      _wsManager = XiaozhiWebSocketManager(
        deviceId: deviceId,
        enableToken: false,
        wsProtocol: _currentAgent?.wsProtocols ?? 'XIAOZHI',
      );

      // 第四步: 添加事件监听器
      _wsManager!.addListener(_handleWebSocketEvent);

      // 第五步: 使用Agent配置 wsUrl 和 wsToken 连接服务器
      await _connectToWebSocket(_currentAgent?.wsUrl ?? '', 'test-token');
    } catch (e) {
      logger.severe('初始化 WebSocket 失败: $e');
      _showError('连接初始化失败: $e');
    }
  }

  /// 使用指定的 URL 和 Token 连接 WebSocket
  Future<void> _connectToWebSocket(String url, String token) async {
    if (_wsManager == null) return;

    setState(() {
      _connectionStatus = '正在连接...';
    });

    try {
      await _wsManager!.connect(url, token);
      logger.info('WebSocket 连接请求已发送');
    } catch (e) {
      logger.severe('WebSocket 连接失败: $e');
      setState(() {
        _connectionStatus = '连接失败';
      });
      _showError('连接失败: $e');
    }
  }

  /// 处理 WebSocket 事件
  void _handleWebSocketEvent(XiaozhiEvent event) {
    if (!mounted) return;

    switch (event.type) {
      case XiaozhiEventType.connected:
        setState(() {
          _isConnected = true;
          _connectionStatus = '已连接';
        });
        logger.info('WebSocket 已连接');
        //_addConnectionStatusMessage('已连接到服务器');
        break;

      case XiaozhiEventType.disconnected:
        setState(() {
          _isConnected = false;
          _connectionStatus = '已断开';
        });
        logger.info('WebSocket 已断开');
        //_addConnectionStatusMessage('与服务器断开连接');
        break;

      case XiaozhiEventType.message:
        _handleTextMessage(event.data as String);
        break;

      case XiaozhiEventType.binaryMessage:
        _handleBinaryMessage(event.data as List<int>);
        break;

      case XiaozhiEventType.error:
        logger.severe('WebSocket 错误: ${event.data}');
        _showError('连接错误: ${event.data}');
        break;
    }
  }
}
