class CreditCard {
  const CreditCard({
    required this.id,
    required this.bankName,
    required this.cardName,
    required this.rewardDescription,
    required this.cashbackRate,
    required this.monthlyLimit,
    required this.needRegistration,
    required this.notes,
  });

  final String id;
  final String bankName;
  final String cardName;
  final String rewardDescription;
  final double cashbackRate;
  final int monthlyLimit;
  final bool needRegistration;
  final String notes;

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    return CreditCard(
      id: json['id'] as String,
      bankName: json['bankName'] as String,
      cardName: json['cardName'] as String,
      rewardDescription: json['rewardDescription'] as String,
      cashbackRate: (json['cashbackRate'] as num).toDouble(),
      monthlyLimit: json['monthlyLimit'] as int,
      needRegistration: json['needRegistration'] as bool,
      notes: json['notes'] as String,
    );
  }
}
