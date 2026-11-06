
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(
        child: Text(
          'Riwayat transaksi akan ditampilkan di sini.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
