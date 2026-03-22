import 'package:hive/hive.dart';

part 'task.g.dart';

// Hive存储模型，typeId=0
@HiveType(typeId: 0)
class Task extends HiveObject {
  // 唯一ID
  @HiveField(0)
  late String id;

  // 事项内容
  @HiveField(1)
  late String content;

  // 标签（如：工作事业）
  @HiveField(2)
  late String tag;

  // 标签表情（如：💼）
  @HiveField(3)
  late String emoji;

  // 标签颜色（16进制）
  @HiveField(4)
  late String tagColor;

  // 截止时间（可为null）
  @HiveField(5)
  late DateTime? ddl;

  // 是否必须完成
  @HiveField(6)
  late bool isMustDo;

  // 四象限分类（仅必须完成）
  @HiveField(7)
  late String quadrant;

  // 是否完成
  @HiveField(8)
  late bool isCompleted;

  // 创建时间
  @HiveField(9)
  late DateTime createdAt;

  // 复盘内容（仅已完成事项）
  @HiveField(10)
  late String? review;

  /// 是否已分拣到「必须 / 非必须」（感悟复盘创建时直接为 true）
  @HiveField(11)
  late bool routed;

  // 构造函数
  Task({
    required this.id,
    required this.content,
    required this.tag,
    required this.emoji,
    required this.tagColor,
    this.ddl,
    required this.isMustDo,
    this.quadrant = 'not_classified',
    this.isCompleted = false,
    required this.createdAt,
    this.review,
    this.routed = false,
  });

  // 复制方法（拖拽更新象限/标记完成用）
  Task copyWith({
    String? id,
    String? content,
    String? tag,
    String? emoji,
    String? tagColor,
    DateTime? ddl,
    bool? isMustDo,
    String? quadrant,
    bool? isCompleted,
    DateTime? createdAt,
    String? review,
    bool? routed,
  }) {
    return Task(
      id: id ?? this.id,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      emoji: emoji ?? this.emoji,
      tagColor: tagColor ?? this.tagColor,
      ddl: ddl ?? this.ddl,
      isMustDo: isMustDo ?? this.isMustDo,
      quadrant: quadrant ?? this.quadrant,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      review: review ?? this.review,
      routed: routed ?? this.routed,
    );
  }
}