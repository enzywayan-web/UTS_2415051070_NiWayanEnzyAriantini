
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../models/saving_entry_model.dart';
import '../models/saving_goal_model.dart';
import '../providers/saving_goal_provider.dart';

class SavingEntryScreen extends StatefulWidget {
  final SavingGoalModel goal;
  final String initialType;

  const SavingEntryScreen({
    super.key,
    required this.goal,
    this.initialType = 'deposit',
  });

  @override
  State<SavingEntryScreen> createState() =>
      _SavingEntryScreenState();
}

class _SavingEntryScreenState extends State<SavingEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late String _selectedType;
  bool _isSaving = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    if (_selectedType == 'withdrawal' &&
        amount > widget.goal.currentAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jumlah penarikan melebihi saldo tabungan.',
          ),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final entry = SavingEntryModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      goalId: widget.goal.id,
      amount: amount,
      type: _selectedType,
      date: DateTime.now(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    try {
      await context.read<SavingGoalProvider>().addEntry(entry);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedType == 'deposit'
                ? 'Tabungan berhasil ditambahkan.'
                : 'Penarikan tabungan berhasil.',
          ),
          backgroundColor: AppColors.income,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan aktivitas: $error'),
          backgroundColor: AppColors.expense,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeposit = _selectedType == 'deposit';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Aktivitas Tabungan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Tabungan',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.goal.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Saldo Terkumpul',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _currencyFormat.format(
                        widget.goal.currentAmount,
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Jenis Aktivitas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      title: 'Tambah Tabungan',
                      type: 'deposit',
                      icon: Icons.add_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      title: 'Tarik Tabungan',
                      type: 'withdrawal',
                      icon: Icons.remove_circle_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Jumlah Uang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  hintText: 'Contoh: 100000',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );

                  if (amount == null || amount <= 0) {
                    return 'Masukkan jumlah uang yang valid.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Catatan (Opsional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan aktivitas...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveEntry,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isDeposit ? Icons.add : Icons.remove,
                        ),
                  label: Text(
                    _isSaving
                        ? 'Menyimpan...'
                        : isDeposit
                            ? 'Simpan Tabungan'
                            : 'Simpan Penarikan',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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

  Widget _buildTypeButton({
    required String title,
    required String type,
    required IconData icon,
  }) {
    final selected = _selectedType == type;

    return OutlinedButton(
      onPressed: _isSaving
          ? null
          : () {
              setState(() {
                _selectedType = type;
              });
            },
      style: OutlinedButton.styleFrom(
        backgroundColor:
            selected ? AppColors.primaryLight : AppColors.surface,
        foregroundColor:
            selected ? AppColors.primary : AppColors.textSecondary,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
