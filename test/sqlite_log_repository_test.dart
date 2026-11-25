import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/meal_logging/data/sqlite_meal_log_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log.dart';
import 'package:lanh_app/features/water/data/sqlite_water_log_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory dir;
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  // A file per test: sqflite shares one database per path, even ':memory:'.
  setUp(() async => dir = await Directory.systemTemp.createTemp('lanh_db'));
  tearDown(() async {
    // Windows cannot delete a database file while the FFI connection is open.
    // Reopening the same path resolves sqflite's shared connection.
    for (final name in ['water.db', 'meals.db']) {
      final path = '${dir.path}/$name';
      if (await File(path).exists()) {
        final database = await databaseFactory.openDatabase(path);
        await database.close();
      }
    }
    await dir.delete(recursive: true);
  });

  test('water counts stay within the local calendar day', () async {
    final repository = SqliteWaterLogRepository(
      databasePath: '${dir.path}/water.db',
    );
    final before = DateTime(2026, 11, 19, 23, 59);
    final start = DateTime(2026, 11, 20);
    final after = DateTime(2026, 11, 21);
    await repository.add(at: before, milliliters: 250);
    await repository.add(at: start, milliliters: 250);
    expect(await repository.countForDate(start), 1);
    expect(await repository.countForDate(after), 0);
    // Removing today's latest glass never touches yesterday's.
    await repository.removeLatestForDate(start);
    await repository.removeLatestForDate(start);
    expect(await repository.countForDate(start), 0);
    expect(await repository.countForDate(before), 1);
  });

  test('meals count stays within the local calendar day', () async {
    final repository = SqliteMealLogRepository(
      databasePath: '${dir.path}/meals.db',
    );
    final analysis = MealAnalysis(
      requestId: 'request',
      items: [
        MealAnalysisItem(
          id: 'rice',
          name: 'Rice',
          portion: null,
          nutrition: MealNutrition(caloriesKcal: 200),
        ),
      ],
    );
    final before = DateTime(2026, 11, 19, 23, 59);
    final start = DateTime(2026, 11, 20);
    final after = DateTime(2026, 11, 21);
    await repository.save(
      analysis: analysis,
      source: MealLogSource.voice,
      portionScale: 1,
      createdAt: before,
    );
    await repository.save(
      analysis: analysis,
      source: MealLogSource.voice,
      portionScale: 1,
      createdAt: start,
    );
    expect((await repository.readForDate(start)), hasLength(1));
    expect(await repository.readForDate(after), isEmpty);
  });
}
