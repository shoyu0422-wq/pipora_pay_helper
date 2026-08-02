import 'package:flutter/material.dart';
import 'package:pipora_pay_helper/features/home/widgets/payment_recommendation_tile.dart';
import 'package:pipora_pay_helper/models/payment_recommendation.dart';

class RecommendationList extends StatelessWidget {
  const RecommendationList({
    super.key,
    required this.recommendations,
    this.onRecommendationTap,
  });

  final List<PaymentRecommendation> recommendations;
  final ValueChanged<PaymentRecommendation>? onRecommendationTap;

  @override
  Widget build(BuildContext context) {
    final topRecommendations = recommendations.take(3).toList();

    return Column(
      children: [
        for (var index = 0; index < topRecommendations.length; index++) ...[
          PaymentRecommendationTile(
            recommendation: topRecommendations[index],
            rank: index + 1,
            isHighlighted: index == 0,
            onTap: onRecommendationTap == null
                ? null
                : () => onRecommendationTap!(topRecommendations[index]),
          ),
          if (index < topRecommendations.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}
