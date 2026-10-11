import 'dart:convert';

import 'package:pipora_pay_helper/models/payment_transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class TransactionRepository {
  Future<List<PaymentTransaction>> getAllTransactions();

  Future<void> save(PaymentTransaction transaction);
}

class SharedPreferencesTransactionRepository implements TransactionRepository {
  SharedPreferencesTransactionRepository({this.preferences});

  static const _storageKey = 'payment_transactions_v1';
  final SharedPreferences? preferences;
  Future<SharedPreferences>? _preferencesFuture;

  Future<SharedPreferences> get _store =>
      _preferencesFuture ??= preferences == null
      ? SharedPreferences.getInstance()
      : Future.value(preferences);

  @override
  Future<List<PaymentTransaction>> getAllTransactions() async {
    final jsonString = (await _store).getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return const [];
    }

    try {
      final values = jsonDecode(jsonString) as List<dynamic>;
      return values
          .map(
            (value) =>
                PaymentTransaction.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false);
    } on FormatException {
      return const [];
    } on TypeError {
      return const [];
    }
  }

  @override
  Future<void> save(PaymentTransaction transaction) async {
    final store = await _store;
    final transactions = await getAllTransactions();
    final updated = [
      for (final item in transactions)
        if (item.id != transaction.id) item,
      transaction,
    ];
    await store.setString(
      _storageKey,
      jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
  }
}

class TransactionLedger {
  const TransactionLedger(this.transactions);

  final List<PaymentTransaction> transactions;

  List<PaymentTransaction> inMonth(DateTime month) => transactions
      .where(
        (transaction) =>
            transaction.date.year == month.year &&
            transaction.date.month == month.month,
      )
      .toList(growable: false);

  double usedRewardFor(String rewardRuleKey, DateTime month) => inMonth(month)
      .where((transaction) => transaction.rewardRuleKey == rewardRuleKey)
      .fold(0, (total, transaction) => total + transaction.rewardForLimit);

  double totalRewardFor(DateTime month) => inMonth(
    month,
  ).fold(0, (total, transaction) => total + transaction.rewardForLimit);
}
