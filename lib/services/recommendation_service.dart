import 'package:pipora_pay_helper/models/credit_card.dart';
import 'package:pipora_pay_helper/models/merchant_rule.dart';
import 'package:pipora_pay_helper/services/card_repository.dart';
import 'package:pipora_pay_helper/services/merchant_rule_repository.dart';

class RecommendationService {
  RecommendationService({
    CardRepository? cardRepository,
    MerchantRuleRepository? merchantRuleRepository,
  }) : _cardRepository = cardRepository ?? CardRepository(),
       _merchantRuleRepository =
           merchantRuleRepository ?? MerchantRuleRepository();

  final CardRepository _cardRepository;
  final MerchantRuleRepository _merchantRuleRepository;
  List<CreditCard> _cards = const [];
  List<MerchantRule> _rules = const [];
  bool _isReady = false;

  bool get isReady => _isReady;

  Future<void> loadCards() async {
    _cards = await _cardRepository.getAllCards();
    _rules = await _merchantRuleRepository.getAllRules();
    _isReady = true;
  }

  List<CreditCard> recommend(String storeName) {
    if (!isReady) {
      throw StateError('Recommendation data has not been loaded.');
    }

    var recommendedCardId = 'hsbc_cashback_signature';
    for (final rule in _rules) {
      if (storeName.contains(rule.keyword)) {
        recommendedCardId = rule.cardId;
        break;
      }
    }

    final recommendedCard = _cardRepository.getCardById(recommendedCardId);
    final rankedCards = List<CreditCard>.of(_cards);
    rankedCards.sort((first, second) {
      if (first.id == recommendedCard.id) {
        return -1;
      }
      if (second.id == recommendedCard.id) {
        return 1;
      }
      return second.cashbackRate.compareTo(first.cashbackRate);
    });

    return rankedCards;
  }
}
