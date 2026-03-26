import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _allTasks = [];

  /// 待分拣（非感悟复盘、未完成）
  List<Task> get inboxTasks => _allTasks
      .where((t) => !t.routed && !t.isCompleted && t.tag != '感悟复盘')
      .toList();

  List<Task> get mustDoTasks => _allTasks
      .where((t) =>
          t.routed &&
          t.isMustDo &&
          !t.isCompleted &&
          t.tag != '感悟复盘')
      .toList();

  List<Task> get nonMustDoTasks => _allTasks
      .where((t) =>
          t.routed &&
          !t.isMustDo &&
          !t.isCompleted &&
          t.tag != '感悟复盘')
      .toList();

  List<Task> get diaryTasks => _allTasks
      .where((t) => t.tag == '感悟复盘' && !t.isCompleted)
      .toList();

  List<Task> get completedTasks =>
      _allTasks.where((t) => t.isCompleted).toList();

  void loadTasks() {
    final box = Hive.box<Task>('tasks');
    _allTasks = box.values.toList();
    notifyListeners();
  }

  void addTask(Task task) {
    final box = Hive.box<Task>('tasks');
    box.put(task.id, task);
    _allTasks.add(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    final box = Hive.box<Task>('tasks');
    // 更新任务时设置编辑时间
    final updatedTask = task.copyWith(editedAt: DateTime.now());
    box.put(updatedTask.id, updatedTask);
    final index = _allTasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _allTasks[index] = updatedTask;
    }
    notifyListeners();
  }

  void markTaskCompleted(Task task) {
    HapticFeedback.mediumImpact();
    final updatedTask = task.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    updateTask(updatedTask);
  }

  /// 右滑「推迟」：有 DDL 则 +1 天；无则设为明日 18:00
  void postponeTask(Task task) {
    HapticFeedback.lightImpact();
    if (task.ddl == null) {
      final n = DateTime.now().add(const Duration(days: 1));
      updateTask(
        task.copyWith(
          ddl: DateTime(n.year, n.month, n.day, 18, 0),
        ),
      );
      return;
    }
    updateTask(task.copyWith(ddl: task.ddl!.add(const Duration(days: 1))));
  }

  void markTaskIncomplete(Task task) {
    HapticFeedback.lightImpact();
    final updatedTask = task.copyWith(
      isCompleted: false,
      completedAt: null,
    );
    updateTask(updatedTask);
  }

  void addReview(Task task, String review) {
    final updatedTask = task.copyWith(review: review);
    updateTask(updatedTask);
  }

  void deleteTask(Task task) {
    final box = Hive.box<Task>('tasks');
    box.delete(task.id);
    _allTasks.remove(task);
    notifyListeners();
  }
}
