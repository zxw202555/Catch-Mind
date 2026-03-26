import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/preset_tags.dart';
import '../models/task.dart';
import '../providers/task_providers.dart';
import '../providers/language_provider.dart';
import '../theme/catchmind_theme.dart';
import './tag_selector.dart';

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

  @override
  void initState() {
    super.initState();
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final l10n = AppLocalizations(languageProvider.currentLanguage);
    
    // 根据语言选择默认标签
    final first = kPresetTags.first;
    _tag = first.name;
    _emoji = first.emoji;
    _tagColor = first.colorHex;
    _ddlNone = _ddl == null;
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
    
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final l10n = AppLocalizations(languageProvider.currentLanguage);
    
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
      SnackBar(content: Text(l10n.snackbarSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations(languageProvider.currentLanguage);
    
    final dateFormat = l10n.isEnglish ? 'MMM d, HH:mm' : 'M月d日 HH:mm';
    final dateLocale = l10n.isEnglish ? 'en_US' : 'zh_CN';
    final ddlLabel = _ddlNone
        ? l10n.dialogDeadlineNone
        : (_ddl != null
            ? DateFormat(dateFormat, dateLocale).format(_ddl!)
            : l10n.dialogDeadlineNotSelected);

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
                  Text(
                    l10n.dialogAddTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CatchMindColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.dialogHint,
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return l10n.dialogContentRequired;
                      return null;
                    },
                  ),
                  if (_moreOptions) ...[
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
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${l10n.dialogDeadline}：$ddlLabel',
                            style: const TextStyle(
                              fontSize: 14,
                              color: CatchMindColors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _pickDdl,
                          child: Text(l10n.dialogSelect, style: TextStyle(color: accent)),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _ddlNone = true;
                            _ddl = null;
                          }),
                          child: Text(
                            l10n.dialogClear,
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
                        _moreOptions ? l10n.dialogCollapse : l10n.dialogExpand,
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
                        child: Text(l10n.dialogCancel, style: TextStyle(color: accent)),
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
                        child: Text(l10n.dialogSave),
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
  final _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String _tag;
  late String _emoji;
  late String _tagColor;
  DateTime? _ddl;
  bool _ddlNone = true;
  bool _moreOptions = true; // 默认展开
  bool _showReview = false; // 是否显示复盘输入

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.task.content;
    _reviewController.text = widget.task.review ?? '';
    _tag = widget.task.tag;
    _emoji = widget.task.emoji;
    _tagColor = widget.task.tagColor;
    _ddl = widget.task.ddl;
    _ddlNone = widget.task.ddl == null;
    _showReview = widget.task.isCompleted; // 已完成的任务显示复盘
  }

  @override
  void dispose() {
    _contentController.dispose();
    _reviewController.dispose();
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
    
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final l10n = AppLocalizations(languageProvider.currentLanguage);
    
    final updatedTask = widget.task.copyWith(
      content: _contentController.text.trim(),
      tag: _tag,
      emoji: _emoji,
      tagColor: _tagColor,
      ddl: noDdl ? null : _ddl,
      review: _reviewController.text.trim(),
    );

    final messenger = ScaffoldMessenger.of(context);
    Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.snackbarUpdated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations(languageProvider.currentLanguage);
    
    final dateFormat = l10n.isEnglish ? 'MMM d, HH:mm' : 'M月d日 HH:mm';
    final dateLocale = l10n.isEnglish ? 'en_US' : 'zh_CN';
    final ddlLabel = _ddlNone
        ? l10n.dialogDeadlineNone
        : (_ddl != null
            ? DateFormat(dateFormat, dateLocale).format(_ddl!)
            : l10n.dialogDeadlineNotSelected);

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
                  Text(
                    l10n.dialogEditTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CatchMindColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.dialogHint,
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return l10n.dialogContentRequired;
                      return null;
                    },
                  ),
                  if (_moreOptions) ...[
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
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${l10n.dialogDeadline}：$ddlLabel',
                            style: const TextStyle(
                              fontSize: 14,
                              color: CatchMindColors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _pickDdl,
                          child: Text(l10n.dialogSelect, style: TextStyle(color: accent)),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _ddlNone = true;
                            _ddl = null;
                          }),
                          child: Text(
                            l10n.dialogClear,
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
                        _moreOptions ? l10n.dialogCollapse : l10n.dialogExpand,
                        style: TextStyle(color: accent, fontSize: 13),
                      ),
                    ),
                  ),
                  if (_showReview) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.dialogReview,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CatchMindColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _reviewController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l10n.dialogReviewHint,
                        isDense: true,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.dialogCancel, style: TextStyle(color: accent)),
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
                        child: Text(l10n.dialogSave),
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
