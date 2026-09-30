import 'package:finance_tracker/features/auth/presentation/auth_gate.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

