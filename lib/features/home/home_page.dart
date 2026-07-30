import 'package:flutter/material.dart';
import 'package:pipora_pay_helper/features/card_detail/card_detail_page.dart';
import 'package:pipora_pay_helper/features/home/widgets/recommendation_list.dart';
import 'package:pipora_pay_helper/features/home/widgets/search_bar.dart';
import 'package:pipora_pay_helper/features/home/widgets/search_button.dart';
import 'package:pipora_pay_helper/models/credit_card.dart';
import 'package:pipora_pay_helper/services/recommendation_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storeController = TextEditingController();
  final _recommendationService = RecommendationService();
  List<CreditCard> _recommendedCards = const [];

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
      _recommendedCards = _recommendationService.recommend(
        _storeController.text,
      );
    });
  }

  void _showCardDetails(CreditCard creditCard) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardDetailPage(creditCard: creditCard),
      ),
    );
  }

  Future<void> _loadCards() async {
    await _recommendationService.loadCards();
    if (!mounted) {
      return;
    }

    setState(() {
      _recommendedCards = _recommendationService.recommend('7-11');
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                    'Find the Best Credit Card',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Search a store and get the best credit card recommendation.',
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  StoreSearchBar(controller: _storeController),
                  const SizedBox(height: 16),
                  SearchButton(onPressed: _search),
                  const SizedBox(height: 32),
                  if (_recommendedCards.isNotEmpty)
                    RecommendationList(
                      creditCards: _recommendedCards,
                      onCardTap: _showCardDetails,
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
