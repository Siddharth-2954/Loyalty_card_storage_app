import 'dart:convert';

class LoyaltyCard {
  final String id;
  final String name;
  final String cardNumber;
  final String? description;
  final DateTime? expiryDate;
  final bool isFavorite;
  final DateTime createdAt;

  LoyaltyCard({
    required this.id,
    required this.name,
    required this.cardNumber,
    this.description,
    this.expiryDate,
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  LoyaltyCard copyWith({
    String? id,
    String? name,
    String? cardNumber,
    String? description,
    DateTime? expiryDate,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return LoyaltyCard(
      id: id ?? this.id,
      name: name ?? this.name,
      cardNumber: cardNumber ?? this.cardNumber,
      description: description ?? this.description,
      expiryDate: expiryDate ?? this.expiryDate,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool isExpiringSoon() {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final difference = expiryDate!.difference(now);
    return difference.inDays <= 30 && !isExpired();
  }

  bool isExpired() {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
}
