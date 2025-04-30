import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:loyalty_card_wallet/models/loyalty_card.dart';
import 'package:loyalty_card_wallet/providers/card_provider.dart';
import 'package:loyalty_card_wallet/screens/cards/edit_card_screen.dart';
import 'package:intl/intl.dart';

class CardDetailScreen extends StatefulWidget {
  final String cardId;

  const CardDetailScreen({
    Key? key,
    required this.cardId,
  }) : super(key: key);

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  bool _isFullScreen = false;

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _showDeleteConfirmation(LoyaltyCard card) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Card'),
          content: Text('Are you sure you want to delete ${card.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Provider.of<CardProvider>(context, listen: false)
                    .deleteCard(card.id);
                if (!mounted) return;
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CardProvider>(
      builder: (context, cardProvider, _) {
        final card = cardProvider.cards.firstWhere(
          (card) => card.id == widget.cardId,
          orElse: () => throw Exception('Card not found'),
        );
        
        if (_isFullScreen) {
          return GestureDetector(
            onTap: _toggleFullScreen,
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: _buildBarcode(card),
              ),
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text(card.name),
            actions: [
              IconButton(
                icon: Icon(
                  card.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                onPressed: () {
                  cardProvider.toggleFavorite(card.id);
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditCardScreen(card: card),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(card);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Color(int.parse(card.cardColor ?? '0xFF4A6FE5')),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        card.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (card.description != null)
                        Text(
                          card.description!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 16),
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Card Number',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    card.cardNumber,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 18),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: card.cardNumber));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Card number copied to clipboard'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBarcode(card),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _toggleFullScreen,
                        icon: const Icon(Icons.fullscreen),
                        label: const Text('Full Screen'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Card Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        context,
                        'Barcode Type',
                        card.barcodeType.replaceAll('_', ' '),
                      ),
                      if (card.expiryDate != null)
                        _buildDetailItem(
                          context,
                          'Expiry Date',
                          DateFormat('MMM dd, yyyy').format(card.expiryDate!),
                          card.isExpiringSoon() ? Colors.orange : null,
                          card.isExpired() ? 'Expired' : null,
                        ),
                      _buildDetailItem(
                        context,
                        'Added On',
                        DateFormat('MMM dd, yyyy').format(card.createdAt),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarcode(LoyaltyCard card) {
    BarcodeType barcodeType;
    
    switch (card.barcodeType) {
      case 'QR_CODE':
        barcodeType = BarcodeType.qrCode;
        break;
      case 'CODE_128':
        barcodeType = BarcodeType.code128;
        break;
      case 'CODE_39':
        barcodeType = BarcodeType.code39;
        break;
      case 'EAN_13':
        barcodeType = BarcodeType.ean13;
        break;
      case 'EAN_8':
        barcodeType = BarcodeType.ean8;
        break;
      case 'UPC_A':
        barcodeType = BarcodeType.upcA;
        break;
      case 'UPC_E':
        barcodeType = BarcodeType.upcE;
        break;
      default:
        barcodeType = BarcodeType.code128;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          BarcodeWidget(
            barcode: Barcode.fromType(barcodeType),
            data: card.barcodeValue,
            width: double.infinity,
            height: 120,
            drawText: barcodeType != BarcodeType.qrCode,
          ),
          if (barcodeType == BarcodeType.qrCode)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                card.barcodeValue,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value, [
    Color? valueColor,
    String? badge,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
              if (badge != null)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
