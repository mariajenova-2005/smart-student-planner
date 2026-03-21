import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'notification_provider.dart';

class TaskProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  final ApiService _api = ApiService();
  final NotificationService _ns = NotificationService();
  NotificationProvider? _notifProvider;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  List<TaskModel> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((t) =>
        t.dueDate.year == now.year &&
        t.dueDate.month == now.month &&
        t.dueDate.day == now.day).toList();
  }

  List<TaskModel> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<TaskModel> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  List<TaskModel> get overdueTasks {
    final now = DateTime.now();
    return _tasks.where((t) => !t.isCompleted && t.dueDate.isBefore(now)).toList();
  }

  List<TaskModel> getTasksForDate(DateTime d) => _tasks.where((t) =>
      t.dueDate.year == d.year &&
      t.dueDate.month == d.month &&
      t.dueDate.day == d.day).toList();

  List<TaskModel> getTasksByPriority(String p) =>
      _tasks.where((t) => t.priority == p).toList();

  int get completionPercentage =>
      _tasks.isEmpty ? 0 : (completedTasks.length / _tasks.length * 100).round();

  void setNotificationProvider(NotificationProvider np) {
    _notifProvider = np;
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    final result = await _api.getTasks();
    if (result['success'] == true) {
      final list = result['tasks'] as List<dynamic>;
      _tasks = list.map((j) => TaskModel.fromJson(j as Map<String, dynamic>)).toList();
      _refreshInAppNotifications();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
    required String category,
  }) async {
    final result = await _api.createTask({
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'category': category,
    });
    if (result['success'] == true) {
      final task = TaskModel.fromJson(result['task'] as Map<String, dynamic>);
      _tasks.add(task);
      _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      await _ns.scheduleDeadlineReminder(
        id: task.id.hashCode & 0x7FFFFFFF,
        taskTitle: task.title,
        priority: task.priority,
        dueDate: dueDate,
      );
      _refreshInAppNotifications();
      notifyListeners();
    }
  }

  Future<void> updateTask(TaskModel task) async {
    final result = await _api.updateTask(task.id, task.toJson());
    if (result['success'] == true) {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        _tasks[idx] = TaskModel.fromJson(result['task'] as Map<String, dynamic>);
      }
      await _ns.cancel(task.id.hashCode & 0x7FFFFFFF);
      if (!task.isCompleted) {
        await _ns.scheduleDeadlineReminder(
          id: task.id.hashCode & 0x7FFFFFFF,
          taskTitle: task.title,
          priority: task.priority,
          dueDate: task.dueDate,
        );
      }
      _refreshInAppNotifications();
      notifyListeners();
    }
  }

  Future<void> toggleComplete(String taskId) async {
    final ok = await _api.toggleTask(taskId);
    if (ok) {
      final idx = _tasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        _tasks[idx].isCompleted = !_tasks[idx].isCompleted;
        final task = _tasks[idx];
        if (task.isCompleted) {
          await _ns.cancel(taskId.hashCode & 0x7FFFFFFF);
          _notifProvider?.addDoneNotification(task.title);
        } else {
          await _ns.scheduleDeadlineReminder(
            id: taskId.hashCode & 0x7FFFFFFF,
            taskTitle: task.title,
            priority: task.priority,
            dueDate: task.dueDate,
          );
        }
        _refreshInAppNotifications();
        notifyListeners();
      }
    }
  }

  Future<void> deleteTask(String taskId) async {
    final ok = await _api.deleteTask(taskId);
    if (ok) {
      _tasks.removeWhere((t) => t.id == taskId);
      await _ns.cancel(taskId.hashCode & 0x7FFFFFFF);
      _refreshInAppNotifications();
      notifyListeners();
    }
  }

  void clearTasks() {
    _tasks = [];
    _ns.cancelAll();
    _notifProvider?.clearAll();
    notifyListeners();
  }

  void _refreshInAppNotifications() {
    _notifProvider?.generateFromTasks(_tasks);
  }
}
