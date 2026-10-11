import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipora_pay_helper/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('English locale displays English home copy', (tester) async {
    await tester.pumpWidget(const App(locale: Locale('en', 'US')));
    await tester.pump();

    expect(find.text('Find the best way to pay'), findsOneWidget);
    expect(find.text('Enter a store name'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });
}
