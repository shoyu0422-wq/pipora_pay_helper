// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:pipora_pay_helper/app/app.dart';
import 'package:pipora_pay_helper/features/home/widgets/payment_recommendation_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the credit card recommendation page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App(locale: Locale('zh', 'TW')));
    await tester.pump();
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byType(PaymentRecommendationTile).evaluate().isNotEmpty) break;
    }
    expect(find.byType(PaymentRecommendationTile), findsAtLeastNWidgets(1));

    expect(find.text('Pipora Pay Helper'), findsOneWidget);
    expect(find.text('找出最優惠的付款方式'), findsOneWidget);
    expect(find.text('輸入商店名稱'), findsOneWidget);
    expect(find.text('LINE Pay'), findsAtLeastNWidgets(1));
    expect(find.text('CUBE 信用卡'), findsAtLeastNWidgets(1));
  });
}
