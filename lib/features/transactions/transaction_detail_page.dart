import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pipora_pay_helper/l10n/app_localizations.dart';
import 'package:pipora_pay_helper/models/payment_transaction.dart';
import 'package:pipora_pay_helper/utils/amount_parser.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({
    super.key,
    required this.transaction,
    required this.onSaveActualReward,
  });

  final PaymentTransaction transaction;
  final Future<bool> Function(double actualReward) onSaveActualReward;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late final TextEditingController _actualRewardController;
  String? _actualRewardError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _actualRewardController = TextEditingController(
      text: widget.transaction.actualReward?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _actualRewardController.dispose();
    super.dispose();
  }

  Future<void> _saveActualReward() async {
    final actualReward = parseRewardAmount(_actualRewardController.text);
    if (actualReward == null) {
      setState(() {
        _actualRewardError = AppLocalizations.of(context).invalidActualReward;
      });
      return;
    }

    setState(() {
      _actualRewardError = null;
      _isSaving = true;
    });
    final saved = await widget.onSaveActualReward(actualReward);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final transaction = widget.transaction;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactionDetails)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _DetailItem(
              label: l10n.purchaseDate,
              value: _formatDate(transaction.date),
            ),
            _DetailItem(label: l10n.store, value: transaction.storeName),
            _DetailItem(
              label: l10n.spendAmount,
              value: _currency(transaction.spendAmount),
            ),
            _DetailItem(
              label: l10n.paymentMethod,
              value: transaction.paymentMethodName,
            ),
            _DetailItem(
              label: l10n.creditCard,
              value: transaction.creditCardName,
            ),
            _DetailItem(
              label: l10n.estimatedRewardLabel,
              value: _currency(transaction.estimatedReward),
            ),
            _DetailItem(
              label: l10n.actualReward,
              value: transaction.actualReward == null
                  ? l10n.notEntered
                  : _currency(transaction.actualReward!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _actualRewardController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.actualReward,
                hintText: l10n.actualRewardHint,
                prefixText: 'NT\$ ',
                errorText: _actualRewardError,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveActualReward,
              icon: const Icon(Icons.save_outlined),
              label: Text(l10n.saveActualReward),
            ),
          ],
        ),
      ),
    );
  }

  String _currency(double amount) => 'NT\$${amount.toStringAsFixed(2)}';

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(value),
  );
}
