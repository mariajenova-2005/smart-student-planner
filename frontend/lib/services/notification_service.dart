import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _i = NotificationService._();
  factory NotificationService() => _i;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _morningId = 9000;
  static const int _eveningId = 9001;
  static const int _overdueId = 9002;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _plugin.initialize(initSettings);
  }

  // ── 1. DEADLINE REMINDER — 1 hour before task is due ──────

  Future<void> scheduleDeadlineReminder({
    required int id,
    required String taskTitle,
    required String priority,
    required DateTime dueDate,
  }) async {
    final reminderTime = dueDate.subtract(const Duration(hours: 1));
    if (reminderTime.isBefore(DateTime.now())) return;

    final priorityIcon = priority == 'high'
        ? '🔴'
        : priority == 'medium'
            ? '🟡'
            : '🟢';
    final formattedDue = DateFormat('MMM d, h:mm a').format(dueDate);

    final androidDetails = AndroidNotificationDetails(
      'deadline_ch',
      'Deadline Reminders',
      channelDescription: '1 hour before task deadline',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        '$priorityIcon $taskTitle\nDue at: $formattedDue\nOnly 1 hour left — complete it now!',
        contentTitle: '⏰ Task Due in 1 Hour!',
        summaryText: priority.toUpperCase() + ' PRIORITY',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id,
      '⏰ Task Due in 1 Hour!',
      '$priorityIcon "$taskTitle" — due at $formattedDue',
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── 2. MORNING ALERT — 8 AM with full pending list ────────

  Future<void> scheduleMorningAlert(List<TaskModel> pendingTasks) async {
    await _plugin.cancel(_morningId);
    if (pendingTasks.isEmpty) return;

    final now = DateTime.now();
    var fireTime = DateTime(now.year, now.month, now.day, 8, 0);
    if (fireTime.isBefore(now)) {
      fireTime = fireTime.add(const Duration(days: 1));
    }

    final total = pendingTasks.length;
    final highCount = pendingTasks.where((t) => t.priority == 'high').length;
    final todayList = pendingTasks.where((t) {
      return t.dueDate.year == fireTime.year &&
          t.dueDate.month == fireTime.month &&
          t.dueDate.day == fireTime.day;
    }).toList();

    final title = '🌅 Good Morning! $total Pending Task${total > 1 ? 's' : ''}';
    final shortBody = todayList.isNotEmpty
        ? '${todayList.length} due today${highCount > 0 ? ', $highCount high priority!' : '.'}'
        : 'Stay on track — $total task${total > 1 ? 's' : ''} pending${highCount > 0 ? ', $highCount high priority!' : '.'}';

    final bigText = _buildDetailedPendingList(pendingTasks, showDueTime: true);

    final androidDetails = AndroidNotificationDetails(
      'pending_ch',
      'Pending Task Alerts',
      channelDescription: 'Daily morning and evening pending summaries',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        bigText,
        contentTitle: title,
        summaryText: '$total pending task${total > 1 ? 's' : ''}',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      _morningId,
      title,
      shortBody,
      tz.TZDateTime.from(fireTime, tz.local),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── 3. EVENING ALERT — 8 PM with remaining pending tasks ──

  Future<void> scheduleEveningAlert(List<TaskModel> pendingTasks) async {
    await _plugin.cancel(_eveningId);
    if (pendingTasks.isEmpty) return;

    final now = DateTime.now();
    var fireTime = DateTime(now.year, now.month, now.day, 20, 0);
    if (fireTime.isBefore(now)) {
      fireTime = fireTime.add(const Duration(days: 1));
    }

    final total = pendingTasks.length;
    final highCount = pendingTasks.where((t) => t.priority == 'high').length;
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowCount = pendingTasks.where((t) =>
        t.dueDate.year == tomorrow.year &&
        t.dueDate.month == tomorrow.month &&
        t.dueDate.day == tomorrow.day).length;

    final title = '🌙 Evening Check-in — $total Pending Task${total > 1 ? 's' : ''}';
    final shortBody =
        '$total task${total > 1 ? 's' : ''} still pending${highCount > 0 ? ' ($highCount high priority)' : ''}.'
        '${tomorrowCount > 0 ? ' $tomorrowCount due tomorrow.' : ' Keep going!'}';

    final bigText = _buildDetailedPendingList(pendingTasks, showDueTime: true);

    final androidDetails = AndroidNotificationDetails(
      'pending_ch',
      'Pending Task Alerts',
      channelDescription: 'Daily morning and evening pending summaries',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        bigText,
        contentTitle: title,
        summaryText: '$total pending task${total > 1 ? 's' : ''}',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      _eveningId,
      title,
      shortBody,
      tz.TZDateTime.from(fireTime, tz.local),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── 4. OVERDUE INSTANT ALERT — fires immediately ──────────

  Future<void> showOverdueAlert(List<TaskModel> overdueTasks) async {
    if (overdueTasks.isEmpty) return;

    final count = overdueTasks.length;
    final highCount = overdueTasks.where((t) => t.priority == 'high').length;
    final bigText = _buildOverdueList(overdueTasks);

    final androidDetails = AndroidNotificationDetails(
      'overdue_ch',
      'Overdue Task Alerts',
      channelDescription: 'Alerts for tasks past their deadline',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE53935),
      styleInformation: BigTextStyleInformation(
        bigText,
        contentTitle: '🚨 $count Overdue Task${count > 1 ? 's' : ''}!',
        summaryText: highCount > 0 ? '$highCount high priority overdue!' : '$count overdue',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      _overdueId,
      '🚨 $count Overdue Task${count > 1 ? 's' : ''}!',
      '${highCount > 0 ? '$highCount high priority! ' : ''}Complete them immediately.',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  // ── 5. TASK DONE CONFIRMATION ─────────────────────────────

  Future<void> showDoneConfirmation(String taskTitle) async {
    const androidDetails = AndroidNotificationDetails(
      'done_ch',
      'Task Completed',
      channelDescription: 'Confirmation when a task is marked done',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: true,
      presentSound: false,
    );

    await _plugin.show(
      taskTitle.hashCode & 0x7FFFFFFF,
      '✅ Task Completed!',
      '"$taskTitle" is done. Great work! 🎉',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────

  String _buildDetailedPendingList(List<TaskModel> tasks,
      {bool showDueTime = false}) {
    final sorted = [...tasks]..sort((a, b) {
        const o = {'high': 0, 'medium': 1, 'low': 2};
        return (o[a.priority] ?? 1).compareTo(o[b.priority] ?? 1);
      });
    final top = sorted.take(6).toList();
    final lines = top.map((t) {
      final icon = t.priority == 'high'
          ? '🔴'
          : t.priority == 'medium'
              ? '🟡'
              : '🟢';
      final due = showDueTime
          ? ' — due ${DateFormat('MMM d, h:mm a').format(t.dueDate)}'
          : '';
      return '$icon ${t.title}$due';
    }).join('\n');
    final extra =
        tasks.length > 6 ? '\n...and ${tasks.length - 6} more tasks' : '';
    return '$lines$extra';
  }

  String _buildOverdueList(List<TaskModel> tasks) {
    final top = tasks.take(6).toList();
    final lines = top.map((t) {
      final icon = t.priority == 'high'
          ? '🔴'
          : t.priority == 'medium'
              ? '🟡'
              : '🟢';
      final was = DateFormat('MMM d, h:mm a').format(t.dueDate);
      return '$icon ${t.title} — was due $was';
    }).join('\n');
    final extra =
        tasks.length > 6 ? '\n...and ${tasks.length - 6} more' : '';
    return '$lines$extra';
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}
