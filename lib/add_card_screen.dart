import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_service.dart';
import 'loyalty_card.dart';

class AddCardScreen extends StatelessWidget {
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expirationDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Loyalty Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: storeNameController,
              decoration: InputDecoration(labelText: 'Store Name'),
            ),
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(labelText: 'Card Number'),
            ),
            TextField(
              controller: expirationDateController,
              decoration: InputDecoration(labelText: 'Expiration Date'),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save the card to local storage
                final newCard = LoyaltyCard(
                  storeName: storeNameController.text,
                  cardNumber: cardNumberController.text,
                  barcode: "barcode_example",  // For now, just an example.
                  expirationDate: DateTime.parse(expirationDateController.text),
                );

                Provider.of<CardService>(context, listen: false).addCard(newCard);

                // Navigate back to the home screen
                Navigator.pop(context);
              },
              child: Text('Add Card'),
            ),
          ],
        ),
      ),
    );
  }
}
