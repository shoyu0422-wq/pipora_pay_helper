import 'package:flutter_test/flutter_test.dart';
import 'package:pipora_pay_helper/models/payment_transaction.dart';
import 'package:pipora_pay_helper/services/transaction_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('transactions persist locally and replace an edited record', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesTransactionRepository();
    final first = _transaction(id: 'purchase', date: DateTime(2026, 10, 2));
    await repository.save(first);
    await repository.save(
      _transaction(
        id: 'purchase',
        date: first.date,
        estimatedReward: 10,
        actualReward: 8.5,
      ),
    );

    final transactions = await repository.getAllTransactions();
    expect(transactions, hasLength(1));
    expect(transactions.single.estimatedReward, 10);
    expect(transactions.single.actualReward, 8.5);
    expect(transactions.single.storeName, 'Test Store');
  });

  test('monthly ledger ignores other months and separates offers', () {
    final ledger = TransactionLedger([
      _transaction(id: 'oct', date: DateTime(2026, 10, 1)),
      _transaction(
        id: 'oct2',
        date: DateTime(2026, 10, 15),
        estimatedReward: 8,
      ),
      _transaction(id: 'nov', date: DateTime(2026, 11, 1)),
      _transaction(
        id: 'other-offer',
        date: DateTime(2026, 10, 3),
        rewardRuleKey: 'other-offer',
      ),
    ]);

    expect(ledger.usedRewardFor('test-offer', DateTime(2026, 10)), 18);
    expect(ledger.usedRewardFor('test-offer', DateTime(2026, 11)), 10);
    expect(ledger.totalRewardFor(DateTime(2026, 10)), 28);
    expect(ledger.inMonth(DateTime(2026, 10)), hasLength(3));
  });

  test('monthly allowance uses actual reward when it has been entered', () {
    final ledger = TransactionLedger([
      _transaction(
        id: 'settled',
        date: DateTime(2026, 10, 2),
        estimatedReward: 50,
        actualReward: 35,
      ),
      _transaction(
        id: 'pending',
        date: DateTime(2026, 10, 3),
        estimatedReward: 20,
      ),
    ]);

    expect(ledger.usedRewardFor('test-offer', DateTime(2026, 10)), 55);
    expect(ledger.totalRewardFor(DateTime(2026, 10)), 55);
  });
}

PaymentTransaction _transaction({
  required String id,
  required DateTime date,
  double estimatedReward = 10,
  double? actualReward,
  String rewardRuleKey = 'test-offer',
}) => PaymentTransaction(
  id: id,
  date: date,
  storeName: 'Test Store',
  spendAmount: 1000,
  paymentMethodId: 'wallet',
  paymentMethodName: 'Test Wallet',
  creditCardId: 'card',
  creditCardName: 'Test Card',
  estimatedReward: estimatedReward,
  actualReward: actualReward,
  rewardRuleKey: rewardRuleKey,
);
