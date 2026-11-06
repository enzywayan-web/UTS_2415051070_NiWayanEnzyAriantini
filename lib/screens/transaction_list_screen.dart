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

    if (date == today) {
      return 'Hari Ini';
    }

    if (date == yesterday) {
      return 'Kemarin';
    }

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
          final transactions = _getFilteredTransactions(
            provider.transactions,
          );

          final groupedTransactions =
              _groupTransactions(transactions);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    TextField(
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
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildFilterButton('Semua'),
                        const SizedBox(width: 8),
                        _buildFilterButton('Pemasukan'),
                        const SizedBox(width: 8),
                        _buildFilterButton('Pengeluaran'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: transactions.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          20,
                        ),
                        children: groupedTransactions.entries.map(
                          (entry) {
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                ...entry.value.map(
                                  (transaction) {
                                    return TransactionTile(
                                      transaction: transaction,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TransactionDetailScreen(
                                              transaction: transaction,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
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
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.isNotEmpty ||
        _selectedFilter != 'Semua';

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
              isSearching
                  ? 'Transaksi Tidak Ditemukan'
                  : 'Belum Ada Transaksi',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Coba gunakan kata kunci atau filter yang berbeda.'
                  : 'Transaksi yang kamu tambahkan nantinya akan muncul di sini.',
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
}