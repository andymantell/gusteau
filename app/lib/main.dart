import 'package:flutter/material.dart';

import 'screens/connection_screen.dart';

void main() {
  runApp(const GusteauApp());
}

class GusteauApp extends StatelessWidget {
  const GusteauApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gusteau',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const ConnectionScreen(),
    );
  }
}
