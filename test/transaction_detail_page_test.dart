import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipora_pay_helper/features/transactions/transaction_detail_page.dart';
import 'package:pipora_pay_helper/l10n/app_localizations.dart';
import 'package:pipora_pay_helper/models/payment_transaction.dart';

void main() {
  testWidgets('transaction details save the actual reward', (tester) async {
    double? savedReward;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'TW'),
        supportedLocales: const [Locale('zh', 'TW')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: TransactionDetailPage(
          transaction: _transaction(),
          onSaveActualReward: (reward) async {
            savedReward = reward;
            return true;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '18.50');
    await tester.scrollUntilVisible(
      find.text('儲存實際回饋'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('儲存實際回饋'));
    await tester.pump();

    expect(savedReward, 18.5);
  });

  testWidgets('actual reward accepts zero when the purchase earned nothing', (
    tester,
  ) async {
    double? savedReward;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'TW'),
        supportedLocales: const [Locale('zh', 'TW')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: TransactionDetailPage(
          transaction: _transaction(),
          onSaveActualReward: (reward) async {
            savedReward = reward;
            return true;
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '0');
    await tester.scrollUntilVisible(
      find.text('儲存實際回饋'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('儲存實際回饋'));
    await tester.pump();

    expect(savedReward, 0);
  });
}

PaymentTransaction _transaction() => PaymentTransaction(
  id: 'test-transaction',
  date: DateTime(2026, 10, 8),
  storeName: 'Test Store',
  spendAmount: 1000,
  paymentMethodId: 'wallet',
  paymentMethodName: 'Test Wallet',
  creditCardId: 'card',
  creditCardName: 'Test Card',
  estimatedReward: 50,
  rewardRuleKey: 'test-rule',
);
