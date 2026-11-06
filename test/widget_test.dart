
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:duitly/main.dart';
import 'package:duitly/providers/transaction_provider.dart';
import 'package:duitly/repositories/transaction_repository.dart';
import 'package:duitly/services/transaction_service.dart';

void main() {
  testWidgets('Duitly app starts successfully', (WidgetTester tester) async {
    final transactionService = TransactionService();
    final transactionRepository =
        TransactionRepository(transactionService);
    final transactionProvider =
        TransactionProvider(transactionRepository);

    await tester.pumpWidget(
      ChangeNotifierProvider<TransactionProvider>.value(
        value: transactionProvider,
        child: const DuitlyApp(),
      ),
    );

    expect(find.text('Duitly'), findsOneWidget);
  });
}
