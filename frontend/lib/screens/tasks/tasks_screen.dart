import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TaskProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        bottom: TabBar(controller: _tab, tabs: [
          Tab(text: 'All (${tp.tasks.length})'),
          Tab(text: 'Pending (${tp.pendingTasks.length})'),
          Tab(text: 'Done (${tp.completedTasks.length})'),
        ]),
      ),
      body: TabBarView(controller: _tab, children: [
        _TaskList(tasks: tp.tasks),
        _TaskList(tasks: tp.pendingTasks),
        _TaskList(tasks: tp.completedTasks),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/tasks/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List tasks;
  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.task_alt, size: 60, color: Color(0xFF6C63FF)),
          SizedBox(height: 16),
          Text('No tasks here', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('Tap + to add a new task', style: TextStyle(color: Colors.grey)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => TaskCard(task: tasks[i]),
    );
  }
}
