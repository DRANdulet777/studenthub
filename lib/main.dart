import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:student_hub/core/router/app_router.dart';
import 'package:student_hub/core/services/local_notification_service.dart';
import 'package:student_hub/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Инициализация timezone
  tz.initializeTimeZones();

  // Инициализация сервиса уведомлений
  await LocalNotificationService().initialize();

  runApp(const ProviderScope(child: StudentHubApp()));
}

class StudentHubApp extends ConsumerWidget {
  const StudentHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'StudentHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
