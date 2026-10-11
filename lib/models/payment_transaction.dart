class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.date,
    required this.storeName,
    required this.spendAmount,
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.creditCardId,
    required this.creditCardName,
    required this.estimatedReward,
    required this.rewardRuleKey,
    this.actualReward,
  });

  final String id;
  final DateTime date;
  final String storeName;
  final double spendAmount;
  final String paymentMethodId;
  final String paymentMethodName;
  final String creditCardId;
  final String creditCardName;
  final double estimatedReward;
  final double? actualReward;
  final String rewardRuleKey;

  double get rewardForLimit => actualReward ?? estimatedReward;

  String get monthKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  PaymentTransaction copyWith({double? actualReward}) => PaymentTransaction(
    id: id,
    date: date,
    storeName: storeName,
    spendAmount: spendAmount,
    paymentMethodId: paymentMethodId,
    paymentMethodName: paymentMethodName,
    creditCardId: creditCardId,
    creditCardName: creditCardName,
    estimatedReward: estimatedReward,
    rewardRuleKey: rewardRuleKey,
    actualReward: actualReward ?? this.actualReward,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'storeName': storeName,
    'spendAmount': spendAmount,
    'paymentMethodId': paymentMethodId,
    'paymentMethodName': paymentMethodName,
    'creditCardId': creditCardId,
    'creditCardName': creditCardName,
    'estimatedReward': estimatedReward,
    'actualReward': actualReward,
    'rewardRuleKey': rewardRuleKey,
  };

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) =>
      PaymentTransaction(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        storeName: json['storeName'] as String,
        spendAmount: (json['spendAmount'] as num).toDouble(),
        paymentMethodId: json['paymentMethodId'] as String,
        paymentMethodName: json['paymentMethodName'] as String,
        creditCardId: json['creditCardId'] as String,
        creditCardName: json['creditCardName'] as String,
        estimatedReward: (json['estimatedReward'] as num).toDouble(),
        actualReward: (json['actualReward'] as num?)?.toDouble(),
        rewardRuleKey: json['rewardRuleKey'] as String,
      );
}
