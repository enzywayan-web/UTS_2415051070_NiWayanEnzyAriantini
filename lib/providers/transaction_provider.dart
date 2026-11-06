
import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;

  final List<TransactionModel> _transactions = [];

  TransactionProvider(this._repository) {
    _transactions.addAll(_repository.getTransactions());
  }

  List<TransactionModel> get transactions {
    return List.unmodifiable(_transactions);
  }

  List<TransactionModel> get incomes {
    return _transactions
        .where((transaction) => transaction.isIncome)
        .toList();
  }

  List<TransactionModel> get expenses {
    return _transactions
        .where((transaction) => transaction.isExpense)
        .toList();
  }

  double get totalIncome {
    return incomes.fold(
      0,
      (total, transaction) => total + transaction.amount,
    );
  }

  double get totalExpense {
    return expenses.fold(
      0,
      (total, transaction) => total + transaction.amount,
    );
  }

  double get balance => totalIncome - totalExpense;

  void addTransaction(TransactionModel transaction) {
    _repository.addTransaction(transaction);
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  void updateTransaction(TransactionModel updatedTransaction) {
    final index = _transactions.indexWhere(
      (transaction) => transaction.id == updatedTransaction.id,
    );

    if (index == -1) return;

    _repository.updateTransaction(updatedTransaction);
    _transactions[index] = updatedTransaction;
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _repository.deleteTransaction(id);

    _transactions.removeWhere(
      (transaction) => transaction.id == id,
    );

    notifyListeners();
  }

  void clearTransactions() {
    for (final transaction in List<TransactionModel>.from(_transactions)) {
      _repository.deleteTransaction(transaction.id);
    }

    _transactions.clear();
    notifyListeners();
  }
}
