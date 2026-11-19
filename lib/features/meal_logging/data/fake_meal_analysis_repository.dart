import '../domain/meal_analysis.dart';
import '../domain/meal_photo_repository.dart';

/// Deterministic analysis used only by explicitly configured dev/test builds.
final class FakeMealAnalysisRepository implements MealAnalysisRepository {
  @override
  Future<MealAnalysis> analyzePhoto(
    MealPhoto photo, {
    required String requestId,
    Future<void>? cancel,
  }) async => _result(requestId);

  @override
  Future<MealAnalysis> analyzeText(
    String description, {
    required String requestId,
    Future<void>? cancel,
  }) async => _result(requestId);

  MealAnalysis _result(String requestId) => MealAnalysis(
    requestId: requestId,
    items: [
      MealAnalysisItem(
        id: 'fake-rice',
        name: 'Cơm trắng',
        portion: MealPortion(amount: 180, unit: MealPortionUnit.gram),
        nutrition: MealNutrition(
          caloriesKcal: 234,
          proteinGrams: 4.3,
          carbohydrateGrams: 51.5,
          fatGrams: 0.5,
        ),
      ),
      MealAnalysisItem(
        id: 'fake-salmon',
        name: 'Cá hồi áp chảo',
        portion: MealPortion(amount: 120, unit: MealPortionUnit.gram),
        nutrition: MealNutrition(
          caloriesKcal: 250,
          proteinGrams: 26,
          carbohydrateGrams: 0,
          fatGrams: 16,
        ),
      ),
    ],
  );
}
