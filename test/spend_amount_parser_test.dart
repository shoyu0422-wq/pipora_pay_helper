import 'package:flutter_test/flutter_test.dart';
import 'package:pipora_pay_helper/utils/amount_parser.dart';

void main() {
  group('parseSpendAmount', () {
    test('accepts positive amounts with optional thousands separators', () {
      expect(parseSpendAmount('1000'), 1000);
      expect(parseSpendAmount('1,000'), 1000);
      expect(parseSpendAmount('1,000.50'), 1000.5);
    });

    test('rejects blank, zero, and malformed amounts', () {
      expect(parseSpendAmount(''), isNull);
      expect(parseSpendAmount('0'), isNull);
      expect(parseSpendAmount('1,00'), isNull);
      expect(parseSpendAmount('1,000.999'), isNull);
      expect(parseSpendAmount(List.filled(400, '9').join()), isNull);
    });
  });

  group('parseRewardAmount', () {
    test('accepts zero and valid rewards', () {
      expect(parseRewardAmount('0'), 0);
      expect(parseRewardAmount('18.50'), 18.5);
    });

    test('rejects malformed or non-finite rewards', () {
      expect(parseRewardAmount('1,00'), isNull);
      expect(parseRewardAmount(List.filled(400, '9').join()), isNull);
    });
  });
}
