import 'package:flutter/material.dart';
import 'package:pipora_pay_helper/l10n/app_localizations.dart';
import 'package:pipora_pay_helper/models/payment_recommendation.dart';

class CardDetailPage extends StatelessWidget {
  const CardDetailPage({
    super.key,
    required this.recommendation,
    this.spendAmount,
    this.onSaveTransaction,
  });

  final PaymentRecommendation recommendation;
  final double? spendAmount;
  final Future<bool> Function()? onSaveTransaction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final card = recommendation.creditCard;
    final rewardRule = recommendation.rewardRule;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cardDetails)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: colorScheme.onPrimaryContainer,
                            foregroundColor: colorScheme.primaryContainer,
                            child: const Icon(Icons.account_balance_outlined),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            card.bankName,
                            style: textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.cardName,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(l10n.cashback, style: textTheme.labelLarge),
                          const SizedBox(height: 4),
                          Text(
                            '${_cashbackRate(recommendation.totalCashback)}%',
                            style: textTheme.displaySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (spendAmount != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _estimatedRewardLabel(l10n),
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (onSaveTransaction != null) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        final saved = await onSaveTransaction!.call();
                        if (saved && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: Text(l10n.recordTransaction),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Card(
                    child: Column(
                      children: [
                        _DetailTile(
                          label: l10n.recommendationReason,
                          value: recommendation.reason,
                        ),
                        const Divider(height: 1),
                        _DetailTile(
                          label: l10n.paymentMethod,
                          value: recommendation.paymentMethod.name,
                        ),
                        const Divider(height: 1),
                        _DetailTile(label: l10n.bank, value: card.bankName),
                        const Divider(height: 1),
                        _DetailTile(
                          label: l10n.creditCard,
                          value: card.cardName,
                        ),
                        const Divider(height: 1),
                        _DetailTile(
                          label: l10n.monthlyLimit,
                          value: _monthlyLimit(card.monthlyLimit, l10n),
                        ),
                        const Divider(height: 1),
                        _DetailTile(
                          label: l10n.registrationRequired,
                          value: rewardRule.needRegistration
                              ? l10n.yes
                              : l10n.no,
                        ),
                        const Divider(height: 1),
                        _DetailTile(
                          label: l10n.promotionValidUntil,
                          value: _formatDate(rewardRule.endDate),
                        ),
                        const Divider(height: 1),
                        _DetailTile(
                          label: l10n.minimumSpendLabel,
                          value: rewardRule.minimumSpend == 0
                              ? l10n.noMinimumSpend
                              : 'NT\$${rewardRule.minimumSpend}',
                        ),
                        const Divider(height: 1),
                        _DetailTile(
                          label: l10n.monthlyRewardLimit,
                          value: _monthlyLimit(
                            rewardRule.monthlyRewardLimit,
                            l10n,
                          ),
                        ),
                        if (recommendation.remainingRewardLimit != null) ...[
                          const Divider(height: 1),
                          _DetailTile(
                            label: l10n.usedReward,
                            value:
                                'NT\$${recommendation.usedMonthlyReward.toStringAsFixed(2)}',
                          ),
                          const Divider(height: 1),
                          _DetailTile(
                            label: l10n.remainingRewardLimitLabel,
                            value: recommendation.remainingRewardLimit == 0
                                ? l10n.rewardLimitReached()
                                : l10n.remainingRewardAmount(
                                    recommendation.remainingRewardLimit!
                                        .toStringAsFixed(2),
                                  ),
                          ),
                        ],
                        if (rewardRule.maximumReward > 0) ...[
                          const Divider(height: 1),
                          _DetailTile(
                            label: l10n.maximumRewardWarning(
                              rewardRule.maximumReward,
                            ),
                            value: '',
                          ),
                        ],
                        if (rewardRule.newCustomerOnly) ...[
                          const Divider(height: 1),
                          _DetailTile(
                            label: l10n.newCustomerOnly,
                            value: l10n.yes,
                          ),
                        ],
                        const Divider(height: 1),
                        _DetailTile(label: l10n.notes, value: rewardRule.notes),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

  String _estimatedRewardLabel(AppLocalizations l10n) {
    if (!recommendation.meetsMinimumSpend(spendAmount!)) {
      return l10n.minimumSpendNotMet(recommendation.rewardRule.minimumSpend);
    }

    return l10n.estimatedReward(
      recommendation.estimatedCashbackFor(spendAmount!).toStringAsFixed(2),
    );
  }

  String _monthlyLimit(int monthlyLimit, AppLocalizations l10n) {
    return monthlyLimit == 0 ? l10n.noLimit : 'NT\$$monthlyLimit';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: value == null || value!.isEmpty ? null : Text(value!),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
