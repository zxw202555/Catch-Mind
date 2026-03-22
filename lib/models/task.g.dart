// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      content: fields[1] as String,
      tag: fields[2] as String,
      emoji: fields[3] as String,
      tagColor: fields[4] as String,
      ddl: fields[5] as DateTime?,
      isMustDo: fields[6] as bool,
      quadrant: fields[7] as String? ?? 'not_classified',
      isCompleted: fields[8] as bool? ?? false,
      createdAt: fields[9] as DateTime,
      review: fields[10] as String?,
      routed: fields[11] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.tag)
      ..writeByte(3)
      ..write(obj.emoji)
      ..writeByte(4)
      ..write(obj.tagColor)
      ..writeByte(5)
      ..write(obj.ddl)
      ..writeByte(6)
      ..write(obj.isMustDo)
      ..writeByte(7)
      ..write(obj.quadrant)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.review)
      ..writeByte(11)
      ..write(obj.routed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}