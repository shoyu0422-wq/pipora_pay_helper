import 'dart:ui' show Locale;

import 'package:pipora_pay_helper/l10n/app_localizations.dart';
import 'package:pipora_pay_helper/models/credit_card.dart';
import 'package:pipora_pay_helper/models/payment_method.dart';
import 'package:pipora_pay_helper/models/payment_recommendation.dart';
import 'package:pipora_pay_helper/models/payment_rule.dart';
import 'package:pipora_pay_helper/models/payment_transaction.dart';
import 'package:pipora_pay_helper/models/merchant_rule.dart';
import 'package:pipora_pay_helper/models/reward_rule.dart';
import 'package:pipora_pay_helper/services/card_repository.dart';
import 'package:pipora_pay_helper/services/merchant_rule_repository.dart';
import 'package:pipora_pay_helper/services/payment_method_repository.dart';
import 'package:pipora_pay_helper/services/payment_rule_repository.dart';
import 'package:pipora_pay_helper/services/reward_rule_repository.dart';
import 'package:pipora_pay_helper/services/transaction_repository.dart';

class RecommendationService {
  RecommendationService({
    Locale locale = const Locale('zh', 'TW'),
    CardRepository? cardRepository,
    PaymentMethodRepository? paymentMethodRepository,
    PaymentRuleRepository? paymentRuleRepository,
    RewardRuleRepository? rewardRuleRepository,
    this.merchantRuleRepository,
    this.transactionRepository,
  }) : _l10n = AppLocalizations(locale),
       _cardRepository = cardRepository ?? CardRepository(),
       _paymentMethodRepository =
           paymentMethodRepository ?? PaymentMethodRepository(),
       _paymentRuleRepository =
           paymentRuleRepository ?? PaymentRuleRepository(),
       _rewardRuleRepository = rewardRuleRepository ?? RewardRuleRepository();

  final CardRepository _cardRepository;
  final PaymentMethodRepository _paymentMethodRepository;
  final PaymentRuleRepository _paymentRuleRepository;
  final RewardRuleRepository _rewardRuleRepository;
  final MerchantRuleRepository? merchantRuleRepository;
  final TransactionRepository? transactionRepository;
  AppLocalizations _l10n;
  List<CreditCard> _cards = const [];
  List<PaymentMethod> _paymentMethods = const [];
  List<PaymentRule> _paymentRules = const [];
  List<RewardRule> _rewardRules = const [];
  List<MerchantRule> _merchantRules = const [];
  List<PaymentTransaction> _transactions = const [];
  bool _isReady = false;

  bool get isReady => _isReady;
  bool get hasOfferData => _rewardRules.isNotEmpty;

  void setLocale(Locale locale) {
    _l10n = AppLocalizations(locale);
  }

  List<PaymentTransaction> get transactions => List.unmodifiable(_transactions);

  double get currentMonthReward =>
      TransactionLedger(_transactions).totalRewardFor(DateTime.now());

  Future<void> recordTransaction(PaymentTransaction transaction) async {
    final repository = transactionRepository;
    if (repository == null) {
      throw StateError('Transaction storage is not configured.');
    }
    await repository.save(transaction);
    _transactions = [
      for (final item in _transactions)
        if (item.id != transaction.id) item,
      transaction,
    ];
  }

  bool hasKnownStore(String storeName) {
    final normalizedStore = storeName.toLowerCase();
    if (normalizedStore.trim().isEmpty) return false;
    return _merchantRules.any(
          (rule) => normalizedStore.contains(rule.keyword.toLowerCase()),
        ) ||
        _rewardRules.any(
          (rule) =>
              normalizedStore.contains(rule.merchantKeyword.toLowerCase()),
        ) ||
        _paymentRules.any(
          (rule) =>
              normalizedStore.contains(rule.merchantKeyword.toLowerCase()),
        );
  }

  bool hasExpiredOffer(String storeName, {DateTime? today}) {
    final date = today ?? DateTime.now();
    if (storeName.trim().isEmpty) return false;
    return _rewardRules.any(
      (rule) =>
          storeName.toLowerCase().contains(
            rule.merchantKeyword.toLowerCase(),
          ) &&
          rule.endDate.isBefore(DateTime(date.year, date.month, date.day)),
    );
  }

  Future<void> loadCards() async {
    _cards = await _cardRepository.getAllCards();
    _paymentMethods = await _paymentMethodRepository.getAllPaymentMethods();
    _paymentRules = await _paymentRuleRepository.getAllPaymentRules();
    _rewardRules = await _rewardRuleRepository.getAllRewardRules();
    _merchantRules = await merchantRuleRepository?.getAllRules() ?? const [];
    _transactions =
        await transactionRepository?.getAllTransactions() ?? const [];
    _isReady = true;
  }

