/// DDL 相对今天的友好文案 + 近 7 日内进度条比例（0~1，无则 null）
class DdlVisual {
  final String? label;
  final double? progress;

  const DdlVisual({this.label, this.progress});
}

DdlVisual ddlVisual(DateTime? ddl) {
  if (ddl == null) {
    return const DdlVisual();
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(ddl.year, ddl.month, ddl.day);
  final days = d.difference(today).inDays;

  String label;
  if (days < 0) {
    label = '已逾期 ${-days} 天';
  } else if (days == 0) {
    label = '今天截止';
  } else if (days == 1) {
    label = '还剩 1 天';
  } else {
    label = '还剩 $days 天';
  }

  double? progress;
  if (days >= 0 && days <= 7) {
    progress = (7 - days) / 7.0;
  } else if (days > 7) {
    progress = 0.05;
  } else {
    progress = 1.0;
  }

  return DdlVisual(label: label, progress: progress);
}
