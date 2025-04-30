import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'loyalty_card.dart';

class CardService extends ChangeNotifier {
  List<LoyaltyCard> _cards = [];

  List<LoyaltyCard> get cards => _cards;

  // Load cards from local storage (Hive)
  Future<void> loadCards() async {
    var box = await Hive.openBox('loyaltyCards');
    _cards = box.values.cast<LoyaltyCard>().toList();
    notifyListeners();
  }

  // Add new card to local storage and sync with Firebase
  Future<void> addCard(LoyaltyCard card) async {
    var box = await Hive.openBox('loyaltyCards');
    box.add(card);
    _cards.add(card);
    notifyListeners();

    // Sync with Firebase Cloud
    // (Implement cloud sync logic here)
  }

  // Handle Push Notifications
  void setupPushNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show notification
      print('Received message: ${message.notification?.title}');
      // Implement notification logic here
    });
  }
}
