
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'package:duitly/main.dart';
import 'package:duitly/providers/transaction_provider.dart';
import 'package:duitly/repositories/transaction_repository.dart';
import 'package:duitly/services/transaction_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/shared_preferences');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, Object>{};
      }
      return null;
    });

    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-publishable-key',
    );
  });

  testWidgets('Duitly app starts successfully', (WidgetTester tester) async {
    final transactionService = TransactionService();

    final transactionRepository =
        TransactionRepository(transactionService);

    final transactionProvider =
        TransactionProvider(transactionRepository);

    await tester.pumpWidget(
      ChangeNotifierProvider<TransactionProvider>.value(
        value: transactionProvider,
        child: const DuitlyApp(
          loadInitialData: false,
),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Goals'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
