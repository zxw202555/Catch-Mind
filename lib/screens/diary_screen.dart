import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_providers.dart';
import '../models/task.dart';
import '../theme/catchmind_theme.dart';
import '../widgets/task_interactive.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  bool _isMerged = false;

  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).loadTasks();
  }

  // 普通列表
  Widget _buildNormalList(List<Task> tasks, TaskProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Text(
                '记录时间：${DateFormat('yyyy年M月d日 HH:mm', 'zh_CN').format(task.createdAt)}',
                style: TextStyle(
                  color: CatchMindColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            TaskInteractive(
              task: task,
              provider: provider,
              enableLongPressDrag: false,
            ),
          ],
        );
      },
    );
  }

  // 合并列表（按日期）
  Widget _buildMergedList(Map<String, List<Task>> groupedTasks, TaskProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: groupedTasks.keys.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTasks.keys.elementAt(index);
        final tasks = groupedTasks[dateKey]!;
        final dateText = DateFormat('yyyy年M月d日').format(DateTime.parse(dateKey));

        return ExpansionTile(
          title: Text(
            dateText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CatchMindColors.accent,
            ),
          ),
          children: tasks.map((task) {
            return TaskInteractive(
              task: task,
              provider: provider,
              enableLongPressDrag: false,
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final diaryTasks = taskProvider.diaryTasks;

    // 按日期分组（日记本按记录时间分组）
    Map<String, List<Task>> groupedTasks = {};
    for (var task in diaryTasks) {
      final dateKey = DateFormat('yyyy-MM-dd').format(task.createdAt);
      if (!groupedTasks.containsKey(dateKey)) {
        groupedTasks[dateKey] = [];
      }
      groupedTasks[dateKey]!.add(task);
    }

    return Column(
      children: [
        // 顶部工具栏
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '日记本',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: CatchMindColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isMerged ? Icons.merge_type : Icons.format_list_bulleted,
                  color: CatchMindColors.accent,
                ),
                onPressed: () => setState(() => _isMerged = !_isMerged),
                tooltip: _isMerged ? '取消合并' : '按日期合并',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // 日记列表
        Expanded(
          child: diaryTasks.isEmpty
              ? const Center(
                  child: Text(
                    '暂无感悟复盘',
                    style: TextStyle(
                      color: CatchMindColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                )
              : _isMerged
                  ? _buildMergedList(groupedTasks, taskProvider)
                  : _buildNormalList(diaryTasks, taskProvider),
        ),
      ],
    );
  }
}