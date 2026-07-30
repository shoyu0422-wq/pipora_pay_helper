import 'package:flutter/material.dart';
import 'package:pipora_pay_helper/features/home/widgets/credit_card_tile.dart';
import 'package:pipora_pay_helper/models/credit_card.dart';

class RecommendationList extends StatelessWidget {
  const RecommendationList({
    super.key,
    required this.creditCards,
    this.onCardTap,
  });

  final List<CreditCard> creditCards;
  final ValueChanged<CreditCard>? onCardTap;

  @override
  Widget build(BuildContext context) {
    final topRecommendations = creditCards.take(3).toList();

    return Column(
      children: [
        for (var index = 0; index < topRecommendations.length; index++) ...[
          CreditCardTile(
            creditCard: topRecommendations[index],
            rank: index + 1,
            isHighlighted: index == 0,
            onTap: onCardTap == null
                ? null
                : () => onCardTap!(topRecommendations[index]),
          ),
          if (index < topRecommendations.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}
