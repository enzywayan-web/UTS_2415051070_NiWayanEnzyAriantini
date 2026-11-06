import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'providers/transaction_provider.dart';
import 'repositories/transaction_repository.dart';
import 'services/transaction_service.dart';
import 'screens/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  final transactionService = TransactionService();
  final transactionRepository =
      TransactionRepository(transactionService);
  final transactionProvider =
      TransactionProvider(transactionRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: transactionProvider,
        ),
      ],
      child: const DuitlyApp(),
    ),
  );
}

class DuitlyApp extends StatelessWidget {
  const DuitlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duitly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}