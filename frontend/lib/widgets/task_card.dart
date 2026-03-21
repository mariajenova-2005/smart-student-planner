import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final bool showActions;
  const TaskCard({super.key, required this.task, this.showActions = true});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isToggling = false;

  Future<void> _handleToggle() async {
    if (_isToggling) return;
    setState(() => _isToggling = true);
    await context.read<TaskProvider>().toggleComplete(widget.task.id);
    if (mounted) setState(() => _isToggling = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = widget.task;
    final pc = AppTheme.priorityColor(task.priority);
    final cc = AppTheme.categoryColor(task.category);
    final overdue = !task.isCompleted && task.dueDate.isBefore(DateTime.now());

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.go('/tasks/edit', extra: task),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Top row: checkbox + title + priority dot + menu ──
              Row(
                children: [
                  GestureDetector(
                    onTap: _handleToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted ? const Color(0xFF43A047) : Colors.transparent,
                        border: Border.all(
                          color: task.isCompleted
                              ? const Color(0xFF43A047)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: _isToggling
                          ? const Padding(
                              padding: EdgeInsets.all(5),
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : task.isCompleted
                              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: pc, shape: BoxShape.circle)),
                  if (widget.showActions)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                      onSelected: (v) {
                        if (v == 'delete') context.read<TaskProvider>().deleteTask(task.id);
                        if (v == 'edit') context.go('/tasks/edit', extra: task);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                ],
              ),

              // ── Description ──
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 38),
                  child: Text(
                    task.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // ── Bottom row: category + due date + DONE BUTTON ──
              Padding(
                padding: const EdgeInsets.only(left: 38),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: cc.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(task.category,
                          style: TextStyle(fontSize: 10, color: cc, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.schedule, size: 12,
                        color: overdue ? Colors.red : theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        DateFormat('MMM d, h:mm a').format(task.dueDate),
                        style: TextStyle(
                          fontSize: 11,
                          color: overdue ? Colors.red : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: overdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // ── DONE BUTTON ──
                    GestureDetector(
                      onTap: _handleToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: task.isCompleted
                              ? const Color(0xFF43A047).withValues(alpha: 0.12)
                              : const Color(0xFF6C63FF).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: task.isCompleted
                                ? const Color(0xFF43A047)
                                : const Color(0xFF6C63FF),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              task.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 13,
                              color: task.isCompleted
                                  ? const Color(0xFF43A047)
                                  : const Color(0xFF6C63FF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.isCompleted ? 'Done' : 'Mark Done',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: task.isCompleted
                                    ? const Color(0xFF43A047)
                                    : const Color(0xFF6C63FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Status strip ──
              if (overdue || task.isCompleted) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 38),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? const Color(0xFF43A047).withValues(alpha: 0.08)
                          : Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      task.isCompleted ? '✓ Completed' : '⚠ Overdue',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted ? const Color(0xFF43A047) : Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
