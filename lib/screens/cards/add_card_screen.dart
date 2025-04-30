import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:loyalty_card_wallet/models/loyalty_card.dart';
import 'package:loyalty_card_wallet/providers/card_provider.dart';
import 'package:loyalty_card_wallet/screens/cards/scan_card_screen.dart';
import 'package:loyalty_card_wallet/widgets/custom_text_field.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _barcodeValueController = TextEditingController();
  
  String _barcodeType = 'CODE_128';
  Color _cardColor = Colors.blue;
  DateTime? _expiryDate;
  bool _isLoading = false;

  final List<String> _barcodeTypes = [
    'CODE_128',
    'CODE_39',
    'EAN_13',
    'EAN_8',
    'UPC_A',
    'UPC_E',
    'QR_CODE',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cardNumberController.dispose();
    _barcodeValueController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _cardColor,
              onColorChanged: (color) {
                setState(() {
                  _cardColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _scanCard() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const ScanCardScreen()),
    );
    
    if (result != null) {
      setState(() {
        if (result.containsKey('name') && result['name']!.isNotEmpty) {
          _nameController.text = result['name']!;
        }
        
        if (result.containsKey('cardNumber') && result['cardNumber']!.isNotEmpty) {
          _cardNumberController.text = result['cardNumber']!;
        }
        
        if (result.containsKey('barcodeValue') && result['barcodeValue']!.isNotEmpty) {
          _barcodeValueController.text = result['barcodeValue']!;
        }
        
        if (result.containsKey('barcodeType') && result['barcodeType']!.isNotEmpty) {
          _barcodeType = result['barcodeType']!;
        }
      });
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final card = LoyaltyCard(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        cardNumber: _cardNumberController.text.trim(),
        barcodeType: _barcodeType,
        barcodeValue: _barcodeValueController.text.trim().isNotEmpty
            ? _barcodeValueController.text.trim()
            : _cardNumberController.text.trim(),
        cardColor: _cardColor.value.toString(),
        expiryDate: _expiryDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
      );

      await Provider.of<CardProvider>(context, listen: false).addCard(card);
      
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving card: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Loyalty Card'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _scanCard,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scan Card'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                labelText: 'Card Name',
                prefixIcon: Icons.credit_card,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a card name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description (Optional)',
                prefixIcon: Icons.description,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cardNumberController,
                labelText: 'Card Number',
                prefixIcon: Icons.numbers,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _barcodeType,
                decoration: InputDecoration(
                  labelText: 'Barcode Type',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _barcodeTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type.replaceAll('_', ' ')),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _barcodeType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _barcodeValueController,
                labelText: 'Barcode Value (Optional)',
                prefixIcon: Icons.qr_code_scanner,
                helperText: 'Leave empty to use card number',
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _showColorPicker,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Card Color',
                    prefixIcon: const Icon(Icons.color_lens),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '#${_cardColor.value.toRadixString(16).substring(2).toUpperCase()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectExpiryDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Expiry Date (Optional)',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _expiryDate != null
                        ? DateFormat('MMM dd, yyyy').format(_expiryDate!)
                        : 'No expiry date',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
