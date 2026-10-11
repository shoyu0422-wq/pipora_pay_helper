import 'package:flutter/material.dart';
import 'package:pipora_pay_helper/l10n/app_localizations.dart';
import 'package:pipora_pay_helper/models/payment_recommendation.dart';

class PaymentRecommendationTile extends StatelessWidget {
  const PaymentRecommendationTile({
    super.key,
    required this.recommendation,
    required this.rank,
    this.spendAmount,
    this.isHighlighted = false,
    this.onTap,
  });

  final PaymentRecommendation recommendation;
  final int rank;
  final double? spendAmount;
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
    final surfaceColor = isHighlighted
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerLow;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: surfaceColor,
      elevation: isHighlighted ? 4 : 1,
      surfaceTintColor: isHighlighted ? colorScheme.primary : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isHighlighted
              ? colorScheme.primary.withValues(alpha: 0.35)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _RankLabel(
                    label: l10n.recommendationRank(rank),
                    isHighlighted: isHighlighted,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                    semanticLabel: l10n.cardDetails,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _PaymentRoute(
                paymentMethodName: paymentMethod.name,
                paymentIcon: _paymentIcon(paymentMethod.icon),
                cardName: card.cardName,
                bankName: card.bankName,
              ),
              const SizedBox(height: 20),
              _CashbackSummary(
                label: l10n.highestCashback,
                rate: '${_formatRate(recommendation.totalCashback)}%',
                cardCashbackLabel: l10n.cardCashback(
                  _formatRate(card.cashbackRate),
                ),
                bonus: recommendation.paymentBonus,
                bonusLabel: l10n.paymentBonusSummary(
                  paymentMethod.name,
                  _formatRate(recommendation.paymentBonus),
                ),
              ),
              const SizedBox(height: 16),
              _RecommendationReason(
                label: l10n.recommendationReason,
                reason: recommendation.reason,
              ),
              if (spendAmount != null) ...[
                const SizedBox(height: 12),
                _EstimatedRewardSummary(
                  recommendation: recommendation,
                  spendAmount: spendAmount!,
                ),
              ],
              const SizedBox(height: 20),
              Text(l10n.promotionDetails, style: textTheme.titleSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ConditionChip(
                    icon: Icons.event_outlined,
                    label:
                        '${l10n.promotionValidUntil} ${_formatDate(rewardRule.endDate)}',
                  ),
                  if (rewardRule.needRegistration)
                    _ConditionChip(
                      icon: Icons.app_registration_outlined,
                      label: l10n.registrationWarning(),
                    ),
                  _ConditionChip(
                    icon: Icons.credit_card_outlined,
                    label: l10n.designatedPaymentRoute(
                      card.cardName,
                      paymentMethod.name,
                    ),
                  ),
                  if (rewardRule.monthlyRewardLimit > 0)
                    _ConditionChip(
                      icon: Icons.account_balance_wallet_outlined,
                      label: l10n.monthlyRewardLimitWarning(
                        rewardRule.monthlyRewardLimit,
                      ),
                    ),
                  if (recommendation.remainingRewardLimit != null)
                    _ConditionChip(
                      icon: Icons.savings_outlined,
                      label: recommendation.remainingRewardLimit == 0
                          ? l10n.rewardLimitReached()
                          : l10n.remainingRewardAmount(
                              _formatAmount(
                                recommendation.remainingRewardLimit!,
                              ),
                            ),
                    ),
                ],
              ),
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

  String _formatAmount(double amount) => amount.toStringAsFixed(2);

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _RecommendationReason extends StatelessWidget {
  const _RecommendationReason({required this.label, required this.reason});

  final String label;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(reason, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _EstimatedRewardSummary extends StatelessWidget {
  const _EstimatedRewardSummary({
    required this.recommendation,
    required this.spendAmount,
  });

  final PaymentRecommendation recommendation;
  final double spendAmount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meetsMinimumSpend = recommendation.meetsMinimumSpend(spendAmount);
    final colorScheme = Theme.of(context).colorScheme;
    final label = meetsMinimumSpend
        ? l10n.estimatedReward(
            recommendation.estimatedCashbackFor(spendAmount).toStringAsFixed(2),
          )
        : l10n.minimumSpendNotMet(recommendation.rewardRule.minimumSpend);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: meetsMinimumSpend
            ? colorScheme.tertiaryContainer
            : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: meetsMinimumSpend
                ? colorScheme.onTertiaryContainer
                : colorScheme.onErrorContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RankLabel extends StatelessWidget {
  const _RankLabel({required this.label, required this.isHighlighted});

  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isHighlighted
        ? colorScheme.primary
        : colorScheme.secondaryContainer;
    final foregroundColor = isHighlighted
        ? colorScheme.onPrimary
        : colorScheme.onSecondaryContainer;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PaymentRoute extends StatelessWidget {
  const _PaymentRoute({
    required this.paymentMethodName,
    required this.paymentIcon,
    required this.cardName,
    required this.bankName,
  });

  final String paymentMethodName;
  final IconData paymentIcon;
  final String cardName;
  final String bankName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RouteItem(
          icon: paymentIcon,
          label: AppLocalizations.of(context).paymentMethod,
          title: paymentMethodName,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RouteItem(
            icon: Icons.credit_card_outlined,
            label: AppLocalizations.of(context).creditCard,
            title: cardName,
            subtitle: bankName,
          ),
        ),
      ],
    );
  }
}

class _RouteItem extends StatelessWidget {
  const _RouteItem({
    required this.icon,
    required this.label,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurfaceVariant,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(label, style: textTheme.labelMedium),
        const SizedBox(height: 2),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _CashbackSummary extends StatelessWidget {
  const _CashbackSummary({
    required this.label,
    required this.rate,
    required this.cardCashbackLabel,
    required this.bonus,
    required this.bonusLabel,
  });

  final String label;
  final String rate;
  final String cardCashbackLabel;
  final double bonus;
  final String bonusLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasBonus = bonus > 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings_outlined, color: colorScheme.onPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
                Text(
                  rate,
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: colorScheme.onPrimary.withValues(alpha: 0.24)),
            const SizedBox(height: 8),
            Text(
              cardCashbackLabel,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
            if (hasBonus) ...[
              const SizedBox(height: 4),
              Text(
                bonusLabel,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Chip(
      avatar: Icon(icon, size: 18, color: colorScheme.onSecondaryContainer),
      backgroundColor: colorScheme.secondaryContainer,
      side: BorderSide.none,
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: colorScheme.onSecondaryContainer,
      ),
    );
  }
}
