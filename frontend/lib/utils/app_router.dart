import 'package:go_router/go_router.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/tasks/add_edit_task_screen.dart';
import '../screens/tasks/tasks_screen.dart';
import '../widgets/main_shell.dart';

GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      if (!authProvider.initialized) return null;
      final loggedIn = authProvider.isLoggedIn;
      final isAuth = state.uri.toString() == '/login' || state.uri.toString() == '/register';
      if (!loggedIn && !isAuth) return '/login';
      if (loggedIn && isAuth) return '/dashboard';
      return null;
    },
    refreshListenable: authProvider,
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(
            path: '/tasks',
            builder: (_, __) => const TasksScreen(),
            routes: [
              GoRoute(path: 'add', builder: (_, __) => const AddEditTaskScreen()),
              GoRoute(path: 'edit', builder: (_, state) => AddEditTaskScreen(task: state.extra as TaskModel?)),
            ],
          ),
          GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
          GoRoute(path: '/notes', builder: (_, __) => const NotesScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
}
