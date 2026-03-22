import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_providers.dart';
import '../theme/catchmind_theme.dart';
import '../widgets/task_interactive.dart';

class NonMustDoScreen extends StatefulWidget {
  const NonMustDoScreen({super.key});

  @override
  State<NonMustDoScreen> createState() => _NonMustDoScreenState();
}

class _NonMustDoScreenState extends State<NonMustDoScreen> {
  bool _isMerged = false;

  Widget _buildNormalList(List<Task> tasks, TaskProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskInteractive(task: task, provider: provider);
      },
    );
  }

  Widget _buildMergedList(
    Map<String, List<Task>> grouped,
    TaskProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final tag = grouped.keys.elementAt(index);
        final tasks = grouped[tag]!;
        final tagColor =
            Color(int.parse(tasks.first.tagColor.replaceFirst('#', '0xFF')));

        return ExpansionTile(
          title: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$tag (${tasks.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: CatchMindColors.accent,
                ),
              ),
            ],
          ),
          children: tasks
              .map((t) => TaskInteractive(task: t, provider: provider))
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.nonMustDoTasks;

    final grouped = <String, List<Task>>{};
    for (final t in tasks) {
      grouped.putIfAbsent(t.tag, () => []).add(t);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '非必须',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: CatchMindColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isMerged ? Icons.merge_type : Icons.view_list,
                      color: CatchMindColors.accent,
                    ),
                    onPressed: () => setState(() => _isMerged = !_isMerged),
                    tooltip: _isMerged ? '取消合并' : '按标签合并',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
        Expanded(
          child: tasks.isEmpty
              ? const Center(
                  child: Text(
                    '暂无事项',
                    style: TextStyle(
                      color: CatchMindColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                )
              : _isMerged
                  ? _buildMergedList(grouped, taskProvider)
                  : _buildNormalList(tasks, taskProvider),
        ),
      ],
    );
  }
}
