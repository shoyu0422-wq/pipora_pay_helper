import 'dart:ui' show Locale;

import 'package:pipora_pay_helper/l10n/app_localizations.dart';
import 'package:pipora_pay_helper/models/credit_card.dart';
import 'package:pipora_pay_helper/models/payment_method.dart';
import 'package:pipora_pay_helper/models/payment_recommendation.dart';
import 'package:pipora_pay_helper/models/payment_rule.dart';
import 'package:pipora_pay_helper/models/reward_rule.dart';
import 'package:pipora_pay_helper/services/card_repository.dart';
import 'package:pipora_pay_helper/services/payment_method_repository.dart';
import 'package:pipora_pay_helper/services/payment_rule_repository.dart';
import 'package:pipora_pay_helper/services/reward_rule_repository.dart';

class RecommendationService {
  static const _l10n = AppLocalizations(Locale('zh', 'TW'));

  RecommendationService({
    CardRepository? cardRepository,
    PaymentMethodRepository? paymentMethodRepository,
    PaymentRuleRepository? paymentRuleRepository,
    RewardRuleRepository? rewardRuleRepository,
  }) : _cardRepository = cardRepository ?? CardRepository(),
       _paymentMethodRepository =
           paymentMethodRepository ?? PaymentMethodRepository(),
       _paymentRuleRepository =
           paymentRuleRepository ?? PaymentRuleRepository(),
       _rewardRuleRepository = rewardRuleRepository ?? RewardRuleRepository();

  final CardRepository _cardRepository;
  final PaymentMethodRepository _paymentMethodRepository;
  final PaymentRuleRepository _paymentRuleRepository;
  final RewardRuleRepository _rewardRuleRepository;
  List<CreditCard> _cards = const [];
  List<PaymentMethod> _paymentMethods = const [];
  List<PaymentRule> _paymentRules = const [];
  List<RewardRule> _rewardRules = const [];
  bool _isReady = false;

  bool get isReady => _isReady;

  Future<void> loadCards() async {
    _cards = await _cardRepository.getAllCards();
    _paymentMethods = await _paymentMethodRepository.getAllPaymentMethods();
    _paymentRules = await _paymentRuleRepository.getAllPaymentRules();
    _rewardRules = await _rewardRuleRepository.getAllRewardRules();
    _isReady = true;
  }

  List<PaymentRecommendation> recommend(String storeName) {
    if (!isReady) {
      throw StateError('Recommendation data has not been loaded.');
    }

    final matchingPaymentRules = _paymentRules
        .where((rule) => storeName.contains(rule.merchantKeyword))
        .toList();
    final recommendations = <PaymentRecommendation>[];
    final today = DateTime.now();

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
          today,
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
          ),
        );
      }
    }

    recommendations.sort((first, second) {
      final cashbackComparison = second.totalCashback.compareTo(
        first.totalCashback,
      );
      if (cashbackComparison != 0) {
        return cashbackComparison;
      }
      return second.paymentBonus.compareTo(first.paymentBonus);
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
          storeName.contains(rule.merchantKeyword) &&
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
