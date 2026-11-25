import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/weight/data/sqlite_weight_repository.dart';
import 'package:lanh_app/features/weight/domain/weight_entry.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('weight values', () {
    test('round to 0,1 kg and stay inside 20–300 kg', () {
      expect(normalizeWeightKg(52.84), 52.8);
      expect(normalizeWeightKg(52.85), 52.9);
      expect(normalizeWeightKg(20), 20);
      expect(normalizeWeightKg(300), 300);
      expect(normalizeWeightKg(19.94), isNull);
      expect(normalizeWeightKg(300.06), isNull);
      expect(normalizeWeightKg(0), isNull);
      expect(normalizeWeightKg(-50), isNull);
      expect(normalizeWeightKg(double.nan), isNull);
      expect(normalizeWeightKg(double.infinity), isNull);
    });

    test('an entry keeps only its local day and rejects bad weights', () {
      final entry = WeightEntry(day: DateTime(2026, 11, 24, 21, 30), kg: 52.83);
      expect(entry.day, DateTime(2026, 11, 24));
      expect(entry.kg, 52.8);
      expect(
        () => WeightEntry(day: DateTime(2026), kg: 10),
        throwsArgumentError,
      );
    });

    test('latest on or before a day ignores later weigh-ins', () {
      final entries = [
        WeightEntry(day: DateTime(2026, 11, 18), kg: 53),
        WeightEntry(day: DateTime(2026, 11, 23), kg: 52.8),
        WeightEntry(day: DateTime(2026, 11, 21), kg: 52.9),
      ];
      expect(latestWeightOnOrBefore(entries, DateTime(2026, 11, 22))?.kg, 52.9);
      expect(latestWeightOnOrBefore(entries, DateTime(2026, 11, 24))?.kg, 52.8);
      expect(latestWeightOnOrBefore(entries, DateTime(2026, 11, 17)), isNull);
    });
  });

  group('SqliteWeightRepository', () {
    late Directory dir;
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });
    setUp(() async => dir = await Directory.systemTemp.createTemp('lanh_w'));
    tearDown(() => dir.delete(recursive: true));

    test(
      'one weigh-in per day: saving again replaces, delete removes',
      () async {
        final repository = SqliteWeightRepository(
          databasePath: '${dir.path}/weight.db',
        );
        await repository.save(
          WeightEntry(day: DateTime(2026, 11, 20, 7), kg: 53),
        );
        await repository.save(
          WeightEntry(day: DateTime(2026, 11, 23), kg: 52.9),
        );
        await repository.save(
          WeightEntry(day: DateTime(2026, 11, 23, 22), kg: 52.8),
        );
        final all = await repository.readBetween(
          DateTime(2026, 11, 1),
          DateTime(2026, 11, 30),
        );
        expect(all.map((e) => (e.day.day, e.kg)), [(23, 52.8), (20, 53.0)]);
        expect(
          await repository.readBetween(
            DateTime(2026, 11, 21),
            DateTime(2026, 11, 22),
          ),
          isEmpty,
        );
        await repository.delete(DateTime(2026, 11, 23, 9));
        expect(
          (await repository.readBetween(
            DateTime(2026, 11, 1),
            DateTime(2026, 12),
          )).single.day,
          DateTime(2026, 11, 20),
        );
      },
    );
  });
}
