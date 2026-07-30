import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pipora_pay_helper/models/credit_card.dart';

class CardRepository {
  List<CreditCard>? _cards;

  Future<List<CreditCard>> getAllCards() async {
    if (_cards != null) {
      return _cards!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/data/credit_cards.json',
    );
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    _cards = jsonList
        .map((item) => CreditCard.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    return _cards!;
  }

  CreditCard getCardById(String cardId) {
    final cards = _cards;
    if (cards == null) {
      throw StateError('Card data has not been loaded.');
    }

    return cards.firstWhere((card) => card.id == cardId);
  }
}
