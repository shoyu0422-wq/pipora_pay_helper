import 'package:flutter/material.dart';
import 'package:pipora_pay_helper/l10n/app_localizations.dart';
import 'package:pipora_pay_helper/models/payment_recommendation.dart';

class PaymentRecommendationTile extends StatelessWidget {
  const PaymentRecommendationTile({
    super.key,
    required this.recommendation,
    required this.rank,
    this.isHighlighted = false,
    this.onTap,
  });

  final PaymentRecommendation recommendation;
  final int rank;
  final bool isHighlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final card = recommendation.creditCard;
    final paymentMethod = recommendation.paymentMethod;
    final rewardRule = recommendation.rewardRule;
    final l10n = AppLocalizations.of(context);

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
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurfaceVariant,
                    child: Icon(_paymentIcon(paymentMethod.icon)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.paymentMethod, style: textTheme.labelLarge),
                        const SizedBox(height: 2),
                        Text(
                          paymentMethod.name,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(_rankBadge(rank), style: textTheme.headlineSmall),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 8, bottom: 8),
                child: Icon(Icons.arrow_downward),
              ),
              Text(l10n.creditCard, style: textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(card.cardName, style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(card.bankName, style: textTheme.bodyMedium),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 12, bottom: 8),
                child: Icon(Icons.arrow_downward),
              ),
              Text(l10n.totalCashback, style: textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                '${_formatRate(recommendation.totalCashback)}%',
                style: textTheme.displaySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.promotionDetails, style: textTheme.labelLarge),
              const SizedBox(height: 8),
              _PromotionDetail(
                label: l10n.promotionValidUntil,
                value: _formatDate(rewardRule.endDate),
              ),
              const SizedBox(height: 4),
              _PromotionDetail(
                label: l10n.registrationRequired,
                value: rewardRule.needRegistration ? l10n.yes : l10n.no,
              ),
              const SizedBox(height: 4),
              _PromotionDetail(
                label: l10n.monthlyRewardLimit,
                value: _monthlyRewardLimit(rewardRule.monthlyRewardLimit, l10n),
              ),
              const SizedBox(height: 16),
              Text(l10n.recommendationReason, style: textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(recommendation.reason, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }

  IconData _paymentIcon(String icon) {
    return switch (icon) {
      'chat' => Icons.chat_outlined,
      'phone_iphone' => Icons.phone_iphone_outlined,
      'android' => Icons.android_outlined,
      'directions_transit' => Icons.directions_transit_outlined,
      'credit_card' => Icons.credit_card_outlined,
      'payments' => Icons.payments_outlined,
      'wallet' => Icons.account_balance_wallet_outlined,
      _ => Icons.account_balance_wallet_outlined,
    };
  }

  String _formatRate(double rate) {
    return rate == rate.roundToDouble() ? rate.toInt().toString() : '$rate';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _monthlyRewardLimit(int limit, AppLocalizations l10n) {
    return limit == 0 ? l10n.noLimit : 'NT\$$limit';
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

class _PromotionDetail extends StatelessWidget {
  const _PromotionDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(child: Text(label, style: textTheme.bodyMedium)),
        const SizedBox(width: 12),
        Text(value, style: textTheme.bodyMedium),
      ],
    );
  }
}
