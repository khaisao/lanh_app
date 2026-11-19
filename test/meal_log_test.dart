import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_log.dart';

void main() {
  test('MealLog.fromAnalysis scales every saved value', () {
    final analysis = MealAnalysis(
      requestId: 'request-1',
      items: [
        MealAnalysisItem(
          id: 'rice',
          name: 'Rice',
          portion: MealPortion(amount: 200, unit: MealPortionUnit.gram),
          nutrition: MealNutrition(
            caloriesKcal: 300,
            proteinGrams: 6,
            carbohydrateGrams: 65,
            fatGrams: 1,
          ),
        ),
        MealAnalysisItem(
          id: 'soup',
          name: 'Soup',
          portion: null,
          nutrition: MealNutrition(),
        ),
      ],
    );

    final log = MealLog.fromAnalysis(
      id: 7,
      source: MealLogSource.voice,
      analysis: analysis,
      portionScale: 0.5,
      createdAt: DateTime.utc(2026, 11, 18, 12),
    );

    expect(log.totalCalories, 150);
    expect(log.totalProtein, 3);
    expect(
      log.items.singleWhere((item) => item.id == 'rice').portion!.amount,
      100,
    );
    expect(
      log.items.singleWhere((item) => item.id == 'soup').nutrition.caloriesKcal,
      isNull,
    );
    expect(log.createdAt.isUtc, isTrue);
  });
}
