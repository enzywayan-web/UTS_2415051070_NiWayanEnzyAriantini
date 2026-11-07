
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';

import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/saving_goal_provider.dart';

import 'repositories/transaction_repository.dart';
import 'repositories/saving_goal_repository.dart';
import 'repositories/saving_entry_repository.dart';

import 'services/transaction_service.dart';
import 'services/saving_goal_service.dart';
import 'services/saving_entry_service.dart';

import 'screens/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabasePublishableKey,
  );

  // Transaction
  final transactionService = TransactionService();

  final transactionRepository =
      TransactionRepository(transactionService);

  final transactionProvider =
      TransactionProvider(transactionRepository);

  // Budget
  final budgetProvider = BudgetProvider();
  await budgetProvider.loadBudget();

  // Saving Goals
  final savingGoalService = SavingGoalService();
  final savingEntryService = SavingEntryService();

  final savingGoalRepository =
      SavingGoalRepository(savingGoalService);

  final savingEntryRepository =
      SavingEntryRepository(savingEntryService);

  final savingGoalProvider = SavingGoalProvider(
    savingGoalRepository,
    savingEntryRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: transactionProvider,
        ),
        ChangeNotifierProvider.value(
          value: budgetProvider,
        ),
        ChangeNotifierProvider.value(
          value: savingGoalProvider,
        ),
      ],
      child: const DuitlyApp(),
    ),
  );
}

class DuitlyApp extends StatelessWidget {
  final bool loadInitialData;

  const DuitlyApp({
    super.key,
    this.loadInitialData = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duitly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainNavigationScreen(
        loadInitialData: loadInitialData,
      ),
    );
  }
}
