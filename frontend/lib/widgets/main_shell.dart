import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'notification_bell.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _idx(String loc) {
    if (loc.startsWith('/dashboard')) return 0;
    if (loc.startsWith('/tasks')) return 1;
    if (loc.startsWith('/calendar')) return 2;
    if (loc.startsWith('/notes')) return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  String _title(String loc) {
    if (loc.startsWith('/dashboard')) return 'Dashboard';
    if (loc.startsWith('/tasks')) return 'My Tasks';
    if (loc.startsWith('/calendar')) return 'Calendar';
    if (loc.startsWith('/notes')) return 'Notes';
    if (loc.startsWith('/profile')) return 'Profile';
    return 'Student Planner Pro';
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(loc)),
        automaticallyImplyLeading: false,
        actions: const [
          NotificationBell(),
          SizedBox(width: 8),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx(loc),
        onTap: (i) {
          switch (i) {
            case 0: context.go('/dashboard'); break;
            case 1: context.go('/tasks'); break;
            case 2: context.go('/calendar'); break;
            case 3: context.go('/notes'); break;
            case 4: context.go('/profile'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.task_outlined),
              activeIcon: Icon(Icons.task),
              label: 'Tasks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Calendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.note_outlined),
              activeIcon: Icon(Icons.note),
              label: 'Notes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}
