import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_providers.dart';
import '../providers/language_provider.dart';
import '../theme/catchmind_theme.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_card.dart';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key});

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {

  void _acceptDropToDelete(Task task, TaskProvider p, AppLocalizations l10n) {
    p.deleteTask(task);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.snackbarDeleted),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _acceptDropToMust(Task task, TaskProvider p) {
    p.updateTask(
      task.copyWith(
        isMustDo: true,
      ),
    );
  }

  void _acceptDropToNonMust(Task task, TaskProvider p) {
    p.updateTask(
      task.copyWith(
        isMustDo: false,
      ),
    );
  }

  Widget _deleteStrip(TaskProvider provider, AppLocalizations l10n) {
    return Consumer<TaskProvider>(
      builder: (context, p, _) {
        return DragTarget<Task>(
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (d) => _acceptDropToDelete(d.data, p, l10n),
          builder: (context, candidate, _) {
            final active = candidate.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: active
                    ? Colors.red.withOpacity(0.2)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active
                      ? Colors.red.withAlpha(140)
                      : Colors.red.withAlpha(80),
                  width: active ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: active ? Colors.red : Colors.red.withAlpha(180),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    active ? l10n.dragToDeleteActive : l10n.dragToDelete,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: active ? Colors.red : Colors.red.withAlpha(180),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _categoryBox({
    required String title,
    required IconData icon,
    required Color color,
    required List<Task> tasks,
    required TaskProvider provider,
    required void Function(Task, TaskProvider) onAccept,
    required AppLocalizations l10n,
  }) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => onAccept(d.data, provider),
      builder: (context, candidate, _) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: active
                ? Color.lerp(color, CatchMindColors.dragStripActive, 0.55) ?? color
                : color,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active
                  ? CatchMindColors.accent.withAlpha(89)
                  : CatchMindColors.hairline,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: CatchMindColors.textPrimary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CatchMindColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 16, thickness: 0.5),
              if (tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      l10n.emptyState,
                      style: const TextStyle(
                        color: CatchMindColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else
                ...tasks.map((task) => _taskItem(task, provider, l10n)),
            ],
          ),
        );
      },
    );
  }

  Widget _taskItem(Task task, TaskProvider p, AppLocalizations l10n) {
    return LongPressDraggable<Task>(
      data: task,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 300,
          child: TaskCard(
            task: task,
            isCompleted: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.45,
        child: TaskCard(
          task: task,
          isCompleted: true,
        ),
      ),
      delay: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: () {
          showEditTaskDialog(context, task);
        },
        onDoubleTap: () {
          p.markTaskIncomplete(task);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.snackbarRestored),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        child: TaskCard(
          task: task,
          isCompleted: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TaskProvider, LanguageProvider>(
      builder: (context, p, languageProvider, _) {
        final l10n = AppLocalizations(languageProvider.currentLanguage);
        final tasks = p.completedTasks;

        final mustDoTasks = tasks.where((t) => t.isMustDo).toList();
        final nonMustDoTasks = tasks.where((t) => !t.isMustDo).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.titleCompleted,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: CatchMindColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  // 语言切换按钮
                  IconButton(
                    icon: const Icon(
                      Icons.language,
                      color: CatchMindColors.accent,
                    ),
                    onPressed: () => languageProvider.toggleLanguage(),
                    tooltip: l10n.languageSwitch,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.completedHint,
                style: const TextStyle(
                  fontSize: 12,
                  color: CatchMindColors.textSecondary,
                ),
              ),
            ),
            const Divider(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _categoryBox(
                        title: l10n.completedMustDo,
                        icon: Icons.check_circle,
                        color: CatchMindColors.qImportantUrgent,
                        tasks: mustDoTasks,
                        provider: p,
                        onAccept: _acceptDropToMust,
                        l10n: l10n,
                      ),
                    ),
                    Expanded(
                      child: _categoryBox(
                        title: l10n.completedNonMustDo,
                        icon: Icons.more_horiz,
                        color: CatchMindColors.qNotImportantNotUrgent,
                        tasks: nonMustDoTasks,
                        provider: p,
                        onAccept: _acceptDropToNonMust,
                        l10n: l10n,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _deleteStrip(p, l10n),
          ],
        );
      },
    );
  }
}
