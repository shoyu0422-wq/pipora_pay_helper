import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pipora_pay_helper/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('\u986f\u793a\u627e\u4e0d\u5230\u5546\u5e97\u7684\u63d0\u793a', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App(locale: Locale('zh', 'TW')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'unmatched store');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(
      find.text(
        '\u627e\u4e0d\u5230\u76f8\u95dc\u5546\u5e97\u512a\u60e0\uff0c\u8acb\u5617\u8a66\u5176\u4ed6\u540d\u7a31\u3002',
      ),
      findsOneWidget,
    );
  });
}
