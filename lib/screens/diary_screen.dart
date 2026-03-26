import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_providers.dart';
import '../providers/language_provider.dart';
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
  Widget _buildMergedList(Map<String, List<Task>> groupedTasks, TaskProvider provider, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: groupedTasks.keys.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTasks.keys.elementAt(index);
        final tasks = groupedTasks[dateKey]!;
        final dateFormat = l10n.isEnglish ? 'MMM d, yyyy' : 'yyyy年M月d日';
        final dateText = DateFormat(dateFormat, l10n.isEnglish ? 'en_US' : 'zh_CN').format(DateTime.parse(dateKey));

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
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations(languageProvider.currentLanguage);
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
              Text(
                l10n.titleDiary,
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
                      _isMerged ? Icons.merge_type : Icons.format_list_bulleted,
                      color: CatchMindColors.accent,
                    ),
                    onPressed: () => setState(() => _isMerged = !_isMerged),
                    tooltip: _isMerged ? l10n.tooltipUnmerge : l10n.tooltipMergeByDate,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // 日记列表
        Expanded(
          child: diaryTasks.isEmpty
              ? Center(
                  child: Text(
                    l10n.emptyDiary,
                    style: const TextStyle(
                      color: CatchMindColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                )
              : _isMerged
                  ? _buildMergedList(groupedTasks, taskProvider, l10n)
                  : _buildNormalList(diaryTasks, taskProvider),
        ),
      ],
    );
  }
}