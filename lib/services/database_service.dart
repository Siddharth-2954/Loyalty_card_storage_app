import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:loyalty_card_wallet/models/loyalty_card.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'loyalty_cards.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE loyalty_cards(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        cardNumber TEXT NOT NULL,
        barcodeType TEXT NOT NULL,
        barcodeValue TEXT NOT NULL,
        logoUrl TEXT,
        cardColor TEXT,
        expiryDate INTEGER,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        isFavorite INTEGER NOT NULL,
        additionalInfo TEXT,
        syncStatus TEXT DEFAULT 'pending'
      )
    ''');
  }

  // CRUD operations for loyalty cards
  Future<List<LoyaltyCard>> getCards() async {
    final db = await database;
    final maps = await db.query('loyalty_cards');
    return List.generate(maps.length, (i) => LoyaltyCard.fromMap(maps[i]));
  }

  Future<LoyaltyCard?> getCard(String id) async {
    final db = await database;
    final maps = await db.query(
      'loyalty_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return LoyaltyCard.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertCard(LoyaltyCard card) async {
    final db = await database;
    await db.insert(
      'loyalty_cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCard(LoyaltyCard card) async {
    final db = await database;
    await db.update(
      'loyalty_cards',
      {...card.toMap(), 'syncStatus': 'pending'},
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(String id) async {
    final db = await database;
    await db.delete(
      'loyalty_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<LoyaltyCard>> getExpiringCards() async {
    final db = await database;
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));
    
    final maps = await db.query(
      'loyalty_cards',
      where: 'expiryDate IS NOT NULL AND expiryDate > ? AND expiryDate <= ?',
      whereArgs: [now.millisecondsSinceEpoch, thirtyDaysLater.millisecondsSinceEpoch],
    );
    
    return List.generate(maps.length, (i) => LoyaltyCard.fromMap(maps[i]));
  }

  Future<List<LoyaltyCard>> getPendingSyncCards() async {
    final db = await database;
    final maps = await db.query(
      'loyalty_cards',
      where: 'syncStatus = ?',
      whereArgs: ['pending'],
    );
    return List.generate(maps.length, (i) => LoyaltyCard.fromMap(maps[i]));
  }

  Future<void> markCardSynced(String id) async {
    final db = await database;
    await db.update(
      'loyalty_cards',
      {'syncStatus': 'synced'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
