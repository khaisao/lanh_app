import 'meal_analysis.dart';
import 'meal_log.dart';
import 'meal_photo_repository.dart';

abstract interface class MealLogRepository {
  Future<MealLog> save({
    required MealAnalysis analysis,
    required MealLogSource source,
    required double portionScale,
    MealPhoto? photo,
    DateTime? createdAt,
  });

  /// Meals saved on the local day of [date], newest first.
  Future<List<MealLog>> readForDate(DateTime date);

  /// Meals saved from local day [from] to local day [to], both included,
  /// newest first.
  Future<List<MealLog>> readBetween(DateTime from, DateTime to);

  /// Removes the meal with [id] and its stored photo. Missing ids are ignored.
  Future<void> delete(int id);
}
