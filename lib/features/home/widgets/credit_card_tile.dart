import 'package:flutter/material.dart';
import 'package:pipora_pay_helper/models/credit_card.dart';

class CreditCardTile extends StatelessWidget {
  const CreditCardTile({
    super.key,
    required this.creditCard,
    required this.rank,
    this.isHighlighted = false,
    this.onTap,
  });

  final CreditCard creditCard;
  final int rank;
  final bool isHighlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: isHighlighted ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurfaceVariant,
                    child: const Icon(Icons.account_balance_outlined),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(creditCard.bankName, style: textTheme.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                          creditCard.cardName,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(_rankBadge(rank), style: textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 24),
              Text('Cashback', style: textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                '${_cashbackRate(creditCard.cashbackRate)}%',
                style: textTheme.displaySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text('Reward', style: textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                creditCard.rewardDescription,
                style: textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _cashbackRate(double cashbackRate) {
    if (cashbackRate == cashbackRate.roundToDouble()) {
      return cashbackRate.toInt().toString();
    }

    return cashbackRate.toString();
  }

  String _rankBadge(int rank) {
    return switch (rank) {
      1 => '\ud83e\udd47',
      2 => '\ud83e\udd48',
      3 => '\ud83e\udd49',
      _ => '',
    };
  }
}
