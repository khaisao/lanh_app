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

  Future<List<MealLog>> readForDate(DateTime date);
}
