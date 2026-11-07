
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionRepository {
  final TransactionService _service;

  TransactionRepository(this._service);

  Future<List<TransactionModel>> getTransactions() {
    return _service.getTransactions();
  }

  Future<void> addTransaction(
    TransactionModel transaction,
  ) {
    return _service.addTransaction(transaction);
  }

  Future<void> updateTransaction(
    TransactionModel transaction,
  ) {
    return _service.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) {
    return _service.deleteTransaction(id);
  }
}
