import 'package:flutter/material.dart';
import 'package:pipora_pay_helper/features/card_detail/card_detail_page.dart';
import 'package:pipora_pay_helper/features/home/widgets/recommendation_list.dart';
import 'package:pipora_pay_helper/features/home/widgets/search_bar.dart';
import 'package:pipora_pay_helper/features/home/widgets/search_button.dart';
import 'package:pipora_pay_helper/models/payment_recommendation.dart';
import 'package:pipora_pay_helper/services/recommendation_service.dart';
import 'package:pipora_pay_helper/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storeController = TextEditingController();
  final _recommendationService = RecommendationService();
  List<PaymentRecommendation> _recommendations = const [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  @override
  void dispose() {
    _storeController.dispose();
    super.dispose();
  }

  void _search() {
    if (!_recommendationService.isReady) {
      return;
    }

    setState(() {
      _recommendations = _recommendationService.recommend(
        _storeController.text,
      );
    });
  }

  void _showCardDetails(PaymentRecommendation recommendation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CardDetailPage(creditCard: recommendation.creditCard),
      ),
    );
  }

  Future<void> _loadCards() async {
    await _recommendationService.loadCards();
    if (!mounted) {
      return;
    }

    setState(() {
      _recommendations = _recommendationService.recommend('7-11');
    });
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
                  ),
                  const SizedBox(height: 16),
                  SearchButton(label: l10n.search, onPressed: _search),
                  const SizedBox(height: 32),
                  if (_recommendations.isNotEmpty)
                    RecommendationList(
                      recommendations: _recommendations,
                      onRecommendationTap: _showCardDetails,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
