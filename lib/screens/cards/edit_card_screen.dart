import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_card_wallet/models/loyalty_card.dart';
import 'package:loyalty_card_wallet/providers/card_provider.dart';
import 'package:loyalty_card_wallet/widgets/custom_text_field.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';

class EditCardScreen extends StatefulWidget {
  final LoyaltyCard card;

  const EditCardScreen({
    Key? key,
    required this.card,
  }) : super(key: key);

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _cardNumberController;
  late TextEditingController _barcodeValueController;
  
  late String _barcodeType;
  late Color _cardColor;
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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card.name);
    _descriptionController = TextEditingController(text: widget.card.description ?? '');
    _cardNumberController = TextEditingController(text: widget.card.cardNumber);
    _barcodeValueController = TextEditingController(text: widget.card.barcodeValue);
    _barcodeType = widget.card.barcodeType;
    _cardColor = Color(int.parse(widget.card.cardColor ?? '0xFF4A6FE5'));
    _expiryDate = widget.card.expiryDate;
  }

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

  Future<void> _updateCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedCard = widget.card.copyWith(
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
      );

      await Provider.of<CardProvider>(context, listen: false).updateCard(updatedCard);
      
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating card: $e')),
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
        title: const Text('Edit Card'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expiryDate != null
                            ? DateFormat('MMM dd, yyyy').format(_expiryDate!)
                            : 'No expiry date',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (_expiryDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _expiryDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateCard,
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
                    : const Text('Update Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
