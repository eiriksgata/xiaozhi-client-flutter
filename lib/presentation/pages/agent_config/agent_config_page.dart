import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/agent_model.dart';
import '../../../core/providers/agent_provider.dart';
import '../../../core/utils/toast_util.dart';

/// 智能体配置页面
class AgentConfigPage extends ConsumerStatefulWidget {
  final String? agentId;

  const AgentConfigPage({super.key, this.agentId});

  @override
  ConsumerState<AgentConfigPage> createState() => _AgentConfigPageState();
}

class _AgentConfigPageState extends ConsumerState<AgentConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _tokenController = TextEditingController(text: 'to-test'); // 设置默认值
  final _descriptionController = TextEditingController();
  final _otaController = TextEditingController();
  bool _isLoading = false;

  bool get isEdit => widget.agentId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _loadAgent();
    }
  }

  /// 加载智能体数据（编辑模式）
  Future<void> _loadAgent() async {
    if (widget.agentId == null) return;

    final agent = await ref
        .read(agentListProvider.notifier)
        .getAgentById(widget.agentId!);

    if (agent != null && mounted) {
      setState(() {
        _nameController.text = agent.name;
        _urlController.text = agent.url;
        _tokenController.text = agent.token;
        _descriptionController.text = agent.description;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _tokenController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '编辑智能体' : '添加智能体'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 名称
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '名称',
                hintText: '例如：GPT-4',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入智能体名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // URL
            TextFormField(
              controller: _otaController,
              decoration: const InputDecoration(
                labelText: 'ota 地址',
                hintText: 'https://api.example.com/v1/ota',
              ),
            ),
            const SizedBox(height: 16),

            // URL
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'API 地址',
                hintText: 'https://api.example.com',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入 API 地址';
                }
                if (!value.startsWith('http://') &&
                    !value.startsWith('https://')) {
                  return '请输入有效的 URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Token
            TextFormField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Token',
                hintText: '输入 API Token',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入 Token';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 描述
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述（可选）',
                hintText: '简单描述这个智能体',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final agent = AgentModel(
        id: widget.agentId ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        url: _urlController.text.trim(),
        token: _tokenController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEdit) {
        await ref.read(agentListProvider.notifier).updateAgent(agent);
        if (mounted) {
          ToastUtil.success('智能体更新成功');
        }
      } else {
        await ref.read(agentListProvider.notifier).addAgent(agent);
        if (mounted) {
          ToastUtil.success('智能体添加成功');
        }
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.error('保存失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
