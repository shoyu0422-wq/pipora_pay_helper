import 'package:flutter/material.dart';
import 'package:pipora_pay_helper/l10n/app_localizations.dart';
import 'package:pipora_pay_helper/models/credit_card.dart';

class CardDetailPage extends StatelessWidget {
  const CardDetailPage({super.key, required this.creditCard});

  final CreditCard creditCard;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

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
                            creditCard.bankName,
                            style: textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            creditCard.cardName,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(l10n.cashback, style: textTheme.labelLarge),
                          const SizedBox(height: 4),
                          Text(
                            '${_cashbackRate(creditCard.cashbackRate)}%',
                            style: textTheme.displaySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Column(
                      children: [
                        _DetailTile(
                          label: l10n.bank,
                          value: creditCard.bankName,
                        ),
                        const Divider(height: 1),
                        _DetailTile(
                          label: l10n.creditCard,
                          value: creditCard.cardName,
                        ),
                        const Divider(height: 1),
                        _DetailTile(
                          label: l10n.monthlyLimit,
                          value: _monthlyLimit(creditCard.monthlyLimit, l10n),
                        ),
                        const Divider(height: 1),
                        _DetailTile(
                          label: l10n.registrationRequired,
                          value: creditCard.needRegistration
                              ? l10n.yes
                              : l10n.no,
                        ),
                        const Divider(height: 1),
                        _DetailTile(label: l10n.notes, value: creditCard.notes),
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

  String _monthlyLimit(int monthlyLimit, AppLocalizations l10n) {
    return monthlyLimit == 0 ? l10n.noLimit : 'NT\$$monthlyLimit';
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
