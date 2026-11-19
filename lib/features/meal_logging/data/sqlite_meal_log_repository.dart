import 'dart:io';
import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import '../domain/meal_analysis.dart';
import '../domain/meal_log.dart';
import '../domain/meal_log_repository.dart';
import '../domain/meal_photo_repository.dart';

final class SqliteMealLogRepository implements MealLogRepository {
  SqliteMealLogRepository({this.databasePath});

  final String? databasePath;
  Future<Database>? _database;

  Future<Database> _open() async {
    try {
      return await (_database ??= _openDatabase());
    } catch (_) {
      _database = null;
      rethrow;
    }
  }

  Future<Database> _openDatabase() async {
    final path =
        databasePath ??
        '${await getDatabasesPath()}${Platform.pathSeparator}lanh_meals.db';
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE meals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            request_id TEXT NOT NULL,
            source TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            portion_scale REAL NOT NULL,
            image_path TEXT,
            total_calories REAL,
            total_protein REAL,
            total_carbohydrate REAL,
            total_fat REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE meal_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            meal_id INTEGER NOT NULL,
            item_key TEXT NOT NULL,
            name TEXT NOT NULL,
            portion_amount REAL,
            portion_unit TEXT,
            calories REAL,
            protein REAL,
            carbohydrate REAL,
            fat REAL,
            FOREIGN KEY (meal_id) REFERENCES meals(id) ON DELETE CASCADE
          )
        ''');
        await db.execute(
          'CREATE INDEX meals_created_at_idx ON meals(created_at)',
        );
      },
    );
  }

  @override
  Future<MealLog> save({
    required MealAnalysis analysis,
    required MealLogSource source,
    required double portionScale,
    MealPhoto? photo,
    DateTime? createdAt,
  }) async {
    final savedAt = (createdAt ?? DateTime.now()).toUtc();
    final imagePath = await _storePhoto(
      photo?.bytes,
      requestId: analysis.requestId,
      createdAt: savedAt,
    );
    final log = MealLog.fromAnalysis(
      id: 0,
      source: source,
      analysis: analysis,
      portionScale: portionScale,
      createdAt: savedAt,
      imagePath: imagePath,
    );
    final db = await _open();
    final id = await db.transaction<int>((txn) async {
      final mealId = await txn.insert('meals', {
        'request_id': log.requestId,
        'source': log.source.name,
        'created_at': log.createdAt.millisecondsSinceEpoch,
        'portion_scale': log.portionScale,
        'image_path': log.imagePath,
        'total_calories': log.totalCalories,
        'total_protein': log.totalProtein,
        'total_carbohydrate': log.totalCarbohydrate,
        'total_fat': log.totalFat,
      });
      final batch = txn.batch();
      for (final item in log.items) {
        batch.insert('meal_items', {
          'meal_id': mealId,
          'item_key': item.id,
          'name': item.name,
          'portion_amount': item.portion?.amount,
          'portion_unit': item.portion?.unit.name,
          'calories': item.nutrition.caloriesKcal,
          'protein': item.nutrition.proteinGrams,
          'carbohydrate': item.nutrition.carbohydrateGrams,
          'fat': item.nutrition.fatGrams,
        });
      }
      await batch.commit(noResult: true);
      return mealId;
    });
    return MealLog(
      id: id,
      requestId: log.requestId,
      source: log.source,
      createdAt: log.createdAt,
      portionScale: log.portionScale,
      imagePath: log.imagePath,
      totalCalories: log.totalCalories,
      totalProtein: log.totalProtein,
      totalCarbohydrate: log.totalCarbohydrate,
      totalFat: log.totalFat,
      items: log.items,
    );
  }

  @override
  Future<List<MealLog>> readForDate(DateTime date) async {
    final localStart = DateTime(date.year, date.month, date.day);
    final localEnd = localStart.add(const Duration(days: 1));
    final db = await _open();
    final meals = await db.query(
      'meals',
      where: 'created_at >= ? AND created_at < ?',
      whereArgs: [
        localStart.toUtc().millisecondsSinceEpoch,
        localEnd.toUtc().millisecondsSinceEpoch,
      ],
      orderBy: 'created_at DESC, id DESC',
    );
    if (meals.isEmpty) return const [];
    final ids = meals.map((row) => row['id'] as int).toList();
    final items = await db.query(
      'meal_items',
      where: 'meal_id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
      orderBy: 'id ASC',
    );
    final byMeal = <int, List<MealLogItem>>{};
    for (final row in items) {
      final mealId = row['meal_id'] as int;
      (byMeal[mealId] ??= []).add(_itemFromRow(row));
    }
    return meals.map((row) {
      final mealId = row['id'] as int;
      final mealItems = byMeal[mealId];
      if (mealItems == null || mealItems.isEmpty) {
        throw FormatException('Meal $mealId has no items');
      }
      return MealLog(
        id: mealId,
        requestId: row['request_id'] as String,
        source: MealLogSource.values.byName(row['source'] as String),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row['created_at'] as int,
          isUtc: true,
        ),
        portionScale: (row['portion_scale'] as num).toDouble(),
        imagePath: row['image_path'] as String?,
        totalCalories: (row['total_calories'] as num?)?.toDouble(),
        totalProtein: (row['total_protein'] as num?)?.toDouble(),
        totalCarbohydrate: (row['total_carbohydrate'] as num?)?.toDouble(),
        totalFat: (row['total_fat'] as num?)?.toDouble(),
        items: mealItems,
      );
    }).toList();
  }

  Future<String?> _storePhoto(
    Uint8List? bytes, {
    required String requestId,
    required DateTime createdAt,
  }) async {
    if (bytes == null || bytes.isEmpty) return null;
    try {
      final root = databasePath == ':memory:'
          ? null
          : databasePath == null
          ? await getDatabasesPath()
          : File(databasePath!).parent.path;
      if (root == null) return null;
      final directory = Directory(
        '$root${Platform.pathSeparator}lanh_meal_photos',
      );
      await directory.create(recursive: true);
      final path =
          '${directory.path}${Platform.pathSeparator}${requestId}_${createdAt.millisecondsSinceEpoch}.jpg';
      await File(path).writeAsBytes(bytes, flush: true);
      return path;
    } catch (_) {
      return null;
    }
  }

  MealLogItem _itemFromRow(Map<String, Object?> row) {
    final amount = (row['portion_amount'] as num?)?.toDouble();
    final unitName = row['portion_unit'] as String?;
    final portion = amount == null || unitName == null
        ? null
        : MealPortion(
            amount: amount,
            unit: MealPortionUnit.values.byName(unitName),
          );
    return MealLogItem(
      id: row['item_key'] as String,
      name: row['name'] as String,
      portion: portion,
      nutrition: MealNutrition(
        caloriesKcal: (row['calories'] as num?)?.toDouble(),
        proteinGrams: (row['protein'] as num?)?.toDouble(),
        carbohydrateGrams: (row['carbohydrate'] as num?)?.toDouble(),
        fatGrams: (row['fat'] as num?)?.toDouble(),
      ),
    );
  }
}
