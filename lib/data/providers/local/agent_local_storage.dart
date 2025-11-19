import 'dart:convert';
import '../../../core/storage/storage_service.dart';
import '../../../app/config/app_config.dart';
import '../../models/agent_model.dart';

/// 智能体本地存储
class AgentLocalStorage {
  final StorageService _storage;

  AgentLocalStorage(this._storage);

  /// 获取所有智能体
  Future<List<AgentModel>> getAgents() async {
    final String? jsonString = _storage.getString(AppConfig.keyAgentList);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => AgentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 根据 ID 获取智能体
  Future<AgentModel?> getAgentById(String id) async {
    final agents = await getAgents();
    try {
      return agents.firstWhere((agent) => agent.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 保存智能体
  Future<void> saveAgent(AgentModel agent) async {
    final agents = await getAgents();
    agents.add(agent);
    await _saveAgents(agents);
  }

  /// 更新智能体
  Future<void> updateAgent(AgentModel agent) async {
    final agents = await getAgents();
    final index = agents.indexWhere((a) => a.id == agent.id);
    if (index != -1) {
      agents[index] = agent;
      await _saveAgents(agents);
    }
  }

  /// 删除智能体
  Future<void> deleteAgent(String id) async {
    final agents = await getAgents();
    agents.removeWhere((agent) => agent.id == id);
    await _saveAgents(agents);
  }

  /// 清空所有智能体
  Future<void> clearAgents() async {
    await _storage.remove(AppConfig.keyAgentList);
  }

  /// 保存智能体列表
  Future<void> _saveAgents(List<AgentModel> agents) async {
    final jsonString =
        json.encode(agents.map((agent) => agent.toJson()).toList());
    await _storage.setString(AppConfig.keyAgentList, jsonString);
  }
}
