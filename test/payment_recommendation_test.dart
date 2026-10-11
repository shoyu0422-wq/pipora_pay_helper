import 'package:flutter_test/flutter_test.dart';
import 'package:pipora_pay_helper/models/credit_card.dart';
import 'package:pipora_pay_helper/models/payment_method.dart';
import 'package:pipora_pay_helper/models/payment_recommendation.dart';
import 'package:pipora_pay_helper/models/reward_rule.dart';

void main() {
  final recommendation = PaymentRecommendation(
    paymentMethod: PaymentMethod(
      id: 'test_payment_method',
      name: 'Test payment method',
      type: 'wallet',
      supportedCards: ['test_card'],
      icon: 'wallet',
      description: 'Test payment method',
    ),
    creditCard: CreditCard(
      id: 'test_card',
      bankName: 'Test bank',
      cardName: 'Test card',
      rewardDescription: 'Test reward',
      cashbackRate: 6.88,
      monthlyLimit: 0,
      needRegistration: false,
      notes: 'Test notes',
    ),
    paymentBonus: 0,
    totalCashback: 6.88,
    reason: 'Test recommendation',
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
      notes: 'Test rule',
    ),
  );

  test('estimates cashback for common spend amounts and monthly cap', () {
    expect(recommendation.estimatedCashbackFor(1000), 68.8);
    expect(recommendation.estimatedCashbackFor(10000), 688);
    expect(recommendation.estimatedCashbackFor(20000), 888);
  });

  test('applies the lower of monthly and per-promotion reward caps', () {
    final cappedRecommendation = PaymentRecommendation(
      paymentMethod: recommendation.paymentMethod,
      creditCard: recommendation.creditCard,
      paymentBonus: recommendation.paymentBonus,
      totalCashback: recommendation.totalCashback,
      reason: recommendation.reason,
      rewardRule: RewardRule(
        cardId: 'test_card',
        merchantKeyword: 'Test merchant',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
        minimumSpend: 1000,
        monthlyRewardLimit: 888,
        maximumReward: 500,
        needRegistration: false,
        newCustomerOnly: false,
        notes: 'Test rule',
      ),
    );

    expect(cappedRecommendation.estimatedCashbackFor(10000), 500);
    expect(cappedRecommendation.meetsMinimumSpend(999), isFalse);
    expect(cappedRecommendation.estimatedCashbackFor(999), 0);
  });

  test('remaining monthly reward is applied to the next estimate', () {
    final partlyUsed = PaymentRecommendation(
      paymentMethod: recommendation.paymentMethod,
      creditCard: recommendation.creditCard,
      paymentBonus: recommendation.paymentBonus,
      totalCashback: recommendation.totalCashback,
      reason: recommendation.reason,
      rewardRule: recommendation.rewardRule,
      usedMonthlyReward: 800,
    );

    expect(partlyUsed.remainingRewardLimit, 88);
    expect(partlyUsed.estimatedCashbackFor(20000), 88);

    final exhausted = PaymentRecommendation(
      paymentMethod: recommendation.paymentMethod,
      creditCard: recommendation.creditCard,
      paymentBonus: recommendation.paymentBonus,
      totalCashback: recommendation.totalCashback,
      reason: recommendation.reason,
      rewardRule: recommendation.rewardRule,
      usedMonthlyReward: 888,
    );
    expect(exhausted.remainingRewardLimit, 0);
    expect(exhausted.estimatedCashbackFor(10000), 0);
  });

  test('remaining reward respects both monthly and promotion caps', () {
    final cappedRecommendation = PaymentRecommendation(
      paymentMethod: recommendation.paymentMethod,
      creditCard: recommendation.creditCard,
      paymentBonus: recommendation.paymentBonus,
      totalCashback: recommendation.totalCashback,
      reason: recommendation.reason,
      rewardRule: RewardRule(
        cardId: 'test_card',
        merchantKeyword: 'Test merchant',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
        minimumSpend: 0,
        monthlyRewardLimit: 888,
        maximumReward: 500,
        needRegistration: false,
        newCustomerOnly: false,
        notes: 'Test rule',
      ),
      usedMonthlyReward: 300,
    );

    expect(cappedRecommendation.remainingRewardLimit, 200);
    expect(cappedRecommendation.estimatedCashbackFor(20000), 200);
  });
}
