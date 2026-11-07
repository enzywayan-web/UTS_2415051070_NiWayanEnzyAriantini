
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetProvider extends ChangeNotifier {
  static const String _budgetKey = 'monthly_budget';

  double _monthlyBudget = 2000000;

  double get monthlyBudget => _monthlyBudget;

  Future<void> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();

    _monthlyBudget = prefs.getDouble(_budgetKey) ?? 2000000;

    notifyListeners();
  }

  Future<void> updateBudget(double amount) async {
    if (amount <= 0) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(_budgetKey, amount);

    _monthlyBudget = amount;

    notifyListeners();
  }
}
