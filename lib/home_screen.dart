import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_service.dart';
import 'add_card_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cardService = Provider.of<CardService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Loyalty Cards'),
      ),
      body: ListView.builder(
        itemCount: cardService.cards.length,
        itemBuilder: (context, index) {
          final card = cardService.cards[index];
          return ListTile(
            title: Text(card.storeName),
            subtitle: Text('Expires: ${card.expirationDate.toLocal()}'),
            onTap: () {
              // View card details
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCardScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
