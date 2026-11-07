
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transaction_model.dart';

class TransactionService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<TransactionModel>> getTransactions() async {
    final response = await _client
        .from('transactions')
        .select()
        .order('date', ascending: false);

    return (response as List)
        .map(
          (item) => TransactionModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> addTransaction(
    TransactionModel transaction,
  ) async {
    await _client
        .from('transactions')
        .insert(transaction.toJson());
  }

  Future<void> updateTransaction(
    TransactionModel transaction,
  ) async {
    await _client
        .from('transactions')
        .update(transaction.toJson())
        .eq('id', transaction.id);
  }

  Future<void> deleteTransaction(String id) async {
    await _client
        .from('transactions')
        .delete()
        .eq('id', id);
  }
}
