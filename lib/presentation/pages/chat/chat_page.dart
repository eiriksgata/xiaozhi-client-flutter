import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/message_model.dart';
import '../../../core/utils/toast_util.dart';
import 'widgets/message_list.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/voice_record_button.dart';

/// 聊天页面
class ChatPage extends ConsumerStatefulWidget {
  final String agentId;
  final String agentName;

  const ChatPage({
    super.key,
    required this.agentId,
    required this.agentName,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<MessageModel> _messages = [];
  bool _showVoiceButton = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
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
    _simulateAIResponse();
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
}
