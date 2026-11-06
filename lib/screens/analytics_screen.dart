
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analisis Keuangan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(
        child: Text(
          'Analisis keuangan akan ditampilkan di sini.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
