import 'package:lanh_app/features/goal/goal.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/profile.dart';

const _energyColumn =
    'daily_energy_kcal INTEGER CHECK (daily_energy_kcal IS NULL OR daily_energy_kcal > 0)';

class SqliteProfileRepository implements ProfileRepository {
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
    final directory = await getDatabasesPath();
    return openDatabase(
      '$directory/lanh_profile.db',
      version: 2,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE profile (
          id INTEGER PRIMARY KEY CHECK (id = 1),
          age_years INTEGER NOT NULL CHECK (age_years > 0),
          height_cm REAL NOT NULL CHECK (height_cm > 0),
          sex TEXT NOT NULL,
          activity_level TEXT NOT NULL,
          goal TEXT NOT NULL,
          $_energyColumn
        )
      '''),
      // Version 2 adds an optional kcal target. Adding a nullable column
      // keeps every existing row unchanged, so no copy or rewrite is needed.
      onUpgrade: (db, from, _) async {
        if (from < 2) {
          await db.execute('ALTER TABLE profile ADD COLUMN $_energyColumn');
        }
      },
    );
  }

  @override
  Future<Profile?> read() async {
    final db = await _open();
    final rows = await db.query('profile', limit: 1);
    if (rows.isEmpty) return null;

    final row = rows.single;
    final goal = Goal.decode(row['goal'] as String);
    if (goal == null) throw const FormatException('Invalid saved goal');
    return Profile(
      ageYears: row['age_years'] as int,
      heightCm: (row['height_cm'] as num).toDouble(),
      sex: ProfileSex.values.byName(row['sex'] as String),
      activityLevel: ActivityLevel.values.byName(
        row['activity_level'] as String,
      ),
      goal: goal,
      dailyEnergyKcal: row['daily_energy_kcal'] as int?,
    );
  }

  @override
  Future<void> save(Profile profile) async {
    final db = await _open();
    await db.insert('profile', {
      'id': 1,
      'age_years': profile.ageYears,
      'height_cm': profile.heightCm,
      'sex': profile.sex.name,
      'activity_level': profile.activityLevel.name,
      'goal': profile.goal.encode(),
      'daily_energy_kcal': profile.dailyEnergyKcal,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
