import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pipora_pay_helper/models/merchant_rule.dart';

class MerchantRuleRepository {
  List<MerchantRule>? _rules;

  Future<List<MerchantRule>> getAllRules() async {
    if (_rules != null) {
      return _rules!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/data/merchant_rules.json',
    );
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    _rules = jsonList
        .map((item) => MerchantRule.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    return _rules!;
  }
}
