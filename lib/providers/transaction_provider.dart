
import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;

  final List<TransactionModel> _transactions = [];

  bool _isLoading = false;
  String? _errorMessage;

  TransactionProvider(this._repository);

  List<TransactionModel> get transactions {
    return List.unmodifiable(_transactions);
  }

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<TransactionModel> get incomes =>
      _transactions.where((t) => t.isIncome).toList();

  List<TransactionModel> get expenses =>
      _transactions.where((t) => t.isExpense).toList();

  double get totalIncome =>
      incomes.fold(0, (total, t) => total + t.amount);

  double get totalExpense =>
      expenses.fold(0, (total, t) => total + t.amount);

  double get balance => totalIncome - totalExpense;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getTransactions();

      _transactions
        ..clear()
        ..addAll(result);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(
    TransactionModel transaction,
  ) async {
    await _repository.addTransaction(transaction);
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  Future<void> updateTransaction(
    TransactionModel updatedTransaction,
  ) async {
    final index = _transactions.indexWhere(
      (t) => t.id == updatedTransaction.id,
    );

    if (index == -1) return;

    await _repository.updateTransaction(updatedTransaction);

    _transactions[index] = updatedTransaction;
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);

    _transactions.removeWhere(
      (t) => t.id == id,
    );

    notifyListeners();
  }

  Future<void> clearTransactions() async {
    final currentTransactions =
        List<TransactionModel>.from(_transactions);

    for (final transaction in currentTransactions) {
      await _repository.deleteTransaction(transaction.id);
    }

    _transactions.clear();
    notifyListeners();
  }
}
