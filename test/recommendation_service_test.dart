import 'package:flutter_test/flutter_test.dart';
import 'package:pipora_pay_helper/models/credit_card.dart';
import 'package:pipora_pay_helper/models/payment_method.dart';
import 'package:pipora_pay_helper/models/payment_rule.dart';
import 'package:pipora_pay_helper/models/payment_transaction.dart';
import 'package:pipora_pay_helper/models/reward_rule.dart';
import 'package:pipora_pay_helper/services/card_repository.dart';
import 'package:pipora_pay_helper/services/payment_method_repository.dart';
import 'package:pipora_pay_helper/services/payment_rule_repository.dart';
import 'package:pipora_pay_helper/services/recommendation_service.dart';
import 'package:pipora_pay_helper/services/reward_rule_repository.dart';
import 'package:pipora_pay_helper/services/transaction_repository.dart';

void main() {
  test(
    'search results include matching offers sorted by total cashback',
    () async {
      final service = RecommendationService(
        cardRepository: _CardRepository([
          _card('lower_rate', 'Lower rate card', 3),
          _card('higher_rate', 'Higher rate card', 5),
        ]),
        paymentMethodRepository: _PaymentMethodRepository([
          const PaymentMethod(
            id: 'wallet',
            name: 'Test Wallet',
            type: 'wallet',
            supportedCards: ['lower_rate', 'higher_rate'],
            icon: 'wallet',
            description: '',
          ),
        ]),
        paymentRuleRepository: _PaymentRuleRepository([
          const PaymentRule(
            merchantKeyword: 'Test Store',
            paymentMethodId: 'wallet',
            bonusCashback: 1,
          ),
        ]),
        rewardRuleRepository: _RewardRuleRepository([
          _rewardRule('lower_rate'),
          _rewardRule('higher_rate'),
        ]),
      );
      await service.loadCards();

      final recommendations = service.recommend('Test Store');

      expect(recommendations.map((item) => item.creditCard.id), [
        'higher_rate',
        'lower_rate',
      ]);
      expect(recommendations.map((item) => item.totalCashback), [6, 4]);
      expect(service.recommend('Unknown Store'), isEmpty);
    },
  );

  test('ranks by obtainable reward and then offer conditions', () async {
    final cardIds = [
      'threshold',
      'registered',
      'earlier_expiry',
      'later_expiry',
      'capped_high_rate',
    ];
    final service = RecommendationService(
      cardRepository: _CardRepository([
        _card('threshold', 'Threshold', 5),
        _card('registered', 'Registration', 5),
        _card('earlier_expiry', 'Earlier expiry', 5),
        _card('later_expiry', 'Later expiry', 5),
        _card('capped_high_rate', 'Capped high rate', 8),
      ]),
      paymentMethodRepository: _PaymentMethodRepository([
        PaymentMethod(
          id: 'wallet',
          name: 'Test Wallet',
          type: 'wallet',
          supportedCards: cardIds,
          icon: 'wallet',
          description: '',
        ),
      ]),
      paymentRuleRepository: _PaymentRuleRepository(const []),
      rewardRuleRepository: _RewardRuleRepository([
        _rewardRule('threshold', minimumSpend: 1500),
        _rewardRule(
          'registered',
          needRegistration: true,
          endDate: DateTime(2028, 12, 31),
        ),
        _rewardRule('earlier_expiry', endDate: DateTime(2027, 12, 31)),
        _rewardRule('later_expiry', endDate: DateTime(2028, 12, 31)),
        _rewardRule('capped_high_rate', monthlyRewardLimit: 5),
      ]),
    );
    await service.loadCards();

    final recommendations = service.recommend(
      'Test Store',
      spendAmount: 1000,
      today: DateTime(2026, 10, 1),
    );

    expect(recommendations.map((item) => item.creditCard.id), [
      'later_expiry',
      'registered',
      'earlier_expiry',
      'capped_high_rate',
      'threshold',
    ]);
    expect(recommendations.map((item) => item.estimatedCashbackFor(1000)), [
      50,
      50,
      50,
      5,
      0,
    ]);
  });

  test('applies this month actual reward and resets for a new month', () async {
    final rewardRule = _rewardRule('only_card', monthlyRewardLimit: 888);
    final service = RecommendationService(
      cardRepository: _CardRepository([_card('only_card', 'Only card', 6)]),
      paymentMethodRepository: _PaymentMethodRepository([
        const PaymentMethod(
          id: 'wallet',
          name: 'Test Wallet',
          type: 'wallet',
          supportedCards: ['only_card'],
          icon: 'wallet',
          description: '',
        ),
      ]),
      paymentRuleRepository: _PaymentRuleRepository(const []),
      rewardRuleRepository: _RewardRuleRepository([rewardRule]),
      transactionRepository: _TransactionRepository([
        _transaction(rewardRule.usageKey, DateTime(2026, 10, 2), 800),
        _transaction(rewardRule.usageKey, DateTime(2026, 9, 28), 888),
      ]),
    );
    await service.loadCards();

    final october = service
        .recommend(
          'Test Store',
          spendAmount: 20000,
          today: DateTime(2026, 10, 8),
        )
        .single;
    final november = service
        .recommend(
          'Test Store',
          spendAmount: 20000,
          today: DateTime(2026, 11, 1),
        )
        .single;

    expect(october.usedMonthlyReward, 800);
    expect(october.remainingRewardLimit, 88);
    expect(october.estimatedCashbackFor(20000), 88);
    expect(november.usedMonthlyReward, 0);
    expect(november.estimatedCashbackFor(20000), 888);
  });

  test(
    'detects an expired offer and returns no active recommendation',
    () async {
      final service = RecommendationService(
        cardRepository: _CardRepository([_card('only_card', 'Only card', 6)]),
        paymentMethodRepository: _PaymentMethodRepository([
          const PaymentMethod(
            id: 'wallet',
            name: 'Test Wallet',
            type: 'wallet',
            supportedCards: ['only_card'],
            icon: 'wallet',
            description: '',
          ),
        ]),
        paymentRuleRepository: _PaymentRuleRepository(const []),
        rewardRuleRepository: _RewardRuleRepository([
          _rewardRule('only_card', endDate: DateTime(2026, 9, 30)),
        ]),
      );
      await service.loadCards();

      expect(
        service.recommend('Test Store', today: DateTime(2026, 10, 8)),
        isEmpty,
      );
      expect(
        service.hasExpiredOffer('Test Store', today: DateTime(2026, 10, 8)),
        isTrue,
      );
    },
  );
}

