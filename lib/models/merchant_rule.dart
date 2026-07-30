class MerchantRule {
  const MerchantRule({required this.keyword, required this.cardId});

  final String keyword;
  final String cardId;

  factory MerchantRule.fromJson(Map<String, dynamic> json) {
    return MerchantRule(
      keyword: json['keyword'] as String,
      cardId: json['cardId'] as String,
    );
  }
}
