import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final destinations = const [
    _ShellDestination(label: 'Home', icon: Icons.home_outlined, route: '/app/home'),
    _ShellDestination(label: 'Расписание', icon: Icons.schedule_outlined, route: '/app/schedule'),
    _ShellDestination(label: 'Задачи', icon: Icons.task_alt_outlined, route: '/app/tasks'),
    _ShellDestination(label: 'Материалы', icon: Icons.folder_open_outlined, route: '/app/materials'),
    _ShellDestination(label: 'Чаты', icon: Icons.chat_bubble_outline, route: '/app/chats'),
    _ShellDestination(label: 'Оценки', icon: Icons.grade_outlined, route: '/app/grades'),
    _ShellDestination(label: 'Профиль', icon: Icons.person_outline, route: '/app/profile'),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    context.go(destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: destinations
            .map((item) => NavigationDestination(icon: Icon(item.icon), label: item.label))
            .toList(),
      ),
    );
  }
}

class _ShellDestination {
  final String label;
  final IconData icon;
  final String route;

  const _ShellDestination({required this.label, required this.icon, required this.route});
}
