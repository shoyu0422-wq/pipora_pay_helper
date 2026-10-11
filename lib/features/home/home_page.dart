import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pipora_pay_helper/features/card_detail/card_detail_page.dart';
import 'package:pipora_pay_helper/features/home/widgets/recommendation_list.dart';
import 'package:pipora_pay_helper/features/home/widgets/search_bar.dart';
import 'package:pipora_pay_helper/features/home/widgets/search_button.dart';
import 'package:pipora_pay_helper/features/transactions/transaction_detail_page.dart';
import 'package:pipora_pay_helper/models/payment_recommendation.dart';
import 'package:pipora_pay_helper/models/payment_transaction.dart';
import 'package:pipora_pay_helper/services/recommendation_service.dart';
import 'package:pipora_pay_helper/services/merchant_rule_repository.dart';
import 'package:pipora_pay_helper/services/transaction_repository.dart';
import 'package:pipora_pay_helper/l10n/app_localizations.dart';
import 'package:pipora_pay_helper/utils/amount_parser.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.transactionRepository,
    this.recommendationService,
  });

  final TransactionRepository? transactionRepository;
  final RecommendationService? recommendationService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storeController = TextEditingController();
  final _spendAmountController = TextEditingController();
  late final TransactionRepository _transactionRepository;
  late final RecommendationService _recommendationService;
  List<PaymentRecommendation> _recommendations = const [];
  String? _spendAmountError;
  String? _loadError;
  List<PaymentTransaction> _transactions = const [];
  bool _isLoading = true;
  bool _hasSearched = false;
  bool _searchRequestedWhileLoading = false;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _transactionRepository =
        widget.transactionRepository ??
        SharedPreferencesTransactionRepository();
    _recommendationService =
        widget.recommendationService ??
        RecommendationService(
          transactionRepository: _transactionRepository,
          merchantRuleRepository: MerchantRuleRepository(),
        );
    _loadCards();
  }

  @override
  void dispose() {
    _storeController.dispose();
    _spendAmountController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_currentLocale == locale) return;
    _currentLocale = locale;
    _recommendationService.setLocale(locale);
    if (_recommendationService.isReady) {
      _recommendations = _recommendationService.recommend(
        _currentStoreName,
        spendAmount: _spendAmount(),
      );
    }
  }

  String get _currentStoreName =>
      _storeController.text.trim().isEmpty && !_hasSearched
      ? '7-11'
      : _storeController.text;

  void _search() {
    if (_loadError != null) return;

    final rawSpendAmount = _spendAmountController.text;
    if (rawSpendAmount.trim().isNotEmpty &&
        parseSpendAmount(rawSpendAmount) == null) {
      setState(() {
        _spendAmountError = AppLocalizations.of(context).invalidSpendAmount;
      });
      return;
    }

    if (!_recommendationService.isReady) {
      _searchRequestedWhileLoading = true;
      return;
    }

    setState(() {
      _spendAmountError = null;
      _hasSearched = true;
      _recommendations = _recommendationService.recommend(
        _storeController.text,
        spendAmount: _spendAmount(),
      );
    });
  }

  void _showCardDetails(
    PaymentRecommendation recommendation,
    double? spendAmount,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardDetailPage(
          recommendation: recommendation,
          spendAmount: spendAmount,
          onSaveTransaction: spendAmount == null
              ? null
              : () => _saveTransaction(recommendation, spendAmount),
        ),
      ),
    );
  }

  Future<bool> _saveTransaction(
    PaymentRecommendation recommendation,
    double spendAmount,
  ) async {
    final transaction = PaymentTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: DateTime.now(),
      storeName: _storeController.text.trim().isEmpty
          ? recommendation.rewardRule.merchantKeyword
          : _storeController.text.trim(),
      spendAmount: spendAmount,
      paymentMethodId: recommendation.paymentMethod.id,
      paymentMethodName: recommendation.paymentMethod.name,
      creditCardId: recommendation.creditCard.id,
      creditCardName: recommendation.creditCard.cardName,
      estimatedReward: recommendation.estimatedCashbackFor(spendAmount),
      rewardRuleKey: recommendation.rewardRule.usageKey,
    );

    try {
      await _recommendationService.recordTransaction(transaction);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).transactionSaveError),
          ),
        );
      }
      return false;
    }
    if (!mounted) return false;
    setState(() {
      _transactions = _recommendationService.transactions;
      _recommendations = _recommendationService.recommend(
        _currentStoreName,
        spendAmount: _spendAmount(),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).transactionSaved)),
    );
    return true;
  }

  void _showTransactionDetails(PaymentTransaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TransactionDetailPage(
          transaction: transaction,
          onSaveActualReward: (amount) =>
              _saveActualReward(transaction, amount),
        ),
      ),
    );
  }

  Future<bool> _saveActualReward(
    PaymentTransaction transaction,
    double amount,
  ) async {
    try {
      await _recommendationService.recordTransaction(
        transaction.copyWith(actualReward: amount),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).transactionSaveError),
          ),
        );
      }
      return false;
    }
    if (!mounted) return false;
    setState(() {
      _transactions = _recommendationService.transactions;
      _recommendations = _recommendationService.recommend(
        _currentStoreName,
        spendAmount: _spendAmount(),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).actualRewardSaved)),
    );
    return true;
  }

  double? _spendAmount() {
    return parseSpendAmount(_spendAmountController.text);
  }

  Future<void> _loadCards() async {
    if (!_isLoading && mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
        _recommendations = const [];
        _hasSearched = false;
      });
    }
    try {
      await _recommendationService.loadCards();
      if (!mounted) return;
      final hasOfferData = _recommendationService.hasOfferData;
      final searchWasSubmitted = _searchRequestedWhileLoading;
      _searchRequestedWhileLoading = false;
      setState(() {
        _isLoading = false;
        _loadError = hasOfferData
            ? null
            : AppLocalizations.of(context).missingOfferData;
        _transactions = _recommendationService.transactions;
        _hasSearched = searchWasSubmitted;
        _recommendations = hasOfferData
            ? _recommendationService.recommend(
                searchWasSubmitted ? _storeController.text : _currentStoreName,
                spendAmount: _spendAmount(),
              )
            : const [];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = AppLocalizations.of(context).dataLoadError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pipora Pay Helper')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.homeTitle,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.homeSubtitle,
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  StoreSearchBar(
                    controller: _storeController,
                    hintText: l10n.searchHint,
                    onSubmitted: (_) => _search(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _spendAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: (_) {
                      setState(() {
                        _spendAmountError = null;
                        if (_recommendationService.isReady) {
                          final store =
                              _storeController.text.trim().isEmpty &&
                                  !_hasSearched
                              ? '7-11'
                              : _storeController.text;
                          _recommendations = _recommendationService.recommend(
                            store,
                            spendAmount: _spendAmount(),
                          );
                        }
                      });
                    },
                    onSubmitted: (_) => _search(),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: l10n.spendAmountHint,
                      labelText: l10n.spendAmount,
                      prefixText: 'NT\$ ',
                      errorText: _spendAmountError,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SearchButton(
                    label: l10n.search,
                    onPressed: _isLoading || _loadError != null
                        ? null
                        : _search,
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  if (_loadError != null) ...[
                    const SizedBox(height: 16),
                    Text(_loadError!, textAlign: TextAlign.center),
                    TextButton(onPressed: _loadCards, child: Text(l10n.retry)),
                  ],
                  const SizedBox(height: 32),
                  if (_recommendations.isNotEmpty)
                    RecommendationList(
                      recommendations: _recommendations,
                      spendAmount: _spendAmount(),
                      onRecommendationTap: _showCardDetails,
                    )
                  else if (_hasSearched)
                    Text(
                      !_recommendationService.hasKnownStore(
                            _storeController.text,
                          )
                          ? l10n.noStoreFound
                          : _recommendationService.hasExpiredOffer(
                              _storeController.text,
                            )
                          ? l10n.expiredPromotion
                          : l10n.noEligiblePromotion,
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  if (_recommendationService.isReady) ...[
                    const SizedBox(height: 24),
                    _TransactionSummary(
                      transactions: _transactions,
                      monthlyReward: _recommendationService.currentMonthReward,
                      onTransactionTap: _showTransactionDetails,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionSummary extends StatelessWidget {
  const _TransactionSummary({
    required this.transactions,
    required this.monthlyReward,
    required this.onTransactionTap,
  });

  final List<PaymentTransaction> transactions;
  final double monthlyReward;
  final ValueChanged<PaymentTransaction> onTransactionTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recentTransactions = transactions.toList()
      ..sort((first, second) => second.date.compareTo(first.date));

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.savings_outlined),
            title: Text(l10n.monthlyEarnedReward),
            trailing: Text('NT\$${monthlyReward.toStringAsFixed(2)}'),
          ),
          ExpansionTile(
            title: Text(l10n.transactionHistory),
            subtitle: Text('${transactions.length}'),
            children: recentTransactions.isEmpty
                ? [ListTile(title: Text(l10n.noTransactions), dense: true)]
                : [
                    for (final transaction in recentTransactions)
                      ListTile(
                        title: Text(transaction.storeName),
                        subtitle: Text(
                          '${_formatDate(transaction.date)} · '
                          '${transaction.paymentMethodName} · '
                          '${transaction.creditCardName}',
                        ),
                        trailing: Text(
                          l10n.rewardValue(
                            (transaction.actualReward ??
                                    transaction.estimatedReward)
                                .toStringAsFixed(2),
                            isActual: transaction.actualReward != null,
                          ),
                        ),
                        dense: true,
                        onTap: () => onTransactionTap(transaction),
                      ),
                  ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
