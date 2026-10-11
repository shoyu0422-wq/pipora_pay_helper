import 'package:pipora_pay_helper/models/credit_card.dart';
import 'package:pipora_pay_helper/models/payment_method.dart';
import 'package:pipora_pay_helper/models/reward_rule.dart';

class PaymentRecommendation {
  const PaymentRecommendation({
    required this.paymentMethod,
    required this.creditCard,
    required this.paymentBonus,
    required this.totalCashback,
    required this.reason,
    required this.rewardRule,
    this.usedMonthlyReward = 0,
  });

  final PaymentMethod paymentMethod;
  final CreditCard creditCard;
  final double paymentBonus;
  final double totalCashback;
  final String reason;
  final RewardRule rewardRule;
  final double usedMonthlyReward;

  double? get rewardLimit {
    final limits = [
      rewardRule.monthlyRewardLimit,
      rewardRule.maximumReward,
    ].where((limit) => limit > 0);
    return limits.isEmpty
        ? null
        : limits.reduce((a, b) => a < b ? a : b).toDouble();
  }

  double? get remainingRewardLimit {
    final limit = rewardLimit;
    return limit == null
        ? null
        : (limit - usedMonthlyReward).clamp(0, limit).toDouble();
  }

  bool meetsMinimumSpend(double amount) => amount >= rewardRule.minimumSpend;

  double estimatedCashbackFor(double amount) {
    if (!meetsMinimumSpend(amount)) {
      return 0;
    }

    var estimatedCashback = amount * totalCashback / 100;
    final remainingLimit = remainingRewardLimit;
    if (remainingLimit != null && estimatedCashback > remainingLimit) {
      estimatedCashback = remainingLimit;
    }

    return estimatedCashback;
  }
}
