import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:loyalty_card_wallet/models/loyalty_card.dart';
import 'package:loyalty_card_wallet/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  final DatabaseService _databaseService = DatabaseService();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isSyncing = false;
  
  // Mock API URL - replace with your actual backend URL
  final String _apiUrl = 'https://api.everydayrewards.com/api/v1/cards';
  
  factory SyncService() => _instance;

  SyncService._internal();

  Future<void> init() async {
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        syncCards();
      }
    });
    
    // Check if we're online and sync on startup
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      syncCards();
    }
  }

  Future<void> syncCards() async {
    if (_isSyncing) return;
    _isSyncing = true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      
      if (authToken == null) {
        _isSyncing = false;
        return;
      }
      
      // Get cards that need to be synced
      final pendingCards = await _databaseService.getPendingSyncCards();
      
      // Get last sync timestamp
      final lastSync = prefs.getInt('last_sync_timestamp') ?? 0;
      
      // Upload pending changes
      for (final card in pendingCards) {
        await _uploadCard(card, authToken);
        await _databaseService.markCardSynced(card.id);
      }
      
      // Download new changes
      await _downloadCards(lastSync, authToken);
      
      // Update last sync timestamp
      await prefs.setInt('last_sync_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _uploadCard(LoyaltyCard card, String authToken) async {
    try {
      final response = await http.put(
        Uri.parse('$_apiUrl/${card.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(card.toMap()),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to upload card: ${response.body}');
      }
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }

  Future<void> _downloadCards(int lastSync, String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl?updated_since=$lastSync'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> cardsJson = jsonDecode(response.body);
        
        for (final cardJson in cardsJson) {
          final card = LoyaltyCard.fromMap(cardJson);
          await _databaseService.insertCard(card);
          await _databaseService.markCardSynced(card.id);
        }
      } else {
        throw Exception('Failed to download cards: ${response.body}');
      }
    } catch (e) {
      print('Download error: $e');
      rethrow;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
