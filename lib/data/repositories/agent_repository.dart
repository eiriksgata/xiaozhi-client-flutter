import '../models/agent_model.dart';
import '../providers/local/agent_local_storage.dart';

/// 智能体数据仓库
class AgentRepository {
  final AgentLocalStorage _localStorage;

  AgentRepository(this._localStorage);

  /// 获取所有智能体
  Future<List<AgentModel>> getAgents() async {
    return await _localStorage.getAgents();
  }

  /// 根据 ID 获取智能体
  Future<AgentModel?> getAgentById(String id) async {
    return await _localStorage.getAgentById(id);
  }

  /// 保存智能体
  Future<void> saveAgent(AgentModel agent) async {
    await _localStorage.saveAgent(agent);
  }

  /// 更新智能体
  Future<void> updateAgent(AgentModel agent) async {
    await _localStorage.updateAgent(agent);
  }

  /// 删除智能体
  Future<void> deleteAgent(String id) async {
    await _localStorage.deleteAgent(id);
  }

  /// 清空所有智能体
  Future<void> clearAgents() async {
    await _localStorage.clearAgents();
  }
}
