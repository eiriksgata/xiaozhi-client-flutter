import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_model.freezed.dart';
part 'agent_model.g.dart';

/// 智能体模型
@freezed
class AgentModel with _$AgentModel {
  const factory AgentModel({
    required String id,
    required String name,
    required String url,
    required String token,
    String? avatar,
    @Default('') String description,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AgentModel;

  factory AgentModel.fromJson(Map<String, dynamic> json) =>
      _$AgentModelFromJson(json);
}
