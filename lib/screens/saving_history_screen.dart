
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../models/saving_goal_model.dart';
import '../models/saving_entry_model.dart';
import '../providers/saving_goal_provider.dart';

class SavingHistoryScreen extends StatefulWidget {
  final SavingGoalModel goal;

  const SavingHistoryScreen({
    super.key,
    required this.goal,
  });

  @override
  State<SavingHistoryScreen> createState() =>
      _SavingHistoryScreenState();
}

class _SavingHistoryScreenState
    extends State<SavingHistoryScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final DateFormat _dateFormat =
      DateFormat('d MMMM yyyy, HH:mm', 'id_ID');

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<SavingGoalProvider>()
          .loadEntries(widget.goal.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Riwayat Tabungan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<SavingGoalProvider>(
        builder: (context, provider, child) {
          final entries = provider.getEntries(widget.goal.id);

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.loadEntries(widget.goal.id),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildGoalSummary(),
                const SizedBox(height: 24),
                const Text(
                  'Aktivitas Tabungan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                if (entries.isEmpty)
                  _buildEmptyState()
                else
                  ...entries.map(_buildEntryCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            Color(0xFF9B83E8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Tabungan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.goal.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Total Terkumpul',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _currencyFormat.format(widget.goal.currentAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Target: ${_currencyFormat.format(widget.goal.targetAmount)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(SavingEntryModel entry) {
    final isDeposit = entry.isDeposit;

    final color = isDeposit
        ? AppColors.income
        : AppColors.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDeposit
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDeposit ? 'Tambah Tabungan' : 'Tarik Tabungan',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _dateFormat.format(entry.date.toLocal()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (entry.note != null &&
                    entry.note!.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    entry.note!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isDeposit ? '+' : '-'}${_currencyFormat.format(entry.amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.history,
            size: 50,
            color: AppColors.primary,
          ),
          SizedBox(height: 12),
          Text(
            'Belum Ada Aktivitas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Aktivitas tambah dan tarik tabungan akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
