import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/language_provider.dart';
import '../theme/catchmind_theme.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final bool isCompleted;

  const TaskCard({
    super.key,
    required this.task,
    this.isCompleted = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isExpanded = false;

  Color _accentColor() {
    final c = Color(int.parse(widget.task.tagColor.replaceFirst('#', '0xFF')));
    if (widget.isCompleted) {
      return Color.lerp(c, Colors.white, 0.55)!;
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations(languageProvider.currentLanguage);
    final accent = _accentColor();
    
    final dateFormatShort = l10n.isEnglish ? 'MMM d, h:mm a' : 'M月d日 a h:mm';
    final dateFormatLong = l10n.isEnglish ? 'MMM d, yyyy HH:mm' : 'yyyy年M月d日 HH:mm';
    final dateFormatMedium = l10n.isEnglish ? 'MMM d, HH:mm' : 'M月d日 HH:mm';
    final dateLocale = l10n.isEnglish ? 'en_US' : 'zh_CN';
    
    final ddlText = widget.task.ddl == null
        ? l10n.dialogDeadlineNone
        : DateFormat(dateFormatShort, dateLocale).format(widget.task.ddl!);
    final titleColor =
        widget.isCompleted ? CatchMindColors.textSecondary : CatchMindColors.textPrimary;
    final subColor = CatchMindColors.textSecondary;
    
    final displayTagName = l10n.getTagName(widget.task.tag);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: widget.isCompleted ? mutedTagFill(accent) : Colors.white,
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
                    '${widget.task.emoji}$displayTagName - ${widget.task.content}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: titleColor,
                      decoration:
                          widget.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l10n.dialogDeadline}：$ddlText',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          _isExpanded ? l10n.timeHide : l10n.timeShow,
                          style: TextStyle(
                            fontSize: 12,
                            color: CatchMindColors.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 14,
                          color: CatchMindColors.accent,
                        ),
                      ],
                    ),
                  ),
                  if (_isExpanded) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${l10n.timeCreated}：${DateFormat(dateFormatLong, dateLocale).format(widget.task.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: CatchMindColors.textSecondary,
                        ),
                      ),
                    ),
                    if (widget.isCompleted && widget.task.completedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${l10n.timeCompleted}：${DateFormat(dateFormatMedium, dateLocale).format(widget.task.completedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: CatchMindColors.textSecondary,
                          ),
                        ),
                      ),
                    if (widget.task.editedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${l10n.timeEdited}：${DateFormat(dateFormatMedium, dateLocale).format(widget.task.editedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: CatchMindColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                  if (widget.isCompleted &&
                      widget.task.review != null &&
                      widget.task.review!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${l10n.reviewLabel}：${widget.task.review}',
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
