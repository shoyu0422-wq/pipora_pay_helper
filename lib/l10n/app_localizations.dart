import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;
  bool get _isEnglish => locale.languageCode == 'en';

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  String get noStoreFound => _isEnglish
      ? 'No matching store offers found. Try another store name.'
      : '找不到相關商店優惠，請嘗試其他名稱。';
  String get homeTitle =>
      _isEnglish ? 'Find the best way to pay' : '找出最優惠的付款方式';
  String get homeSubtitle => _isEnglish
      ? 'Search for a store to find the best payment method and card.'
      : '搜尋商店，取得最佳付款方式與信用卡建議。';
  String get searchHint => _isEnglish ? 'Enter a store name' : '輸入商店名稱';
  String get search => _isEnglish ? 'Search' : '搜尋';
  String get spendAmount => _isEnglish ? 'Purchase amount' : '消費金額';
  String get spendAmountHint => _isEnglish ? 'For example: 1,000' : '例如：1,000';
  String get paymentMethod => _isEnglish ? 'Payment method' : '付款方式';
  String get creditCard => _isEnglish ? 'Credit card' : '信用卡';
  String get totalCashback => _isEnglish ? 'Total rewards' : '總回饋';
  String get highestCashback => _isEnglish ? 'Best reward rate' : '最高回饋';
  String get recommendationReason =>
      _isEnglish ? 'Why this is recommended' : '推薦原因';
  String get promotionDetails => _isEnglish ? 'Offer details' : '活動資訊';
  String get promotionValidUntil => _isEnglish ? 'Valid until' : '活動期限';
  String get registrationRequired =>
      _isEnglish ? 'Registration required' : '需登錄';
  String get monthlyRewardLimit =>
      _isEnglish ? 'Monthly reward limit' : '每月回饋上限';
  String get remainingRewardLimitLabel =>
      _isEnglish ? 'Remaining offer allowance' : '剩餘優惠回饋額度';
  String get noLimit => _isEnglish ? 'No limit' : '無上限';
  String get yes => _isEnglish ? 'Yes' : '是';
  String get no => _isEnglish ? 'No' : '否';
  String get cardDetails => _isEnglish ? 'Card details' : '信用卡詳情';
  String get bank => _isEnglish ? 'Issuing bank' : '發卡銀行';
  String get cashback => _isEnglish ? 'Reward rate' : '回饋';
  String get reward => _isEnglish ? 'Reward' : '優惠';
  String get monthlyLimit => _isEnglish ? 'Monthly limit' : '每月上限';
  String get minimumSpendLabel => _isEnglish ? 'Minimum spend' : '最低消費';
  String get noMinimumSpend => _isEnglish ? 'No minimum' : '無最低消費';
  String get notes => _isEnglish ? 'Notes' : '注意事項';
  String get newCustomerOnly => _isEnglish ? 'New customers only' : '限新戶';
  String get monthlyEarnedReward =>
      _isEnglish ? 'Rewards logged this month' : '本月已登記回饋';
  String get transactionHistory => _isEnglish ? 'Transactions' : '消費紀錄';
  String get noTransactions => _isEnglish ? 'No transactions yet' : '尚無消費紀錄';
  String get recordTransaction =>
      _isEnglish ? 'Record this purchase' : '記錄這筆消費';
  String get transactionSaved => _isEnglish ? 'Purchase recorded' : '已記錄消費';
  String get transactionSaveError => _isEnglish
      ? 'Could not save the transaction. Please try again.'
      : '無法儲存消費紀錄，請稍後再試';
  String get dataLoadError => _isEnglish
      ? 'Could not load offer data. Please try again.'
      : '無法取得優惠資料，請重試';
  String get missingOfferData => _isEnglish
      ? 'Offer data is missing. Please try again later.'
      : '目前沒有優惠資料，請稍後重試';
  String get retry => _isEnglish ? 'Retry' : '重試';
  String get expiredPromotion => _isEnglish
      ? 'This store has no currently active offers.'
      : '這間商店目前沒有有效中優惠';
  String get noEligiblePromotion =>
      _isEnglish ? 'No eligible payment offers were found.' : '目前沒有符合的付款優惠';
  String remainingRewardAmount(String amount) => _isEnglish
      ? 'Remaining reward allowance: NT\$$amount'
      : '剩餘回饋額度 NT\$$amount';
  String rewardLimitReached() =>
      _isEnglish ? 'Reward allowance reached' : '本月回饋額度已用完';
  String usedRewardAmount(String amount) =>
      _isEnglish ? 'Rewards used: NT\$$amount' : '已使用回饋額度 NT\$$amount';
  String recommendationRank(int rank) =>
      _isEnglish ? 'Rank $rank' : '推薦排名 $rank';
  String cardCashback(String rate) =>
      _isEnglish ? '✓ Card reward $rate%' : '✓ 信用卡回饋 $rate%';
  String paymentBonus(String name, String rate) =>
      _isEnglish ? '✓ $name bonus $rate%' : '✓ $name 加碼 $rate%';
  String paymentBonusSummary(String name, String rate) =>
      _isEnglish ? '$name bonus $rate%' : '$name 加碼 $rate%';
  String designatedPaymentRoute(String cardName, String paymentMethodName) =>
      _isEnglish
      ? 'Use $cardName with $paymentMethodName'
      : '指定 $cardName／$paymentMethodName';
  String registrationWarning() =>
      _isEnglish ? '⚠ Registration required' : '⚠ 需登錄';
  String monthlyRewardLimitWarning(int amount) => _isEnglish
      ? '⚠ Monthly reward limit NT\$$amount'
      : '⚠ 每月回饋上限 NT\$$amount';
  String minimumSpendWarning(int amount) =>
      _isEnglish ? '⚠ Minimum spend NT\$$amount' : '⚠ 最低消費 NT\$$amount';
  String maximumRewardWarning(int amount) =>
      _isEnglish ? '⚠ Maximum reward NT\$$amount' : '⚠ 最高回饋 NT\$$amount';
  String estimatedReward(String amount) =>
      _isEnglish ? 'Estimated reward: NT\$$amount' : '預估本筆回饋 NT\$$amount';
  String minimumSpendNotMet(int amount) => _isEnglish
      ? 'Minimum spend of NT\$$amount not met'
      : '未達最低消費 NT\$$amount';
  String get invalidSpendAmount => _isEnglish
      ? 'Enter a valid amount greater than 0, such as 1,000 or 1,000.50.'
      : '請輸入大於 0 的有效金額，例如 1,000 或 1,000.50';
  String newCustomerWarning() => _isEnglish ? '⚠ New customers only' : '⚠ 限新戶';
  String genericTermsNote() => _isEnglish
      ? 'Check the issuer’s official terms for full conditions and exclusions.'
      : '活動條件及限制請以發卡銀行公告為準。';

  String get transactionDetails => _isEnglish ? 'Transaction details' : '消費明細';
  String get purchaseDate => _isEnglish ? 'Purchase date' : '消費日期';
  String get store => _isEnglish ? 'Store' : '商店';
  String get estimatedRewardLabel => _isEnglish ? 'Estimated reward' : '預估回饋';
  String get actualReward => _isEnglish ? 'Actual reward' : '實際回饋';
  String get actualRewardHint =>
      _isEnglish ? 'Enter the posted reward' : '輸入帳單實際回饋';
  String get notEntered => _isEnglish ? 'Not entered' : '尚未輸入';
  String get saveActualReward => _isEnglish ? 'Save actual reward' : '儲存實際回饋';
  String get invalidActualReward => _isEnglish
      ? 'Enter a valid reward amount, including 0 if no reward was received.'
      : '請輸入有效的實際回饋金額，若無回饋請輸入 0';
  String get actualRewardSaved =>
      _isEnglish ? 'Actual reward saved' : '已更新實際回饋';
  String rewardValue(String amount, {required bool isActual}) => _isEnglish
      ? '${isActual ? 'Actual' : 'Estimated'} NT\$$amount'
      : '${isActual ? '實際' : '預估'} NT\$$amount';

  String get usedReward => _isEnglish ? 'Used allowance' : '已使用額度';

  String registrationAndTerms(String registration, String terms) =>
      [registration, terms].where((value) => value.isNotEmpty).join('\n');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'zh' || locale.languageCode == 'en';

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
