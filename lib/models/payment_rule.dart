class PaymentRule {
  const PaymentRule({
    required this.merchantKeyword,
    required this.paymentMethodId,
    required this.bonusCashback,
  });

  final String merchantKeyword;
  final String paymentMethodId;
  final double bonusCashback;

  factory PaymentRule.fromJson(Map<String, dynamic> json) {
    return PaymentRule(
      merchantKeyword: json['merchantKeyword'] as String,
      paymentMethodId: json['paymentMethodId'] as String,
      bonusCashback: (json['bonusCashback'] as num).toDouble(),
    );
  }
}
