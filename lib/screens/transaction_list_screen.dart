
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState
    extends State<TransactionListScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _getFilteredTransactions(
    List<TransactionModel> transactions,
  ) {
    final filtered = transactions.where((transaction) {
      final matchesFilter = switch (_selectedFilter) {
        'Pemasukan' => transaction.isIncome,
        'Pengeluaran' => transaction.isExpense,
        _ => true,
      };

      final query = _searchQuery.toLowerCase();

      final matchesSearch =
          transaction.title.toLowerCase().contains(query) ||
          transaction.category.toLowerCase().contains(query) ||
          (transaction.note ?? '').toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  Map<DateTime, List<TransactionModel>> _groupTransactions(
    List<TransactionModel> transactions,
  ) {
    final grouped = <DateTime, List<TransactionModel>>{};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(transaction);
    }

    return grouped;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'Hari Ini';
    if (date == yesterday) return 'Kemarin';

    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 850;

              final controls = _buildControls(
                isWide: isWide,
              );

              final results = _buildResults(provider);

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1200,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: isWide
                        ? Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 280,
                                child: controls,
                              ),
                              const SizedBox(width: 20),
                              Expanded(child: results),
                            ],
                          )
                        : Column(
                            children: [
                              controls,
                              const SizedBox(height: 12),
                              Expanded(child: results),
                            ],
                          ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildControls({required bool isWide}) {
    final searchField = TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari transaksi...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.close),
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
      ),
    );

    if (isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchField,
          const SizedBox(height: 18),
          const Text(
            'Filter Transaksi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildFilterButton('Semua'),
          const SizedBox(height: 8),
          _buildFilterButton('Pemasukan'),
          const SizedBox(height: 8),
          _buildFilterButton('Pengeluaran'),
        ],
      );
    }

    return Column(
      children: [
        searchField,
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildFilterButton('Semua')),
            const SizedBox(width: 8),
            Expanded(child: _buildFilterButton('Pemasukan')),
            const SizedBox(width: 8),
            Expanded(child: _buildFilterButton('Pengeluaran')),
          ],
        ),
      ],
    );
  }

  Widget _buildResults(TransactionProvider provider) {
    final transactions = _getFilteredTransactions(
      provider.transactions,
    );

    final groupedTransactions =
        _groupTransactions(transactions);

    Widget content;

    if (provider.isLoading && provider.transactions.isEmpty) {
      content = const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    } else if (provider.errorMessage != null &&
        provider.transactions.isEmpty) {
      content = _buildErrorState(
        provider.errorMessage!,
        provider.loadTransactions,
      );
    } else if (transactions.isEmpty) {
      content = _buildEmptyState(
        hasAnyTransaction: provider.transactions.isNotEmpty,
      );
    } else {
      content = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        children: groupedTransactions.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 10,
                ),
                child: Text(
                  _formatDate(entry.key),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...entry.value.map((transaction) {
                return TransactionTile(
                  transaction: transaction,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TransactionDetailScreen(
                          transaction: transaction,
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          );
        }).toList(),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: provider.loadTransactions,
      child: content is ListView
          ? content
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 350,
                  child: content,
                ),
              ],
            ),
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required bool hasAnyTransaction,
  }) {
    final isSearching = _searchQuery.isNotEmpty ||
        _selectedFilter != 'Semua';

    final title = isSearching
        ? 'Transaksi Tidak Ditemukan'
        : 'Belum Ada Transaksi';

    final description = isSearching
        ? 'Coba gunakan kata kunci atau filter yang berbeda.'
        : 'Transaksi yang kamu tambahkan nantinya akan muncul di sini.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.receipt_long_rounded,
              size: 65,
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    String message,
    Future<void> Function() onRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 55,
              color: AppColors.expense,
            ),
            const SizedBox(height: 14),
            const Text(
              'Gagal Memuat Transaksi',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Periksa koneksi internet atau coba beberapa saat lagi.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
