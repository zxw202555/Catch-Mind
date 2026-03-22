import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/preset_tags.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';
import '../theme/catchmind_theme.dart';

/// 居中「小窗」新建事项（默认仅输入框，可展开标签与 DDL）
Future<void> showAddTaskDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withAlpha(89),
    builder: (ctx) => const _AddTaskDialogBody(),
  );
}

/// 编辑现有任务
Future<void> showEditTaskDialog(BuildContext context, Task task) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withAlpha(89),
    builder: (ctx) => _EditTaskDialogBody(task: task),
  );
}

class _AddTaskDialogBody extends StatefulWidget {
  const _AddTaskDialogBody();

  @override
  State<_AddTaskDialogBody> createState() => _AddTaskDialogBodyState();
}

class _AddTaskDialogBodyState extends State<_AddTaskDialogBody> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String _tag;
  late String _emoji;
  late String _tagColor;
  DateTime? _ddl;
  bool _ddlNone = true;
  bool _moreOptions = true; // 默认展开

  List<TagPreset> _allTagChoices() {
    final box = Hive.box<String>('custom_tags');
    final custom = box.toMap().entries.map((e) {
      final parts = e.value.split('|');
      final emoji = parts.isNotEmpty ? parts[0] : '✨';
      final hex = parts.length > 1 ? parts[1] : '#607D8B';
      return TagPreset(name: e.key, emoji: emoji, colorHex: hex);
    });
    return [...kPresetTags, ...custom];
  }

  @override
  void initState() {
    super.initState();
    final first = kPresetTags.first;
    _tag = first.name;
    _emoji = first.emoji;
    _tagColor = first.colorHex;
    _ddlNone = true;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
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

  void _save() {
    if (_formKey.currentState?.validate() != true) return;

    final bool noDdl = !_moreOptions || _ddlNone;
    
    final isDiary = _tag == '感悟复盘';
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _contentController.text.trim(),
      tag: _tag,
      emoji: _emoji,
      tagColor: _tagColor,
      ddl: noDdl ? null : _ddl,
      isMustDo: false,
      quadrant: 'not_classified',
      createdAt: DateTime.now(),
      review: null,
      routed: isDiary,
    );

    final messenger = ScaffoldMessenger.of(context);
    Provider.of<TaskProvider>(context, listen: false).addTask(task);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('已保存')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final choices = _allTagChoices();
    final ddlLabel = _ddlNone
        ? '无'
        : (_ddl != null
            ? DateFormat('M月d日 HH:mm', 'zh_CN').format(_ddl!)
            : '未选择');

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '✨ 捕捉你的想法',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CatchMindColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '输入你的事项…',
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '请输入内容';
                      return null;
                    },
                  ),
                  if (_moreOptions) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: choices.any((c) => c.name == _tag)
                          ? _tag
                          : choices.first.name,
                      decoration: const InputDecoration(
                        labelText: '标签',
                        isDense: true,
                      ),
                      items: choices
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.name,
                              child: Text('${c.emoji} ${c.name}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        final c = choices.firstWhere((e) => e.name == v);
                        setState(() {
                          _tag = c.name;
                          _emoji = c.emoji;
                          _tagColor = c.colorHex;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ddl：$ddlLabel',
                            style: const TextStyle(
                              fontSize: 14,
                              color: CatchMindColors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _pickDdl,
                          child: Text('选择', style: TextStyle(color: accent)),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _ddlNone = true;
                            _ddl = null;
                          }),
                          child: Text(
                            '清除',
                            style: TextStyle(
                              color: CatchMindColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () =>
                          setState(() => _moreOptions = !_moreOptions),
                      icon: Icon(
                        _moreOptions ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: accent,
                      ),
                      label: Text(
                        _moreOptions ? '收起标签与截止时间' : '标签与截止时间',
                        style: TextStyle(color: accent, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('取消', style: TextStyle(color: accent)),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('保存'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditTaskDialogBody extends StatefulWidget {
  final Task task;

  const _EditTaskDialogBody({required this.task});

  @override
  State<_EditTaskDialogBody> createState() => _EditTaskDialogBodyState();
}

class _EditTaskDialogBodyState extends State<_EditTaskDialogBody> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String _tag;
  late String _emoji;
  late String _tagColor;
  DateTime? _ddl;
  bool _ddlNone = true;
  bool _moreOptions = true; // 默认展开

  List<TagPreset> _allTagChoices() {
    final box = Hive.box<String>('custom_tags');
    final custom = box.toMap().entries.map((e) {
      final parts = e.value.split('|');
      final emoji = parts.isNotEmpty ? parts[0] : '✨';
      final hex = parts.length > 1 ? parts[1] : '#607D8B';
      return TagPreset(name: e.key, emoji: emoji, colorHex: hex);
    });
    return [...kPresetTags, ...custom];
  }

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.task.content;
    _tag = widget.task.tag;
    _emoji = widget.task.emoji;
    _tagColor = widget.task.tagColor;
    _ddl = widget.task.ddl;
    _ddlNone = widget.task.ddl == null;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickDdl() async {
    final initialDate = _ddl ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (date == null || !mounted) return;
    final initialTime = _ddl != null 
        ? TimeOfDay(hour: _ddl!.hour, minute: _ddl!.minute) 
        : TimeOfDay.now();
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
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

  void _save() {
    if (_formKey.currentState?.validate() != true) return;

    final bool noDdl = !_moreOptions || _ddlNone;
    
    final updatedTask = widget.task.copyWith(
      content: _contentController.text.trim(),
      tag: _tag,
      emoji: _emoji,
      tagColor: _tagColor,
      ddl: noDdl ? null : _ddl,
    );

    final messenger = ScaffoldMessenger.of(context);
    Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('已更新')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final choices = _allTagChoices();
    final ddlLabel = _ddlNone
        ? '无'
        : (_ddl != null
            ? DateFormat('M月d日 HH:mm', 'zh_CN').format(_ddl!)
            : '未选择');

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '✨ 编辑事项',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CatchMindColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '输入你的事项…',
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '请输入内容';
                      return null;
                    },
                  ),
                  if (_moreOptions) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: choices.any((c) => c.name == _tag)
                          ? _tag
                          : choices.first.name,
                      decoration: const InputDecoration(
                        labelText: '标签',
                        isDense: true,
                      ),
                      items: choices
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.name,
                              child: Text('${c.emoji} ${c.name}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        final c = choices.firstWhere((e) => e.name == v);
                        setState(() {
                          _tag = c.name;
                          _emoji = c.emoji;
                          _tagColor = c.colorHex;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ddl：$ddlLabel',
                            style: const TextStyle(
                              fontSize: 14,
                              color: CatchMindColors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _pickDdl,
                          child: Text('选择', style: TextStyle(color: accent)),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _ddlNone = true;
                            _ddl = null;
                          }),
                          child: Text(
                            '清除',
                            style: TextStyle(
                              color: CatchMindColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () =>
                          setState(() => _moreOptions = !_moreOptions),
                      icon: Icon(
                        _moreOptions ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                        color: accent,
                      ),
                      label: Text(
                        _moreOptions ? '收起标签与截止时间' : '标签与截止时间',
                        style: TextStyle(color: accent, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('取消', style: TextStyle(color: accent)),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('保存'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
