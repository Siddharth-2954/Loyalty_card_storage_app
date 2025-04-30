import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/loyalty_card.dart';

class DatabaseService {
  static const String _cardsKey = 'loyalty_cards';

  Future<List<LoyaltyCard>> getCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getStringList(_cardsKey) ?? [];
    return cardsJson.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return LoyaltyCard(
        id: map['id'] as String,
        name: map['name'] as String,
        cardNumber: map['cardNumber'] as String,
        description: map['description'] as String?,
        expiryDate:
            map['expiryDate'] != null
                ? DateTime.parse(map['expiryDate'] as String)
                : null,
        isFavorite: map['isFavorite'] as bool? ?? false,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
    }).toList();
  }

  Future<void> saveCards(List<LoyaltyCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson =
        cards.map((card) {
          return jsonEncode({
            'id': card.id,
            'name': card.name,
            'cardNumber': card.cardNumber,
            'description': card.description,
            'expiryDate': card.expiryDate?.toIso8601String(),
            'isFavorite': card.isFavorite,
            'createdAt': card.createdAt.toIso8601String(),
          });
        }).toList();
    await prefs.setStringList(_cardsKey, cardsJson);
  }

  Future<LoyaltyCard?> getCard(String id) async {
    final cards = await getCards();
    try {
      return cards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> insertCard(LoyaltyCard card) async {
    final cards = await getCards();
    cards.add(card);
    await saveCards(cards);
  }

  Future<void> updateCard(LoyaltyCard card) async {
    final cards = await getCards();
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      cards[index] = card;
      await saveCards(cards);
    }
  }

  Future<void> deleteCard(String id) async {
    final cards = await getCards();
    cards.removeWhere((card) => card.id == id);
    await saveCards(cards);
  }

  Future<List<LoyaltyCard>> getExpiringCards() async {
    final cards = await getCards();
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));

    return cards.where((card) {
      if (card.expiryDate == null) return false;
      return card.expiryDate!.isAfter(now) &&
          card.expiryDate!.isBefore(thirtyDaysLater);
    }).toList();
  }
}
