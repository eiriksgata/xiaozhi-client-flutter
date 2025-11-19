import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

/// 消息类型
enum MessageType {
  text,
  image,
  audio,
  system,
}

/// 消息发送者
enum MessageSender {
  user,
  ai,
  system,
}

/// 消息状态
enum MessageStatus {
  sending,
  sent,
  failed,
  received,
}

/// 消息模型
@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String content,
    required MessageType type,
    required MessageSender sender,
    required DateTime timestamp,
    @Default(MessageStatus.sent) MessageStatus status,
    String? agentId,
    String? agentName,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}
