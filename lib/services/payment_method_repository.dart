import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pipora_pay_helper/models/payment_method.dart';

class PaymentMethodRepository {
  List<PaymentMethod>? _paymentMethods;

  Future<List<PaymentMethod>> getAllPaymentMethods() async {
    if (_paymentMethods != null) {
      return _paymentMethods!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/data/payment_methods.json',
    );
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    _paymentMethods = jsonList
        .map((item) => PaymentMethod.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    return _paymentMethods!;
  }
}
