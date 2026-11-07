
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Bulan ini';

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();

    return transactions.where((transaction) {
      final date = transaction.date;

      switch (_selectedPeriod) {
        case 'Bulan ini':
          return date.year == now.year &&
              date.month == now.month;

        case '30 hari terakhir':
          final startDate = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 29));

          return !date.isBefore(startDate) &&
              !date.isAfter(now);

        case 'Tahun ini':
          return date.year == now.year;

        case 'Semua':
          return true;

        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final transactions = _filterTransactions(
      provider.transactions,
    );

    final incomes = transactions
        .where((transaction) => transaction.isIncome)
        .toList();

    final expenses = transactions
        .where((transaction) => transaction.isExpense)
        .toList();

    final totalIncome = incomes.fold<double>(
      0,
      (total, transaction) => total + transaction.amount,
    );

    final totalExpense = expenses.fold<double>(
      0,
      (total, transaction) => total + transaction.amount,
    );

    final balance = totalIncome - totalExpense;

    final Map<String, double> categoryTotals = {};

    for (final transaction in expenses) {
      categoryTotals.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final categoryEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCategory = categoryEntries.isEmpty
        ? 0.0
        : categoryEntries.first.value;

    final maxComparison = totalIncome > totalExpense
        ? totalIncome
        : totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analisis Keuangan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter periode
              const Text(
                'Periode Laporan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'Bulan ini',
                        child: Text('Bulan ini'),
                      ),
                      DropdownMenuItem(
                        value: '30 hari terakhir',
                        child: Text('30 hari terakhir'),
                      ),
                      DropdownMenuItem(
                        value: 'Tahun ini',
                        child: Text('Tahun ini'),
                      ),
                      DropdownMenuItem(
                        value: 'Semua',
                        child: Text('Semua transaksi'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Loading
              if (provider.isLoading &&
                  provider.transactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(),
                  ),
                )

              // Error
              else if (provider.errorMessage != null &&
                  provider.transactions.isEmpty)
                _buildMessage(
                  Icons.error_outline,
                  'Gagal memuat data transaksi.',
                  'Tarik layar ke bawah untuk mencoba lagi.',
                )

              else ...[
                // Ringkasan
                const Text(
                  'Ringkasan Keuangan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                _buildSummaryCard(
                  title: 'Total Pemasukan',
                  amount: totalIncome,
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                ),

                const SizedBox(height: 12),

                _buildSummaryCard(
                  title: 'Total Pengeluaran',
                  amount: totalExpense,
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),

                const SizedBox(height: 12),

                _buildSummaryCard(
                  title: 'Selisih Keuangan',
                  amount: balance,
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                ),

                const SizedBox(height: 28),

                // Grafik perbandingan
                const Text(
                  'Perbandingan Pemasukan dan Pengeluaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: maxComparison == 0
                      ? _buildEmptyContent(
                          'Belum ada data untuk ditampilkan.',
                        )
                      : Column(
                          children: [
                            _buildComparisonBar(
                              title: 'Pemasukan',
                              amount: totalIncome,
                              maxAmount: maxComparison,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 24),
                            _buildComparisonBar(
                              title: 'Pengeluaran',
                              amount: totalExpense,
                              maxAmount: maxComparison,
                              color: Colors.red,
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 28),

                // Kategori pengeluaran
                const Text(
                  'Pengeluaran Berdasarkan Kategori',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: categoryEntries.isEmpty
                      ? _buildEmptyContent(
                          'Belum ada pengeluaran pada periode ini.',
                        )
                      : Column(
                          children: categoryEntries.map((entry) {
                            final progress = maxCategory > 0
                                ? entry.value / maxCategory
                                : 0.0;

                            final percentage = totalExpense > 0
                                ? (entry.value / totalExpense) * 100
                                : 0.0;

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 20,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatRupiah(entry.value),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 9,
                                      backgroundColor:
                                          AppColors.primaryLight,
                                      valueColor:
                                          const AlwaysStoppedAnimation<
                                              Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    '${percentage.toStringAsFixed(1)}% dari total pengeluaran',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),

                const SizedBox(height: 24),

                if (transactions.isEmpty)
                  _buildMessage(
                    Icons.analytics_outlined,
                    'Belum ada transaksi.',
                    'Tambahkan transaksi untuk melihat analisis keuangan.',
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
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
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatRupiah(amount),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar({
    required String title,
    required double amount,
    required double maxAmount,
    required Color color,
  }) {
    final progress = maxAmount > 0
        ? (amount / maxAmount).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              _formatRupiah(amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: AppColors.primaryLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyContent(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
