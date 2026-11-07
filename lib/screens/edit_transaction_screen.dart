import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _type;
  late String _category;
  late DateTime _selectedDate;

  final List<String> _expenseCategories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Pendidikan',
    'Hiburan',
    'Kesehatan',
    'Tagihan',
    'Lainnya',
  ];

  final List<String> _incomeCategories = [
    'Gaji',
    'Bisnis',
    'Hadiah',
    'Uang Saku',
    'Investasi',
    'Lainnya',
  ];

  List<String> get _categories {
    return _type == 'income'
        ? _incomeCategories
        : _expenseCategories;
  }

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    _titleController = TextEditingController(
      text: transaction.title,
    );

    _amountController = TextEditingController(
      text: transaction.amount.toStringAsFixed(0),
    );

    _noteController = TextEditingController(
      text: transaction.note ?? '',
    );

    _type = transaction.type;
    _category = transaction.category;
    _selectedDate = transaction.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_categories.contains(_category)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori transaksi.'),
        ),
      );
      return;
    }

    final amountText = _amountController.text
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      return;
    }

    final updatedTransaction = TransactionModel(
      id: widget.transaction.id,
      title: _titleController.text.trim(),
      category: _category,
      amount: amount,
      type: _type,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    try {
      await context
          .read<TransactionProvider>()
          .updateTransaction(updatedTransaction);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil diperbarui.'),
          backgroundColor: AppColors.income,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui transaksi: $error'),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == 'income';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jenis Transaksi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _typeButton(
                      label: 'Pengeluaran',
                      value: 'expense',
                      color: AppColors.expense,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _typeButton(
                      label: 'Pemasukan',
                      value: 'income',
                      color: AppColors.income,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Nama Transaksi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Makan siang',
                  prefixIcon: Icon(Icons.edit_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama transaksi wajib diisi.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Nominal (Rp)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'Contoh: 25000',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nominal wajib diisi.';
                  }

                  final parsed = double.tryParse(
                    value.trim()
                        .replaceAll('.', '')
                        .replaceAll(',', '.'),
                  );

                  if (parsed == null || parsed <= 0) {
                    return 'Masukkan nominal yang valid.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Kategori',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _categories.contains(_category)
                    ? _category
                    : null,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Silakan pilih kategori.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Tanggal Transaksi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat(
                          'EEEE, dd MMMM yyyy',
                          'id_ID',
                        ).format(_selectedDate),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_calendar_outlined),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Catatan (Opsional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan transaksi...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan Perubahan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isIncome
                        ? AppColors.income
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeButton({
    required String label,
    required String value,
    required Color color,
  }) {
    final selected = _type == value;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _type = value;

          if (!_categories.contains(_category)) {
            _category = _categories.first;
          }
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? color.withValues(alpha: 0.12)
            : AppColors.surface,
        foregroundColor: color,
        side: BorderSide(
          color: selected ? color : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}