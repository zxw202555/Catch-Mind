import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_providers.dart';
import '../providers/language_provider.dart';
import '../theme/catchmind_theme.dart';
import '../widgets/task_interactive.dart';

class NonMustDoScreen extends StatefulWidget {
  const NonMustDoScreen({super.key});

  @override
  State<NonMustDoScreen> createState() => _NonMustDoScreenState();
}

class _NonMustDoScreenState extends State<NonMustDoScreen> {
  bool _isMerged = false;

  void _acceptDropToExperience(Task task, TaskProvider p) {
    p.updateTask(
      task.copyWith(
        quadrant: 'experience',
        routed: true,
        isMustDo: false,
      ),
    );
  }

  void _acceptDropToDevelopment(Task task, TaskProvider p) {
    p.updateTask(
      task.copyWith(
        quadrant: 'development',
        routed: true,
        isMustDo: false,
      ),
    );
  }

  Widget _categoryBox({
    required String title,
    required String emoji,
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
                  Text(emoji, style: const TextStyle(fontSize: 20)),
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
                ...tasks.map((t) => TaskInteractive(
                      task: t,
                      provider: provider,
                    )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations(languageProvider.currentLanguage);
    final tasks = taskProvider.nonMustDoTasks;

    // 确保所有非必须任务都有象限，默认为体验一下
    for (var task in tasks) {
      if (task.quadrant != 'experience' && task.quadrant != 'development') {
        taskProvider.updateTask(
          task.copyWith(
            quadrant: 'experience',
          ),
        );
      }
    }

    final experienceTasks = tasks.where((t) => t.quadrant == 'experience').toList();
    final developmentTasks = tasks.where((t) => t.quadrant == 'development').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.titleNonMustDo,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: CatchMindColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Row(
                children: [
                  // 语言切换按钮
                  IconButton(
                    icon: const Icon(
                      Icons.language,
                      color: CatchMindColors.accent,
                    ),
                    onPressed: () => languageProvider.toggleLanguage(),
                    tooltip: l10n.languageSwitch,
                  ),
                  IconButton(
                    icon: Icon(
                      _isMerged ? Icons.merge_type : Icons.view_list,
                      color: CatchMindColors.accent,
                    ),
                    onPressed: () => setState(() => _isMerged = !_isMerged),
                    tooltip: _isMerged ? l10n.tooltipUnmerge : l10n.tooltipMerge,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _categoryBox(
                    title: l10n.categoryExperience,
                    emoji: '🎯',
                    color: CatchMindColors.qUrgentNotImportant,
                    tasks: experienceTasks,
                    provider: taskProvider,
                    onAccept: _acceptDropToExperience,
                    l10n: l10n,
                  ),
                ),
                Expanded(
                  child: _categoryBox(
                    title: l10n.categoryDevelopment,
                    emoji: '📈',
                    color: CatchMindColors.qImportantNotUrgent,
                    tasks: developmentTasks,
                    provider: taskProvider,
                    onAccept: _acceptDropToDevelopment,
                    l10n: l10n,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
