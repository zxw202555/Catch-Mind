import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../theme/catchmind_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isCompleted;

  const TaskCard({
    super.key,
    required this.task,
    this.isCompleted = false,
  });

  Color _accentColor() {
    final c = Color(int.parse(task.tagColor.replaceFirst('#', '0xFF')));
    if (isCompleted) {
      return Color.lerp(c, Colors.white, 0.55)!;
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    final ddlText = task.ddl == null
        ? '无'
        : DateFormat('M月d日 a h:mm', 'zh_CN').format(task.ddl!);
    final titleColor =
        isCompleted ? CatchMindColors.textSecondary : CatchMindColors.textPrimary;
    final subColor = CatchMindColors.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: isCompleted ? mutedTagFill(accent) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CatchMindColors.hairline.withAlpha(230),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 18,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${task.emoji}${task.tag}-${task.content}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: titleColor,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ddl：$ddlText',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subColor,
                    ),
                  ),

                  if (isCompleted &&
                      task.review != null &&
                      task.review!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '复盘：${task.review}',
                        style: TextStyle(
                          fontSize: 12,
                          color: CatchMindColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
