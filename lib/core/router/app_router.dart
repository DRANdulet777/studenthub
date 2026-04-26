import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_hub/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:student_hub/features/auth/presentation/screens/login_screen.dart';
import 'package:student_hub/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:student_hub/features/auth/presentation/screens/register_screen.dart';
import 'package:student_hub/features/auth/presentation/screens/splash_screen.dart';
import 'package:student_hub/features/chat/presentation/screens/chat_screen.dart';
import 'package:student_hub/features/core/presentation/app_shell.dart';
import 'package:student_hub/features/grades/presentation/screens/grades_screen.dart';
import 'package:student_hub/features/home/presentation/screens/home_screen.dart';
import 'package:student_hub/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:student_hub/features/profile/presentation/screens/profile_screen.dart';
import 'package:student_hub/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:student_hub/features/tasks/presentation/screens/tasks_screen.dart';

class AppRouter {
  AppRouter._();

  static GoRouter get router {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final isAppRoute = state.matchedLocation.startsWith('/app/');
        if (isAppRoute && FirebaseAuth.instance.currentUser == null) {
          return '/login';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/app/home', builder: (context, state) => const HomeScreen()),
            GoRoute(path: '/app/schedule', builder: (context, state) => const ScheduleScreen()),
            GoRoute(path: '/app/tasks', builder: (context, state) => const TasksScreen()),
            GoRoute(path: '/app/chats', builder: (context, state) => const ChatScreen()),
            GoRoute(path: '/app/grades', builder: (context, state) => const GradesScreen()),
            GoRoute(path: '/app/notifications', builder: (context, state) => const NotificationsScreen()),
            GoRoute(path: '/app/profile', builder: (context, state) => const ProfileScreen()),
          ],
        ),
      ],
    );
  }
}
