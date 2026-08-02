class CreditCard {
  const CreditCard({
    required this.id,
    required this.bankName,
    required this.cardName,
    required this.rewardDescription,
    required this.cashbackRate,
    required this.monthlyLimit,
    required this.needRegistration,
    required this.notes,
  });

  final String id;
  final String bankName;
  final String cardName;
  final String rewardDescription;
  final double cashbackRate;
  final int monthlyLimit;
  final bool needRegistration;
  final String notes;

  factory CreditCard.fromJson(Map<String, dynamic> json) {
    final cashbackRate = (json['cashbackRate'] as num).toDouble();
    return CreditCard(
      id: json['id'] as String,
      bankName: _bankName(json['bankName'] as String),
      cardName: _cardName(json['cardName'] as String),
      rewardDescription: _rewardDescription(cashbackRate),
      cashbackRate: cashbackRate,
      monthlyLimit: json['monthlyLimit'] as int,
      needRegistration: json['needRegistration'] as bool,
      notes: '詳細活動條件與限制請以發卡銀行公告為準。',
    );
  }

  static String _bankName(String name) {
    const names = {
      'Cathay United Bank': '國泰世華銀行',
      'CTBC Bank': '中國信託銀行',
      'E.SUN Bank': '玉山銀行',
      'Taipei Fubon Bank': '台北富邦銀行',
      'Taishin International Bank': '台新銀行',
      'SinoPac Bank': '永豐銀行',
      'Mega International Commercial Bank': '兆豐銀行',
      'First Commercial Bank': '第一銀行',
      'HSBC Taiwan': '滙豐（台灣）銀行',
      'The Shanghai Commercial & Savings Bank': '上海商業儲蓄銀行',
      'Union Bank of Taiwan': '聯邦銀行',
      'Bank of Taiwan': '臺灣銀行',
      'Hua Nan Bank': '華南銀行',
      'KGI Bank': '凱基銀行',
      'Yuanta Commercial Bank': '元大銀行',
      'Taiwan Cooperative Bank': '合作金庫銀行',
      'Land Bank of Taiwan': '土地銀行',
      'AEON Credit Service Taiwan': '台灣永旺信用卡',
      'O-Bank': '王道銀行',
      'DBS Bank Taiwan': '星展銀行（台灣）',
      'Standard Chartered Taiwan': '渣打銀行（台灣）',
    };

    return names[name] ?? name;
  }

  static String _cardName(String name) {
    const names = {
      'CUBE Card': 'CUBE 信用卡',
      'Cash Back Signature Card': '現金回饋御璽卡',
      'LINE Pay Credit Card': 'LINE Pay 信用卡',
      'China Airlines Co-branded Card': '中華航空聯名卡',
      'U Bear Credit Card': 'U Bear 信用卡',
      'Pi Wallet Credit Card': 'Pi 拍錢包信用卡',
      'J Card': 'J 卡',
      'momo Co-branded Card': 'momo 聯名卡',
      '@GoGo Card': '@GoGo 卡',
      'FlyGo Card': 'FlyGo 卡',
      'DAWHO Credit Card': 'DAWHO 信用卡',
      'SPORT Card': 'SPORT 卡',
      'MegaLite Digital Account Card': 'MegaLite 數位帳戶信用卡',
      'HAPPY GO Co-branded Card': 'HAPPY GO 聯名卡',
      'Living Green Card': '綠活信用卡',
      'iLEO Credit Card': 'iLEO 信用卡',
      'Live+ Cash Back Card': 'Live+ 現金回饋卡',
      'Teresa Card': 'Teresa 卡',
      'Lucky Crane Card': '吉鶴卡',
      'Asia Miles Co-branded Card': '亞洲萬里通聯名卡',
      'EVA Air Co-branded Card': '長榮航空聯名卡',
      'agoda Co-branded Card': 'agoda 聯名卡',
      'IKEA Co-branded Card': 'IKEA 聯名卡',
      'Unicard': 'Unicard 信用卡',
      'Only Card': 'Only 卡',
      'Costco Co-branded Card': 'Costco 聯名卡',
      'Royal Family Card': '皇室家族卡',
      'Richart Life Card': 'Richart Life 卡',
      'Rose Giving Card': '玫瑰 Giving 卡',
      'Green Card': '綠色信用卡',
      'Breeze Co-branded Card': '微風聯名卡',
      'Gogoro Co-branded Card': 'Gogoro 聯名卡',
      'Mega One Card': 'Mega One 卡',
      'Happy Card': '快樂卡',
      'iLEO Green Card': 'iLEO 綠色信用卡',
      'TravelOne Signature Card': '旅人御璽卡',
      'Red Credit Card': '紅利信用卡',
      'Taiwan Pay Credit Card': '台灣 Pay 信用卡',
      'Rich+ Credit Card': 'Rich+ 信用卡',
      'KGI One Card': 'KGI One 卡',
      'Love Credit Card': '愛金信用卡',
      'Joy Credit Card': '樂活信用卡',
      'Tiger Card': '老虎卡',
      'iCash Co-branded Card': 'icash 聯名卡',
      'WAON Card': 'WAON 卡',
      'Fun Card': 'Fun 卡',
      'ECO Card': 'ECO 卡',
    };

    return names[name] ?? name;
  }

  static String _rewardDescription(double cashbackRate) {
    if (cashbackRate == 0) {
      return '符合資格消費可享點數或哩程回饋，詳細條件依銀行公告。';
    }

    final rate = cashbackRate == cashbackRate.roundToDouble()
        ? cashbackRate.toInt().toString()
        : cashbackRate.toString();
    return '符合資格消費最高享 $rate% 回饋，詳細條件依銀行公告。';
  }
}
