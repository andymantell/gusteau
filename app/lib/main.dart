import 'package:flutter/material.dart';

import 'data/database.dart';
import 'screens/connection_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/weekly_plan_screen.dart';

void main() {
  runApp(const GusteauApp());
}

class GusteauApp extends StatefulWidget {
  const GusteauApp({super.key});

  @override
  State<GusteauApp> createState() => _GusteauAppState();
}

class _GusteauAppState extends State<GusteauApp> {
  // One instance for the whole app's lifetime, shared by every screen
  // that touches storage — not recreated per navigation.
  final _db = AppDatabase();

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gusteau',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: HomeShell(db: _db),
    );
  }
}

/// Bottom-nav shell over the three top-level screens. See
/// docs/planning/iterations.md, iteration 1.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.db});

  final AppDatabase db;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      WeeklyPlanScreen(database: widget.db),
      SettingsScreen(database: widget.db),
      const ConnectionScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'This week',
          ),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Settings'),
          NavigationDestination(icon: Icon(Icons.link), label: 'Connection'),
        ],
      ),
    );
  }
}
