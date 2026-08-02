import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pipora_pay_helper/models/reward_rule.dart';

class RewardRuleRepository {
  List<RewardRule>? _rewardRules;

  Future<List<RewardRule>> getAllRewardRules() async {
    if (_rewardRules != null) {
      return _rewardRules!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/data/reward_rules.json',
    );
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    _rewardRules = jsonList
        .map((item) => RewardRule.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    return _rewardRules!;
  }
}
