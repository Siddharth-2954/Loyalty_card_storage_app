import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/loyalty_card.dart';
import 'package:loyalty_card_wallet/services/database_service.dart';
import 'package:loyalty_card_wallet/services/notification_service.dart';

class CardProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final _uuid = const Uuid();

  List<LoyaltyCard> _cards = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _sortBy = 'name'; // 'name', 'date', 'expiry'
  bool _showFavoritesOnly = false;

  List<LoyaltyCard> get cards {
    List<LoyaltyCard> filteredCards = [..._cards];

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredCards =
          filteredCards.where((card) {
            return card.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                card.cardNumber.contains(_searchQuery) ||
                (card.description?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false);
          }).toList();
    }

    // Apply favorites filter
    if (_showFavoritesOnly) {
      filteredCards = filteredCards.where((card) => card.isFavorite).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        filteredCards.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        filteredCards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'expiry':
        filteredCards.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        });
        break;
    }

    return filteredCards;
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get showFavoritesOnly => _showFavoritesOnly;

  CardProvider() {
    loadCards();
  }

  Future<void> loadCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cards = await _databaseService.getCards();
    } catch (e) {
      print('Error loading cards: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addCard(LoyaltyCard card) {
    _cards.add(card);
    notifyListeners();
  }

  void removeCard(String cardId) {
    _cards.removeWhere((card) => card.id == cardId);
    notifyListeners();
  }

  void updateCard(String cardId, Map<String, dynamic> updatedCard) {
    final index = _cards.indexWhere((card) => card.id == cardId);
    if (index != -1) {
      _cards[index] = updatedCard;
      notifyListeners();
    }
  }

  Future<void> addCard(LoyaltyCard card) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newCard = LoyaltyCard(
        id: _uuid.v4(),
        name: card.name,
        cardNumber: card.cardNumber,
        description: card.description,
        expiryDate: card.expiryDate,
        isFavorite: card.isFavorite,
      );

      _cards.add(newCard);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCard(LoyaltyCard card) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _cards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _cards[index] = card;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCard(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _cards.removeWhere((card) => card.id == id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleFavorite(String id) async {
    final index = _cards.indexWhere((card) => card.id == id);
    if (index != -1) {
      final card = _cards[index];
      final updatedCard = card.copyWith(isFavorite: !card.isFavorite);
      await updateCard(updatedCard);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void toggleFavoritesOnly() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  List<LoyaltyCard> getExpiringCards() {
    return _cards
        .where((card) => card.isExpiringSoon() && !card.isExpired())
        .toList();
  }
}
