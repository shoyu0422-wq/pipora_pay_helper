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
  });

  final PaymentMethod paymentMethod;
  final CreditCard creditCard;
  final double paymentBonus;
  final double totalCashback;
  final String reason;
  final RewardRule rewardRule;
}
