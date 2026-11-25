import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_photo_repository.dart';

final class TestMealLogRepository implements MealLogRepository {
  final List<MealLog> saved = [];
  bool failSave = false;
  bool failDelete = false;

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
  Future<List<MealLog>> readForDate(DateTime date) => readBetween(date, date);

  @override
  Future<void> delete(int id) async {
    if (failDelete) throw StateError('delete failed');
    saved.removeWhere((meal) => meal.id == id);
  }

  @override
  Future<List<MealLog>> readBetween(DateTime from, DateTime to) async {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day + 1);
    return saved.where((meal) {
      final local = meal.createdAt.toLocal();
      return !local.isBefore(start) && local.isBefore(end);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
