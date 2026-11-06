
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const DuitlyApp());
}

class DuitlyApp extends StatelessWidget {
  const DuitlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duitly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}
