
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../models/saving_goal_model.dart';
import '../providers/saving_goal_provider.dart';
import 'saving_entry_screen.dart';
import 'saving_history_screen.dart';

class SavingGoalsScreen extends StatefulWidget {
  const SavingGoalsScreen({super.key});

  static Future<void> showAddGoalDialog(BuildContext context) async {
    final goal = await showDialog<SavingGoalModel>(
      context: context,
      builder: (context) => const _SavingGoalFormDialog(),
    );

    if (goal == null || !context.mounted) return;

    try {
      await context.read<SavingGoalProvider>().addGoal(goal);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target tabungan berhasil ditambahkan.'),
          backgroundColor: AppColors.income,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan target: $error'),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  @override
  State<SavingGoalsScreen> createState() =>
      _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends State<SavingGoalsScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> _editGoal(SavingGoalModel goal) async {
    final updatedGoal = await showDialog<SavingGoalModel>(
      context: context,
      builder: (context) => _SavingGoalFormDialog(
        existingGoal: goal,
      ),
    );

    if (updatedGoal == null || !mounted) return;

    try {
      await context
          .read<SavingGoalProvider>()
          .updateGoal(updatedGoal);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target tabungan berhasil diperbarui.'),
          backgroundColor: AppColors.income,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui target: $error'),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  Future<void> _deleteGoal(SavingGoalModel goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Target Tabungan?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus target "${goal.title}"? '
          'Seluruh riwayat aktivitas target ini juga akan terhapus. '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<SavingGoalProvider>().deleteGoal(goal.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target tabungan berhasil dihapus.'),
          backgroundColor: AppColors.income,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus target: $error'),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Target Tabungan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                SavingGoalsScreen.showAddGoalDialog(context),
            tooltip: 'Tambah target',
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Consumer<SavingGoalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.errorMessage != null &&
              provider.goals.isEmpty) {
            return _buildErrorState(provider);
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: provider.loadGoals,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(provider),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Target',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${provider.goals.length} target',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (provider.goals.isEmpty)
                  _buildEmptyState()
                else
                  ...provider.goals.map(
                    (goal) => _buildGoalCard(goal),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(SavingGoalProvider provider) {
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
            'Total Tabungan Terkumpul',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(provider.totalSaved),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white30),
          const SizedBox(height: 12),
          const Text(
            'Total Target Tabungan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(provider.totalTarget),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(SavingGoalModel goal) {
    final percentage = (goal.progress * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (goal.isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.income,
                ),
              PopupMenuButton<String>(
                tooltip: 'Pengaturan target',
                onSelected: (value) {
                  if (value == 'edit') {
                    _editGoal(goal);
                  } else if (value == 'delete') {
                    _deleteGoal(goal);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text('Edit target'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: AppColors.expense,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Hapus target',
                          style: TextStyle(
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progres tabungan',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 9,
              backgroundColor: AppColors.primaryLight,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Terkumpul',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                _currencyFormat.format(goal.currentAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Target',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                _currencyFormat.format(goal.targetAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (goal.targetDate != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Target: ${DateFormat('d MMM yyyy', 'id_ID').format(goal.targetDate!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (goal.isCompleted) ...[
            const SizedBox(height: 12),
            const Text(
              'Selamat! Target tabungan tercapai.',
              style: TextStyle(
                color: AppColors.income,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SavingEntryScreen(
                          goal: goal,
                          initialType: 'deposit',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: goal.currentAmount <= 0
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SavingEntryScreen(
                                goal: goal,
                                initialType: 'withdrawal',
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Tarik'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SavingHistoryScreen(
                          goal: goal,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Riwayat'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
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
            Icons.savings_outlined,
            size: 54,
            color: AppColors.primary,
          ),
          SizedBox(height: 14),
          Text(
            'Belum Ada Target Tabungan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Mulai buat target tabungan pertamamu dan pantau progresnya di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SavingGoalProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.expense,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gagal Memuat Target Tabungan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: provider.loadGoals,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingGoalFormDialog extends StatefulWidget {
  final SavingGoalModel? existingGoal;

  const _SavingGoalFormDialog({
    this.existingGoal,
  });

  @override
  State<_SavingGoalFormDialog> createState() =>
      _SavingGoalFormDialogState();
}

class _SavingGoalFormDialogState
    extends State<_SavingGoalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  DateTime? _targetDate;

  bool get _isEditing => widget.existingGoal != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.existingGoal?.title ?? '',
    );

    _amountController = TextEditingController(
      text: widget.existingGoal?.targetAmount.toStringAsFixed(0) ?? '',
    );

    _targetDate = widget.existingGoal?.targetDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 3650),
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _targetDate = selectedDate;
      });
    }
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    final existingGoal = widget.existingGoal;

    if (existingGoal != null &&
        amount < existingGoal.currentAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Target tidak boleh kurang dari jumlah terkumpul '
            '(${NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(existingGoal.currentAmount)}).',
          ),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final goal = SavingGoalModel(
      id: existingGoal?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      targetAmount: amount,
      currentAmount: existingGoal?.currentAmount ?? 0,
      targetDate: _targetDate,
      createdAt: existingGoal?.createdAt ?? DateTime.now(),
    );

    Navigator.of(context).pop(goal);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isEditing
            ? 'Edit Target Tabungan'
            : 'Tambah Target Tabungan',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama target',
                  hintText: 'Contoh: Beli laptop',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama target wajib diisi.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Jumlah target',
                  hintText: 'Contoh: 5000000',
                  prefixIcon: Icon(Icons.payments_outlined),
                  prefixText: 'Rp ',
                ),
                validator: (value) {
                  final amount = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );

                  if (amount == null || amount <= 0) {
                    return 'Masukkan jumlah yang valid.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  _targetDate == null
                      ? 'Pilih tanggal target (opsional)'
                      : DateFormat('d MMM yyyy', 'id_ID')
                          .format(_targetDate!),
                ),
              ),
              if (_targetDate != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _targetDate = null;
                    });
                  },
                  child: const Text('Hapus tanggal target'),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _saveGoal,
          child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Target'),
        ),
      ],
    );
  }
}
