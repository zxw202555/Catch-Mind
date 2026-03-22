import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_providers.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key});

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  bool _isMerged = false;

  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).loadTasks();
  }

  // 编辑复盘
  void _editReview(Task task) {
    final TextEditingController reviewController =
        TextEditingController(text: task.review);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑复盘'),
        content: TextField(
          controller: reviewController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '输入对这个事项的复盘...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false)
                  .addReview(task, reviewController.text);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final completedTasks = taskProvider.completedTasks;

    // 按标签分组
    Map<String, List<Task>> groupedTasks = {};
    for (var task in completedTasks) {
      if (!groupedTasks.containsKey(task.tag)) {
        groupedTasks[task.tag] = [];
      }
      groupedTasks[task.tag]!.add(task);
    }

    return Column(
      children: [
        // 顶部工具栏
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '已完成',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  _isMerged ? Icons.merge_type : Icons.format_list_bulleted,
                  color: Colors.teal,
                ),
                onPressed: () => setState(() => _isMerged = !_isMerged),
                tooltip: _isMerged ? '取消合并' : '按标签合并',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // 已完成列表
        Expanded(
          child: completedTasks.isEmpty
              ? const Center(
                  child: Text(
                    '暂无已完成事项',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              : _isMerged
                  ? _buildMergedList(groupedTasks, taskProvider)
                  : _buildNormalList(completedTasks, taskProvider),
        ),
      ],
    );
  }

  // 普通列表
  Widget _buildNormalList(List<Task> tasks, TaskProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          isCompleted: true,
          onDoubleTap: () {}, // 已完成无需双击
          onTap: () => _editReview(task), // 点击编辑复盘
        );
      },
    );
  }

  // 合并列表
  Widget _buildMergedList(Map<String, List<Task>> groupedTasks, TaskProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: groupedTasks.keys.length,
      itemBuilder: (context, index) {
        final tag = groupedTasks.keys.elementAt(index);
        final tasks = groupedTasks[tag]!;
        final tagColor = Color(int.parse(tasks.first.tagColor.replaceAll('#', '0xFF')));

        return ExpansionTile(
          title: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.5), // 低饱和度
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$tag (${tasks.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.withOpacity(0.8),
                ),
              ),
            ],
          ),
          children: tasks.map((task) {
            return TaskCard(
              task: task,
              isCompleted: true,
              onDoubleTap: () {},
              onTap: () => _editReview(task),
            );
          }).toList(),
        );
      },
    );
  }
}