import 'package:flutter/material.dart';

/// 聊天输入栏组件
class ChatInputBar extends StatefulWidget {
  final TextEditingController textController;
  final VoidCallback onSendText;
  final VoidCallback onPickImage;
  final VoidCallback onStartVoice;

  const ChatInputBar({
    super.key,
    required this.textController,
    required this.onSendText,
    required this.onPickImage,
    required this.onStartVoice,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 语音按钮
            IconButton(
              icon: const Icon(Icons.mic_outlined),
              onPressed: widget.onStartVoice,
              tooltip: '按住说话',
            ),
            // 图片按钮
            IconButton(
              icon: const Icon(Icons.image_outlined),
              onPressed: widget.onPickImage,
              tooltip: '发送图片',
            ),

            // 输入框
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[100]
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: widget.textController,
                  decoration: const InputDecoration(
                    hintText: '输入消息...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (_hasText) {
                      widget.onSendText();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(width: 4),

            // 发送按钮
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _hasText ? widget.onSendText : null,
              tooltip: '发送',
              color: _hasText
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
