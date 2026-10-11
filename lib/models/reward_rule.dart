class RewardRule {
  const RewardRule({
    required this.cardId,
    required this.merchantKeyword,
    required this.startDate,
    required this.endDate,
    required this.minimumSpend,
    required this.monthlyRewardLimit,
    required this.maximumReward,
    required this.needRegistration,
    required this.newCustomerOnly,
    required this.notes,
  });

  final String cardId;
  final String merchantKeyword;
  final DateTime startDate;
  final DateTime endDate;
  final int minimumSpend;
  final int monthlyRewardLimit;
  final int maximumReward;
  final bool needRegistration;
  final bool newCustomerOnly;
  final String notes;

  String get usageKey =>
      '$cardId|$merchantKeyword|${_dateKey(startDate)}|${_dateKey(endDate)}';

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  factory RewardRule.fromJson(Map<String, dynamic> json) {
    return RewardRule(
      cardId: json['cardId'] as String,
      merchantKeyword: json['merchantKeyword'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      minimumSpend: json['minimumSpend'] as int,
      monthlyRewardLimit: json['monthlyRewardLimit'] as int,
      maximumReward: json['maximumReward'] as int,
      needRegistration: json['needRegistration'] as bool,
      newCustomerOnly: json['newCustomerOnly'] as bool,
      notes: '活動條件及限制請以發卡銀行公告為準。',
    );
  }

  bool isActiveOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(startDate) && !day.isAfter(endDate);
  }
}
