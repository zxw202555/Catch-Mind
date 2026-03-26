import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_providers.dart';
import '../providers/language_provider.dart';
import 'add_task_dialog.dart';
import 'task_card.dart';

/// 长按可拖拽；左右滑：推迟 / 完成（与拖拽手势不冲突）
class TaskInteractive extends StatelessWidget {
  final Task task;
  final TaskProvider provider;
  final bool enableLongPressDrag;

  const TaskInteractive({
    super.key,
    required this.task,
    required this.provider,
    this.enableLongPressDrag = true,
  });

  Widget _card() {
    return TaskCard(
      task: task,
    );
  }

  Widget _maybeDrag(Widget child) {
    if (!enableLongPressDrag) return child;
    return LongPressDraggable<Task>(
      data: task,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 300,
          child: TaskCard(
            task: task,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.45,
        child: TaskCard(
          task: task,
        ),
      ),
      delay: const Duration(milliseconds: 200), // 减少长按时间，使判定更简单
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _maybeDrag(
      GestureDetector(
        onTap: () {
          showEditTaskDialog(context, task);
        },
        onDoubleTap: () {
          provider.markTaskCompleted(task);
        },
        onSecondaryTap: () {
          _deleteTask(context);
        },
        child: _card(),
      ),
    );
  }

  Future<void> _deleteTask(BuildContext context) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final l10n = AppLocalizations(languageProvider.currentLanguage);
    
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.deleteTaskTitle),
          content: Text('${l10n.deleteTaskConfirm} "${task.content}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.dialogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      provider.deleteTask(task);
    }
  }
}
