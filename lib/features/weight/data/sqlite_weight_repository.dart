import 'package:sqflite/sqflite.dart';

import '../domain/weight_entry.dart';

/// Weigh-ins in their own on-device database (`lanh_weight.db`), one row per
/// local day. Version 1 creates the table; later versions must migrate in
/// `onUpgrade` without dropping rows.
final class SqliteWeightRepository implements WeightRepository {
  SqliteWeightRepository({this.databasePath});

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

  Future<Database> _openDatabase() async => openDatabase(
    databasePath ?? '${await getDatabasesPath()}/lanh_weight.db',
    version: 1,
    onCreate: (db, _) => db.execute('''
      CREATE TABLE weight_logs (
        day TEXT PRIMARY KEY,
        kg REAL NOT NULL CHECK (kg >= $minWeightKg AND kg <= $maxWeightKg),
        updated_at INTEGER NOT NULL
      )
    '''),
  );

  /// `yyyy-mm-dd`, which sorts and compares in calendar order.
  static String _key(DateTime date) {
    final day = weightDay(date);
    String two(int value) => value.toString().padLeft(2, '0');
    return '${day.year.toString().padLeft(4, '0')}-${two(day.month)}-${two(day.day)}';
  }

  @override
  Future<List<WeightEntry>> readBetween(DateTime from, DateTime to) async {
    final db = await _open();
    final rows = await db.query(
      'weight_logs',
      where: 'day >= ? AND day <= ?',
      whereArgs: [_key(from), _key(to)],
      orderBy: 'day DESC',
    );
    return rows
        .map(
          (row) => WeightEntry(
            day: DateTime.parse(row['day'] as String),
            kg: (row['kg'] as num).toDouble(),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> save(WeightEntry entry) async {
    final db = await _open();
    await db.insert('weight_logs', {
      'day': _key(entry.day),
      'kg': entry.kg,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> delete(DateTime day) async {
    final db = await _open();
    await db.delete('weight_logs', where: 'day = ?', whereArgs: [_key(day)]);
  }
}
