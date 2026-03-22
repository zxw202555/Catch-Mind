import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_providers.dart';
import '../theme/catchmind_theme.dart';
import '../widgets/task_interactive.dart';

class MustDoScreen extends StatefulWidget {
  const MustDoScreen({super.key});

  @override
  State<MustDoScreen> createState() => _MustDoScreenState();
}

class _MustDoScreenState extends State<MustDoScreen> {
  bool _isMerged = false;

  Color _quadrantBg(String name) {
    switch (name) {
      case '重要紧急':
        return CatchMindColors.qImportantUrgent;
      case '重要不紧急':
        return CatchMindColors.qImportantNotUrgent;
      case '不重要紧急':
        return CatchMindColors.qUrgentNotImportant;
      case '不重要不紧急':
        return CatchMindColors.qNotImportantNotUrgent;
      default:
        return CatchMindColors.quadrantSurface;
    }
  }

  void _onDropInQuadrant(Task task, String quadrantName, TaskProvider p) {
    p.updateTask(
      task.copyWith(
        routed: true,
        isMustDo: true,
        quadrant: quadrantName,
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已归入「$quadrantName」'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildQuadrant(
    String quadrantName,
    TaskProvider provider,
  ) {
    final tasks = provider.mustDoTasks
        .where((t) => t.quadrant == quadrantName)
        .toList();

    final grouped = <String, List<Task>>{};
    for (final t in tasks) {
      grouped.putIfAbsent(t.tag, () => []).add(t);
    }

    return DragTarget<Task>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) =>
          _onDropInQuadrant(d.data, quadrantName, provider),
      builder: (context, candidate, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          decoration: BoxDecoration(
            color: candidate.isNotEmpty
                ? Color.lerp(
                    _quadrantBg(quadrantName),
                    CatchMindColors.dragStripActive,
                    0.55,
                  )!
                : _quadrantBg(quadrantName),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: candidate.isNotEmpty
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
              Text(
                quadrantName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CatchMindColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              const Divider(height: 10, thickness: 0.5),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text(
                      '✨ 这里还很清爽',
                      style: TextStyle(
                        color: CatchMindColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else if (_isMerged)
                ..._buildMergedChildren(grouped, provider)
              else
                ...tasks.map((t) => _taskRow(t, provider)),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildMergedChildren(
    Map<String, List<Task>> grouped,
    TaskProvider provider,
  ) {
    return grouped.keys.map((tag) {
      final list = grouped[tag]!;
      final tagColor =
          Color(int.parse(list.first.tagColor.replaceFirst('#', '0xFF')));
      return ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$tag (${list.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: CatchMindColors.accent,
                ),
              ),
            ),
          ],
        ),
        children: list.map((t) => _taskRow(t, provider)).toList(),
      );
    }).toList();
  }

  Widget _taskRow(Task task, TaskProvider provider) {
    return TaskInteractive(task: task, provider: provider);
  }

  Widget _inboxStrip(TaskProvider provider) {
    final inbox = provider.inboxTasks;
    if (inbox.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE082).withAlpha(179)),
        ),
        child: const Text(
          '暂无待分拣。点右下角 + 新建；可拖到下方「非必须」条。',
          style: TextStyle(fontSize: 13, color: CatchMindColors.textSecondary),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE082).withAlpha(179)),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '待分拣 → 拖到象限，或拖到屏幕最下方「非必须」条',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CatchMindColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: inbox.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final task = inbox[i];
                return SizedBox(
                  width: 260,
                  child: TaskInteractive(task: task, provider: provider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '必须完成',
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
            _inboxStrip(provider),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildQuadrant('重要紧急', provider),
                          _buildQuadrant('不重要紧急', provider),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildQuadrant('重要不紧急', provider),
                          _buildQuadrant('不重要不紧急', provider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
