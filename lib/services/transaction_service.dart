
import '../models/transaction_model.dart';

class TransactionService {
  final List<TransactionModel> _transactions = [];

  List<TransactionModel> getTransactions() {
    return List.unmodifiable(_transactions);
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction);
  }

  void updateTransaction(TransactionModel updatedTransaction) {
    final index = _transactions.indexWhere(
      (transaction) => transaction.id == updatedTransaction.id,
    );

    if (index == -1) return;

    _transactions[index] = updatedTransaction;
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere(
      (transaction) => transaction.id == id,
    );
  }
}
