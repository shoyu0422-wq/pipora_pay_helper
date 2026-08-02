import 'package:flutter/material.dart';
import 'package:pipora_pay_helper/features/home/home_page.dart';
import 'package:pipora_pay_helper/l10n/app_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pipora Pay Helper',
      debugShowCheckedModeBanner: false,
      locale: const Locale('zh', 'TW'),
      supportedLocales: const [Locale('zh', 'TW')],
      localizationsDelegates: const [AppLocalizations.delegate],
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}
