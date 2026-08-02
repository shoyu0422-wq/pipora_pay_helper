import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pipora_pay_helper/models/payment_rule.dart';

class PaymentRuleRepository {
  List<PaymentRule>? _paymentRules;

  Future<List<PaymentRule>> getAllPaymentRules() async {
    if (_paymentRules != null) {
      return _paymentRules!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/data/payment_rules.json',
    );
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    _paymentRules = jsonList
        .map((item) => PaymentRule.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    return _paymentRules!;
  }
}