CreditCard _card(String id, String name, double cashbackRate) => CreditCard(
  id: id,
  bankName: 'Test Bank',
  cardName: name,
  rewardDescription: '',
  cashbackRate: cashbackRate,
  monthlyLimit: 0,
  needRegistration: false,
  notes: '',
);

RewardRule _rewardRule(
  String cardId, {
  int minimumSpend = 0,
  int monthlyRewardLimit = 0,
  bool needRegistration = false,
  DateTime? endDate,
}) => RewardRule(
  cardId: cardId,
  merchantKeyword: 'Test Store',
  startDate: DateTime(2020, 1, 1),
  endDate: endDate ?? DateTime(2030, 12, 31),
  minimumSpend: minimumSpend,
  monthlyRewardLimit: monthlyRewardLimit,
  maximumReward: 0,
  needRegistration: needRegistration,
  newCustomerOnly: false,
  notes: '',
);

class _CardRepository extends CardRepository {
  _CardRepository(this.cards);
  final List<CreditCard> cards;

  @override
  Future<List<CreditCard>> getAllCards() async => cards;
}

class _PaymentMethodRepository extends PaymentMethodRepository {
  _PaymentMethodRepository(this.paymentMethods);
  final List<PaymentMethod> paymentMethods;

  @override
  Future<List<PaymentMethod>> getAllPaymentMethods() async => paymentMethods;
}

class _PaymentRuleRepository extends PaymentRuleRepository {
  _PaymentRuleRepository(this.paymentRules);
  final List<PaymentRule> paymentRules;

  @override
  Future<List<PaymentRule>> getAllPaymentRules() async => paymentRules;
}

class _RewardRuleRepository extends RewardRuleRepository {
  _RewardRuleRepository(this.rewardRules);
  final List<RewardRule> rewardRules;

  @override
  Future<List<RewardRule>> getAllRewardRules() async => rewardRules;
}

class _TransactionRepository implements TransactionRepository {
  _TransactionRepository(this.transactions);
  final List<PaymentTransaction> transactions;

  @override
  Future<List<PaymentTransaction>> getAllTransactions() async => transactions;

  @override
  Future<void> save(PaymentTransaction transaction) async {}
}

PaymentTransaction _transaction(String key, DateTime date, double reward) =>
    PaymentTransaction(
      id: '$key-${date.toIso8601String()}',
      date: date,
      storeName: 'Test Store',
      spendAmount: 20000,
      paymentMethodId: 'wallet',
      paymentMethodName: 'Test Wallet',
      creditCardId: 'only_card',
      creditCardName: 'Only card',
      estimatedReward: 888,
      actualReward: reward,
      rewardRuleKey: key,
    );
