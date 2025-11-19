import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../data/models/message_model.dart';
import '../../../../app/themes/app_colors.dart';

/// 聊天消息气泡组件
class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  bool get isUser => message.sender == MessageSender.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageContent(context),
                const SizedBox(height: 4),
                _buildTimestamp(),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  /// 头像
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 18,
      backgroundColor: isUser ? AppColors.primary : AppColors.secondary,
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  /// 消息内容
  Widget _buildMessageContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser
            ? (isDark ? AppColors.userMessageBgDark : AppColors.userMessageBg)
            : (isDark ? AppColors.aiMessageBgDark : AppColors.aiMessageBg),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildContentByType(),
    );
  }

  /// 根据消息类型构建内容
  Widget _buildContentByType() {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: const TextStyle(fontSize: 15),
        );

      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: message.content,
            width: 200,
            placeholder: (context, url) => const SizedBox(
              width: 200,
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );

      case MessageType.audio:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle_outline, size: 24),
            const SizedBox(width: 8),
            Text(message.content),
          ],
        );

      case MessageType.system:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        );
    }
  }

  /// 时间戳
  Widget _buildTimestamp() {
    final time = message.timestamp;
    final timeStr = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    
    return Text(
      timeStr,
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey[600],
      ),
    );
  }
}
