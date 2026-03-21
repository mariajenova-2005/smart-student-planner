import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  bool isRead;
  final TaskModel? task;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.task,
  });
}

class NotificationSettings {
  bool overdueAlerts;
  bool dueSoonAlerts;
  bool upcomingAlerts;
  bool doneConfirmations;
  bool morningDigest;
  bool eveningDigest;
  int dueSoonHours;   // alert when task is X hours away
  int upcomingDays;   // alert for tasks within X days

  NotificationSettings({
    this.overdueAlerts = true,
    this.dueSoonAlerts = true,
    this.upcomingAlerts = true,
    this.doneConfirmations = true,
    this.morningDigest = true,
    this.eveningDigest = true,
    this.dueSoonHours = 24,
    this.upcomingDays = 3,
  });
}

class NotificationProvider with ChangeNotifier {
  final List<AppNotification> _notifications = [];
  NotificationSettings _settings = NotificationSettings();

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications.reversed.toList());
  List<AppNotification> get unread =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unread.length;
  NotificationSettings get settings => _settings;

  NotificationProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = NotificationSettings(
      overdueAlerts:     prefs.getBool('notif_overdue')    ?? true,
      dueSoonAlerts:     prefs.getBool('notif_due_soon')   ?? true,
      upcomingAlerts:    prefs.getBool('notif_upcoming')   ?? true,
      doneConfirmations: prefs.getBool('notif_done')       ?? true,
      morningDigest:     prefs.getBool('notif_morning')    ?? true,
      eveningDigest:     prefs.getBool('notif_evening')    ?? true,
      dueSoonHours:      prefs.getInt('notif_soon_hours')  ?? 24,
      upcomingDays:      prefs.getInt('notif_upcoming_days') ?? 3,
    );
    notifyListeners();
  }

  Future<void> updateSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is int) await prefs.setInt(key, value);

    switch (key) {
      case 'notif_overdue':     _settings.overdueAlerts     = value as bool; break;
      case 'notif_due_soon':    _settings.dueSoonAlerts     = value as bool; break;
      case 'notif_upcoming':    _settings.upcomingAlerts    = value as bool; break;
      case 'notif_done':        _settings.doneConfirmations = value as bool; break;
      case 'notif_morning':     _settings.morningDigest     = value as bool; break;
      case 'notif_evening':     _settings.eveningDigest     = value as bool; break;
      case 'notif_soon_hours':  _settings.dueSoonHours      = value as int;  break;
      case 'notif_upcoming_days': _settings.upcomingDays    = value as int;  break;
    }
    notifyListeners();
  }

  void generateFromTasks(List<TaskModel> tasks) {
    _notifications.removeWhere((n) => n.type != 'done');
    final now = DateTime.now();

    for (final task in tasks) {
      if (task.isCompleted) continue;

      if (task.dueDate.isBefore(now)) {
        if (!_settings.overdueAlerts) continue;
        _notifications.add(AppNotification(
          id: 'overdue_${task.id}',
          title: '⚠️ Overdue Task',
          body: '"${task.title}" was due on ${_fmt(task.dueDate)}',
          type: 'overdue',
          createdAt: now,
          task: task,
        ));
        continue;
      }

      final diff = task.dueDate.difference(now);
      if (diff.inHours <= _settings.dueSoonHours) {
        if (!_settings.dueSoonAlerts) continue;
        final timeLeft = diff.inHours > 0
            ? '${diff.inHours}h ${diff.inMinutes % 60}m'
            : '${diff.inMinutes}m';
        _notifications.add(AppNotification(
          id: 'soon_${task.id}',
          title: '⏰ Due Soon',
          body: '"${task.title}" is due in $timeLeft — at ${_fmtTime(task.dueDate)}',
          type: 'due_soon',
          createdAt: now,
          task: task,
        ));
        continue;
      }

      if (diff.inDays <= _settings.upcomingDays) {
        if (!_settings.upcomingAlerts) continue;
        _notifications.add(AppNotification(
          id: 'upcoming_${task.id}',
          title: '📅 Upcoming Task',
          body: '"${task.title}" is due on ${_fmt(task.dueDate)}',
          type: 'pending',
          createdAt: now,
          task: task,
        ));
      }
    }

    notifyListeners();
  }

  void addDoneNotification(String taskTitle) {
    if (!_settings.doneConfirmations) return;
    _notifications.add(AppNotification(
      id: 'done_${DateTime.now().millisecondsSinceEpoch}',
      title: '✅ Task Completed',
      body: '"$taskTitle" has been marked as done. Great work!',
      type: 'done',
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _notifications) { n.isRead = true; }
    notifyListeners();
  }

  void markRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) { _notifications[idx].isRead = true; notifyListeners(); }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  String _fmt(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${_fmtTime(d)}';
  }

  String _fmtTime(DateTime d) {
    final h = d.hour > 12 ? d.hour - 12 : d.hour == 0 ? 12 : d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}
