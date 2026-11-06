
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SavingGoalsScreen extends StatelessWidget {
  const SavingGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Target Tabungan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(
        child: Text(
          'Target tabungan akan ditampilkan di sini.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
