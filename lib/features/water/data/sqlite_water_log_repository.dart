import 'package:sqflite/sqflite.dart';

import '../domain/water_log_repository.dart';

/// Water glasses in their own on-device database (`lanh_water.db`), so the
/// meal and profile schemas stay untouched. Version 1 creates the table;
/// later versions must add migrations in `onUpgrade` without dropping rows.
final class SqliteWaterLogRepository implements WaterLogRepository {
  SqliteWaterLogRepository({this.databasePath});

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
    databasePath ?? '${await getDatabasesPath()}/lanh_water.db',
    version: 1,
    onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE water_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount_ml INTEGER NOT NULL CHECK (amount_ml > 0),
          logged_at INTEGER NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX water_logs_logged_at_idx ON water_logs(logged_at)',
      );
    },
  );

  /// [start, end) of the local day of [date], in epoch milliseconds.
  static (int, int) _day(DateTime date) {
    final local = date.toLocal();
    final start = DateTime(local.year, local.month, local.day);
    final end = DateTime(local.year, local.month, local.day + 1);
    return (start.millisecondsSinceEpoch, end.millisecondsSinceEpoch);
  }

  @override
  Future<int> countForDate(DateTime date) async {
    final db = await _open();
    final (start, end) = _day(date);
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS n FROM water_logs WHERE logged_at >= ? AND logged_at < ?',
      [start, end],
    );
    return (rows.single['n'] as int?) ?? 0;
  }

  @override
  Future<Map<DateTime, int>> countsBetween(DateTime from, DateTime to) async {
    final db = await _open();
    final (start, _) = _day(from);
    final (_, end) = _day(to);
    final rows = await db.query(
      'water_logs',
      columns: ['logged_at'],
      where: 'logged_at >= ? AND logged_at < ?',
      whereArgs: [start, end],
    );
    final counts = <DateTime, int>{};
    for (final row in rows) {
      final at = DateTime.fromMillisecondsSinceEpoch(row['logged_at'] as int);
      final day = DateTime(at.year, at.month, at.day);
      counts[day] = (counts[day] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Future<void> add({required DateTime at, required int milliliters}) async {
    if (milliliters <= 0) {
      throw ArgumentError.value(milliliters, 'milliliters', 'Must be > 0.');
    }
    final db = await _open();
    await db.insert('water_logs', {
      'amount_ml': milliliters,
      'logged_at': at.millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> removeLatestForDate(DateTime date) async {
    final db = await _open();
    final (start, end) = _day(date);
    await db.rawDelete(
      '''
      DELETE FROM water_logs WHERE id = (
        SELECT id FROM water_logs
        WHERE logged_at >= ? AND logged_at < ?
        ORDER BY logged_at DESC, id DESC LIMIT 1
      )
      ''',
      [start, end],
    );
  }
}
