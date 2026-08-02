import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get homeTitle => '找出最優惠的付款方式';
  String get homeSubtitle => '搜尋商店，取得最佳付款方式與信用卡建議。';
  String get searchHint => '輸入商店名稱';
  String get search => '搜尋';
  String get paymentMethod => '付款方式';
  String get creditCard => '信用卡';
  String get totalCashback => '總回饋';
  String get recommendationReason => '推薦原因';
  String get promotionDetails => '活動資訊';
  String get promotionValidUntil => '活動期限';
  String get registrationRequired => '需登錄';
  String get monthlyRewardLimit => '每月回饋上限';
  String get noLimit => '無上限';
  String get yes => '是';
  String get no => '否';
  String get cardDetails => '信用卡詳情';
  String get bank => '發卡銀行';
  String get cashback => '回饋';
  String get monthlyLimit => '每月上限';
  String get notes => '注意事項';
  String get newCustomerOnly => '限新戶';

  String cardCashback(String rate) => '✓ 信用卡回饋 $rate%';
  String paymentBonus(String name, String rate) => '✓ $name 加碼 $rate%';
  String registrationWarning() => '⚠ 需登錄';
  String monthlyRewardLimitWarning(int amount) => '⚠ 每月回饋上限 NT\$$amount';
  String minimumSpendWarning(int amount) => '⚠ 最低消費 NT\$$amount';
  String maximumRewardWarning(int amount) => '⚠ 最高回饋 NT\$$amount';
  String newCustomerWarning() => '⚠ 限新戶';
  String genericTermsNote() => '活動條件及限制請以發卡銀行公告為準。';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'zh';

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
