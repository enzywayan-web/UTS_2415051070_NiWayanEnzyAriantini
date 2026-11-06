
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionRepository {
  final TransactionService _service;

  TransactionRepository(this._service);

  List<TransactionModel> getTransactions() {
    return _service.getTransactions();
  }

  void addTransaction(TransactionModel transaction) {
    _service.addTransaction(transaction);
  }

  void updateTransaction(TransactionModel transaction) {
    _service.updateTransaction(transaction);
  }

  void deleteTransaction(String id) {
    _service.deleteTransaction(id);
  }
}
