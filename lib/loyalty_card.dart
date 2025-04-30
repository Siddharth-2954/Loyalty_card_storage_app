import 'package:hive/hive.dart';

part 'loyalty_card.g.dart';

@HiveType(typeId: 0)
class LoyaltyCard {
  @HiveField(0)
  String storeName;
  
  @HiveField(1)
  String cardNumber;

  @HiveField(2)
  String barcode;

  @HiveField(3)
  DateTime expirationDate;

  LoyaltyCard({
    required this.storeName,
    required this.cardNumber,
    required this.barcode,
    required this.expirationDate,
  });
}