import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipora_pay_helper/features/home/home_page.dart';
import 'package:pipora_pay_helper/features/home/widgets/payment_recommendation_tile.dart';
import 'package:pipora_pay_helper/l10n/app_localizations.dart';
import 'package:pipora_pay_helper/models/credit_card.dart';
import 'package:pipora_pay_helper/models/payment_method.dart';
import 'package:pipora_pay_helper/models/payment_rule.dart';
import 'package:pipora_pay_helper/models/reward_rule.dart';
import 'package:pipora_pay_helper/services/card_repository.dart';
import 'package:pipora_pay_helper/services/payment_method_repository.dart';
import 'package:pipora_pay_helper/services/payment_rule_repository.dart';
import 'package:pipora_pay_helper/services/recommendation_service.dart';
import 'package:pipora_pay_helper/services/reward_rule_repository.dart';
import 'package:pipora_pay_helper/services/transaction_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('search submitted during loading runs when offers are ready', (
    WidgetTester tester,
  ) async {
    final transactions = SharedPreferencesTransactionRepository();
    final cardLoadGate = Completer<void>();
    final service = _service(transactions, cardLoadGate: cardLoadGate);
    await tester.pumpWidget(_app(service));
    await tester.pump();

    expect(service.isReady, isFalse);
    await tester.enterText(find.byType(TextField).first, 'Test Store');
    await tester.enterText(find.byType(TextField).at(1), '1,000');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    expect(find.byType(PaymentRecommendationTile), findsNothing);

    cardLoadGate.complete();
    await _waitUntilReady(tester, service);

    expect(find.byType(PaymentRecommendationTile), findsOneWidget);
    expect(find.text('Estimated reward: NT\$50.00'), findsOneWidget);
  });

  testWidgets(
    'record, edit and reload one transaction with matching monthly allowance',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final transactions = SharedPreferencesTransactionRepository();
      final service = _service(transactions);
      await tester.pumpWidget(_app(service));
      await _waitUntilReady(tester, service);

      await tester.enterText(find.byType(TextField).first, 'Test Store');
      await tester.enterText(find.byType(TextField).at(1), '1,000');
      await tester.tap(find.text('Search'));
      await tester.pump();

      final recommendation = find.byType(PaymentRecommendationTile).first;
      expect(recommendation, findsOneWidget);
      await tester.ensureVisible(recommendation);
      await tester.tap(recommendation);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Record this purchase'));
      await tester.pumpAndSettle();

      expect(await transactions.getAllTransactions(), hasLength(1));
      expect(find.text('NT\$50.00'), findsWidgets);
      expect(
        find.text('Remaining reward allowance: NT\$50.00'),
        findsOneWidget,
      );

      final transactionHistory = find.byType(ExpansionTile);
      await tester.ensureVisible(transactionHistory);
      await tester.tap(transactionHistory);
      await tester.pumpAndSettle();
      final transactionStore = find.descendant(
        of: transactionHistory,
        matching: find.text('Test Store'),
      );
      expect(transactionStore, findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ExpansionTile),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );

      await tester.ensureVisible(transactionStore);
      await tester.tap(transactionStore);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '40');
      await tester.scrollUntilVisible(
        find.text('Save actual reward'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Save actual reward'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save actual reward'));
      await tester.pumpAndSettle();

      final updated = await transactions.getAllTransactions();
      expect(updated, hasLength(1));
      expect(updated.single.actualReward, 40);
      expect(find.text('NT\$40.00'), findsWidgets);
      expect(
        find.text('Remaining reward allowance: NT\$60.00'),
        findsOneWidget,
      );

      final reloadedService = _service(
        SharedPreferencesTransactionRepository(),
      );
      await tester.pumpWidget(_app(reloadedService));
      await _waitUntilReady(tester, reloadedService);

      expect(reloadedService.transactions, hasLength(1));
      expect(reloadedService.currentMonthReward, 40);
      expect(find.text('NT\$40.00'), findsWidgets);
    },
  );
}

MaterialApp _app(RecommendationService service) => MaterialApp(
  locale: const Locale('en'),
  supportedLocales: const [Locale('en'), Locale('zh', 'TW')],
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: HomePage(key: ValueKey(service), recommendationService: service),
);

Future<void> _waitUntilReady(
  WidgetTester tester,
  RecommendationService service,
) async {
  for (var attempt = 0; attempt < 20 && !service.isReady; attempt++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(service.isReady, isTrue);
  await tester.pump();
}

RecommendationService _service(
  TransactionRepository transactions, {
  Completer<void>? cardLoadGate,
}) => RecommendationService(
  cardRepository: _Cards(cardLoadGate),
  paymentMethodRepository: _PaymentMethods(),
  paymentRuleRepository: _PaymentRules(),
  rewardRuleRepository: _RewardRules(),
  transactionRepository: transactions,
);

class _Cards extends CardRepository {
  _Cards(this.loadGate);

  final Completer<void>? loadGate;

  @override
  Future<List<CreditCard>> getAllCards() async {
    await loadGate?.future;
    return const [
      CreditCard(
        id: 'test-card',
        bankName: 'Test Bank',
        cardName: 'Test Card',
        rewardDescription: '',
        cashbackRate: 5,
        monthlyLimit: 0,
        needRegistration: false,
        notes: '',
      ),
    ];
  }
}

class _PaymentMethods extends PaymentMethodRepository {
  @override
  Future<List<PaymentMethod>> getAllPaymentMethods() async => const [
    PaymentMethod(
      id: 'test-wallet',
      name: 'Test Wallet',
      type: 'wallet',
      supportedCards: ['test-card'],
      icon: 'wallet',
      description: '',
    ),
  ];
}

class _PaymentRules extends PaymentRuleRepository {
  @override
  Future<List<PaymentRule>> getAllPaymentRules() async => const [];
}

class _RewardRules extends RewardRuleRepository {
  @override
  Future<List<RewardRule>> getAllRewardRules() async => [
    RewardRule(
      cardId: 'test-card',
      merchantKeyword: 'Test Store',
      startDate: DateTime(2020, 1, 1),
      endDate: DateTime(2030, 12, 31),
      minimumSpend: 0,
      monthlyRewardLimit: 100,
      maximumReward: 0,
      needRegistration: false,
      newCustomerOnly: false,
      notes: '',
    ),
  ];
}
