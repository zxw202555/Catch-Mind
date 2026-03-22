import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_providers.dart';
import '../widgets/tag_selector.dart';

/// 分步：内容 → 标签 → DDL（可无）
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _pageController = PageController();
  int _step = 0;

  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _tag = '工作事业';
  String _emoji = '💼';
  String _tagColor = '#008080';

  DateTime? _ddl;
  bool _ddlNone = false;

  void _next() {
    if (_step == 0) {
      if (_formKey.currentState?.validate() != true) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }
    if (_step == 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return;
    }
  }

  void _back() {
    if (_step > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _submit() {
    final isDiary = _tag == '感悟复盘';
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _contentController.text.trim(),
      tag: _tag,
      emoji: _emoji,
      tagColor: _tagColor,
      ddl: _ddlNone ? null : _ddl,
      isMustDo: false,
      quadrant: 'not_classified',
      createdAt: DateTime.now(),
      review: null,
      routed: isDiary,
    );

    Provider.of<TaskProvider>(context, listen: false).addTask(task);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已保存'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Future<void> _pickDdl() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;
    setState(() {
      _ddlNone = false;
      _ddl = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle()),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / 3,
            backgroundColor: Colors.grey[200],
            color: Colors.teal,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _step = i),
              children: [
                _buildStepContent(),
                _buildStepTag(),
                _buildStepDdl(),
              ],
            ),
          ),
          _buildNavBar(),
        ],
      ),
    );
  }

  String _stepTitle() {
    switch (_step) {
      case 0:
        return '写一件事';
      case 1:
        return '选标签';
      default:
        return '截止时间';
    }
  }

  Widget _buildStepContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '先把脑子里的念头丢进来，减轻负荷。',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: '事项内容',
                border: OutlineInputBorder(),
                hintText: '例如：写完周报、买牛奶…',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '请输入内容';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTag() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '用颜色和表情区分领域，之后可以按标签合并查看。',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TagSelector(
            initialTag: _tag,
            onTagSelected: (tag, emoji, color) {
              setState(() {
                _tag = tag;
                _emoji = emoji;
                _tagColor = color;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepDdl() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '可选截止时间；选「无」表示不设期限。',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          if (_ddlNone)
            const Text('当前：无截止时间', style: TextStyle(fontSize: 16))
          else if (_ddl != null)
            Text(
              '当前：${_ddl!.year}年${_ddl!.month}月${_ddl!.day}日 '
              '${TimeOfDay.fromDateTime(_ddl!).format(context)}',
              style: const TextStyle(fontSize: 16),
            )
          else
            const Text('尚未选择', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.tonal(
                onPressed: _pickDdl,
                child: const Text('选择日期与时间'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => setState(() {
                  _ddlNone = true;
                  _ddl = null;
                }),
                child: const Text('无'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_step > 0)
              TextButton(onPressed: _back, child: const Text('上一步'))
            else
              const SizedBox(width: 64),
            const Spacer(),
            if (_step < 2)
              FilledButton(
                onPressed: _next,
                style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('下一步'),
              )
            else
              FilledButton(
                onPressed: () {
                  if (!_ddlNone && _ddl == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('请选择时间或点「无」')),
                    );
                    return;
                  }
                  _submit();
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('完成'),
              ),
          ],
        ),
      ),
    );
  }
}
