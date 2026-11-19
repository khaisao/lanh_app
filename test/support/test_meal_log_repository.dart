import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_photo_repository.dart';

final class TestMealLogRepository implements MealLogRepository {
  final List<MealLog> saved = [];
  bool failSave = false;

  @override
  Future<MealLog> save({
    required MealAnalysis analysis,
    required MealLogSource source,
    required double portionScale,
    MealPhoto? photo,
    DateTime? createdAt,
  }) async {
    if (failSave) throw StateError('save failed');
    final log = MealLog.fromAnalysis(
      id: saved.length + 1,
      source: source,
      analysis: analysis,
      portionScale: portionScale,
      createdAt: (createdAt ?? DateTime.now()).toUtc(),
      imagePath: photo == null ? null : '/tmp/meal.jpg',
    );
    saved.add(log);
    return log;
  }

  @override
  Future<List<MealLog>> readForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return saved.where((meal) {
      final local = meal.createdAt.toLocal();
      return !local.isBefore(start) && local.isBefore(end);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
