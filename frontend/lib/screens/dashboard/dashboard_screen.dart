import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tp = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final todayTasks = tp.todayTasks;

    return RefreshIndicator(
      onRefresh: () => tp.loadTasks(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text('${_greeting()},',
                style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            Text(
              auth.user?.name.split(' ').first ?? 'Student',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(DateFormat('EEEE, MMMM d').format(DateTime.now()),
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 24),

            // Stats
            Row(children: [
              _StatCard(label: 'Total', value: tp.tasks.length.toString(), color: const Color(0xFF6C63FF), icon: Icons.task_alt),
              const SizedBox(width: 12),
              _StatCard(label: 'Done', value: tp.completedTasks.length.toString(), color: const Color(0xFF43A047), icon: Icons.check_circle_outline),
              const SizedBox(width: 12),
              _StatCard(label: 'Today', value: todayTasks.length.toString(), color: const Color(0xFFFFA726), icon: Icons.today),
            ]),
            const SizedBox(height: 24),

            // Progress
            if (tp.tasks.isNotEmpty) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Overall progress',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text('${tp.completionPercentage}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: tp.completionPercentage / 100,
                  minHeight: 8,
                  backgroundColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Quick actions
            Text('Quick actions',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              _QuickAction(label: 'Add Task', icon: Icons.add_task, color: const Color(0xFF6C63FF), onTap: () => context.go('/tasks/add')),
              const SizedBox(width: 12),
              _QuickAction(label: 'Calendar', icon: Icons.calendar_month, color: const Color(0xFF00ACC1), onTap: () => context.go('/calendar')),
              const SizedBox(width: 12),
              _QuickAction(label: 'Notes', icon: Icons.note_add, color: const Color(0xFFE91E8C), onTap: () => context.go('/notes')),
              const SizedBox(width: 12),
              _QuickAction(label: 'All Tasks', icon: Icons.list_alt, color: const Color(0xFFFFA726), onTap: () => context.go('/tasks')),
            ]),
            const SizedBox(height: 24),

            // Today's tasks
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Today's tasks",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                  onPressed: () => context.go('/tasks'),
                  child: const Text('See all')),
            ]),
            const SizedBox(height: 8),
            if (todayTasks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
                ),
                child: const Column(children: [
                  Icon(Icons.celebration, size: 40, color: Color(0xFF6C63FF)),
                  SizedBox(height: 8),
                  Text('No tasks due today. Enjoy your day!',
                      textAlign: TextAlign.center),
                ]),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayTasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) => TaskCard(task: todayTasks[i]),
              ),

            // High priority
            if (tp.getTasksByPriority('high').where((t) => !t.isCompleted).isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('High priority',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...tp.getTasksByPriority('high').where((t) => !t.isCompleted).take(3).map(
                    (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TaskCard(task: t)),
                  ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        ]),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