  List<PaymentRecommendation> recommend(
    String storeName, {
    double? spendAmount,
    DateTime? today,
  }) {
    if (!isReady) {
      throw StateError('Recommendation data has not been loaded.');
    }

    final normalizedStore = storeName.toLowerCase();
    final matchingPaymentRules = _paymentRules
        .where(
          (rule) =>
              normalizedStore.contains(rule.merchantKeyword.toLowerCase()),
        )
        .toList();
    final recommendations = <PaymentRecommendation>[];
    final currentDate = today ?? DateTime.now();

    for (final paymentMethod in _paymentMethods) {
      final paymentBonus = _paymentBonus(
        paymentMethod.id,
        matchingPaymentRules,
      );
      for (final cardId in paymentMethod.supportedCards) {
        final creditCard = _cardById(cardId);
        if (creditCard == null) {
          continue;
        }

        final rewardRule = _activeRewardRuleFor(
          creditCard.id,
          storeName,
          currentDate,
        );
        if (rewardRule == null) {
          continue;
        }

        recommendations.add(
          PaymentRecommendation(
            paymentMethod: paymentMethod,
            creditCard: creditCard,
            paymentBonus: paymentBonus,
            totalCashback: creditCard.cashbackRate + paymentBonus,
            reason: _reason(
              creditCard.cashbackRate,
              paymentMethod.name,
              paymentBonus,
              rewardRule,
            ),
            rewardRule: rewardRule,
            usedMonthlyReward: TransactionLedger(
              _transactions,
            ).usedRewardFor(rewardRule.usageKey, currentDate),
          ),
        );
      }
    }

    recommendations.sort((first, second) {
      final firstReward = spendAmount == null
          ? first.totalCashback
          : first.estimatedCashbackFor(spendAmount);
      final secondReward = spendAmount == null
          ? second.totalCashback
          : second.estimatedCashbackFor(spendAmount);
      final rewardComparison = secondReward.compareTo(firstReward);
      if (rewardComparison != 0) return rewardComparison;

      final remainingComparison =
          (second.remainingRewardLimit ?? double.infinity).compareTo(
            first.remainingRewardLimit ?? double.infinity,
          );
      if (remainingComparison != 0) return remainingComparison;

      final minimumSpendComparison = first.rewardRule.minimumSpend.compareTo(
        second.rewardRule.minimumSpend,
      );
      if (minimumSpendComparison != 0) return minimumSpendComparison;

      final expirationComparison = second.rewardRule.endDate.compareTo(
        first.rewardRule.endDate,
      );
      if (expirationComparison != 0) return expirationComparison;

      if (first.rewardRule.needRegistration !=
          second.rewardRule.needRegistration) {
        return first.rewardRule.needRegistration ? 1 : -1;
      }

      final paymentMethodComparison = second.paymentBonus.compareTo(
        first.paymentBonus,
      );
      if (paymentMethodComparison != 0) return paymentMethodComparison;

      return second.totalCashback.compareTo(first.totalCashback);
    });

    return recommendations;
  }

  CreditCard? _cardById(String cardId) {
    for (final card in _cards) {
      if (card.id == cardId) {
        return card;
      }
    }
    return null;
  }

  RewardRule? _activeRewardRuleFor(
    String cardId,
    String storeName,
    DateTime today,
  ) {
    for (final rule in _rewardRules) {
      if (rule.cardId == cardId &&
          storeName.toLowerCase().contains(
            rule.merchantKeyword.toLowerCase(),
          ) &&
          rule.isActiveOn(today)) {
        return rule;
      }
    }
    return null;
  }

  double _paymentBonus(String paymentMethodId, List<PaymentRule> rules) {
    var bonus = 0.0;
    for (final rule in rules) {
      if (rule.paymentMethodId == paymentMethodId &&
          rule.bonusCashback > bonus) {
        bonus = rule.bonusCashback;
      }
    }
    return bonus;
  }

  String _reason(
    double cardCashback,
    String paymentMethodName,
    double paymentBonus,
    RewardRule rewardRule,
  ) {
    final lines = <String>[
      _l10n.cardCashback(_formatRate(cardCashback)),
      if (paymentBonus > 0)
        _l10n.paymentBonus(paymentMethodName, _formatRate(paymentBonus)),
      if (rewardRule.needRegistration) _l10n.registrationWarning(),
      if (rewardRule.monthlyRewardLimit > 0)
        _l10n.monthlyRewardLimitWarning(rewardRule.monthlyRewardLimit),
      if (rewardRule.minimumSpend > 0)
        _l10n.minimumSpendWarning(rewardRule.minimumSpend),
      if (rewardRule.maximumReward > 0)
        _l10n.maximumRewardWarning(rewardRule.maximumReward),
      if (rewardRule.newCustomerOnly) _l10n.newCustomerWarning(),
      if (rewardRule.notes.isNotEmpty) 'ℹ ${rewardRule.notes}',
    ];

    return lines.join('\n');
  }

  String _formatRate(double rate) {
    return rate == rate.roundToDouble() ? rate.toInt().toString() : '$rate';
  }
}
