import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipora_pay_helper/features/card_detail/card_detail_page.dart';
import 'package:pipora_pay_helper/features/home/widgets/payment_recommendation_tile.dart';
import 'package:pipora_pay_helper/l10n/app_localizations.dart';
import 'package:pipora_pay_helper/models/credit_card.dart';
import 'package:pipora_pay_helper/models/payment_method.dart';
import 'package:pipora_pay_helper/models/payment_recommendation.dart';
import 'package:pipora_pay_helper/models/reward_rule.dart';

void main() {
  testWidgets('推薦卡顯示推薦原因', (WidgetTester tester) async {
    const reason = '因為符合指定付款路徑，可獲得最高回饋。';

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
        home: Scaffold(
          body: PaymentRecommendationTile(
            recommendation: _recommendation(reason),
            rank: 1,
          ),
        ),
      ),
    );

    expect(find.text('推薦原因'), findsOneWidget);
    expect(find.text(reason), findsOneWidget);
  });

  testWidgets('推薦卡顯示最高回饋率與套用上限後的本筆回饋', (WidgetTester tester) async {
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
        home: Scaffold(
          body: SingleChildScrollView(
            child: PaymentRecommendationTile(
              recommendation: _recommendation('Test recommendation'),
              rank: 1,
              spendAmount: 20000,
            ),
          ),
        ),
      ),
    );

    expect(find.text('最高回饋'), findsOneWidget);
    expect(find.text('5%'), findsOneWidget);
    expect(find.text('預估本筆回饋 NT\$888.00'), findsOneWidget);
    expect(find.text('剩餘回饋額度 NT\$888.00'), findsOneWidget);
  });

  testWidgets('卡片詳情頁可記錄消費', (WidgetTester tester) async {
    var saved = false;

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
        home: CardDetailPage(
          recommendation: _recommendation('Test recommendation'),
          spendAmount: 1000,
          onSaveTransaction: () async {
            saved = true;
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.text('記錄這筆消費'));
    await tester.pump();

    expect(saved, isTrue);
  });
}

PaymentRecommendation _recommendation(String reason) {
  return PaymentRecommendation(
    paymentMethod: PaymentMethod(
      id: 'test_payment_method',
      name: 'Test payment method',
      type: 'wallet',
      supportedCards: const ['test_card'],
      icon: 'wallet',
      description: 'Test payment method',
    ),
    creditCard: CreditCard(
      id: 'test_card',
      bankName: 'Test bank',
      cardName: 'Test card',
      rewardDescription: 'Test reward',
      cashbackRate: 3,
      monthlyLimit: 0,
      needRegistration: false,
      notes: '',
    ),
    paymentBonus: 2,
    totalCashback: 5,
    reason: reason,
    rewardRule: RewardRule(
      cardId: 'test_card',
      merchantKeyword: 'Test merchant',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
      minimumSpend: 0,
      monthlyRewardLimit: 888,
      maximumReward: 0,
      needRegistration: false,
      newCustomerOnly: false,
      notes: '',
    ),
  );
}
