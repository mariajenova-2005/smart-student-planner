import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'utils/app_router.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const StudentPlannerProApp());
}

class StudentPlannerProApp extends StatelessWidget {
  const StudentPlannerProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProxyProvider<NotificationProvider, TaskProvider>(
          create: (_) => TaskProvider(),
          update: (_, notifProvider, taskProvider) {
            taskProvider!.setNotificationProvider(notifProvider);
            return taskProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          
          return MaterialApp.router(
            title: 'Student Planner Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: buildRouter(authProvider),
          );
        },
      ),
    );
  }
}
