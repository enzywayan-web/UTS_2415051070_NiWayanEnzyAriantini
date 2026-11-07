
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../providers/budget_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _showBudgetDialog(BuildContext context) async {
    final budgetProvider = context.read<BudgetProvider>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _BudgetDialog(
          initialAmount: budgetProvider.monthlyBudget,
          onSave: (amount) async {
            await budgetProvider.updateBudget(amount);
          },
        );
      },
    );

    if (!context.mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anggaran bulanan berhasil diperbarui'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>().monthlyBudget;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.primaryLight,
              child: Icon(
                Icons.person,
                size: 45,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enzy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pengguna Duitly',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Informasi Profil'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Pengaturan Anggaran'),
              subtitle: Text(_formatRupiah(budget)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showBudgetDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang Duitly'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Duitly',
                  applicationVersion: '1.0.0',
                  applicationLegalese: 'Your Money Buddy',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetDialog extends StatefulWidget {
  final double initialAmount;
  final Future<void> Function(double amount) onSave;

  const _BudgetDialog({
    required this.initialAmount,
    required this.onSave,
  });

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late final TextEditingController _controller;

  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.initialAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final input = _controller.text
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();

    final amount = double.tryParse(input);

    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Masukkan nominal yang valid';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.onSave(amount);

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _errorMessage = 'Gagal menyimpan anggaran. Silakan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Atur Anggaran Bulanan'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        enabled: !_isSaving,
        decoration: InputDecoration(
          labelText: 'Nominal Anggaran',
          prefixText: 'Rp ',
          hintText: 'Contoh: 2000000',
          border: const OutlineInputBorder(),
          errorText: _errorMessage,
        ),
        onChanged: (_) {
          if (_errorMessage != null) {
            setState(() {
              _errorMessage = null;
            });
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveBudget,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
