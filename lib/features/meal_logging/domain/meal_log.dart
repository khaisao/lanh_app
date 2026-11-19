import 'meal_analysis.dart';

enum MealLogSource { photo, voice }

final class MealLogItem {
  const MealLogItem({
    required this.id,
    required this.name,
    required this.portion,
    required this.nutrition,
  });

  final String id;
  final String name;
  final MealPortion? portion;
  final MealNutrition nutrition;
}

final class MealLog {
  MealLog({
    required this.id,
    required this.requestId,
    required this.source,
    required this.createdAt,
    required this.portionScale,
    required List<MealLogItem> items,
    this.imagePath,
    this.totalCalories,
    this.totalProtein,
    this.totalCarbohydrate,
    this.totalFat,
  }) : items = List.unmodifiable(items) {
    if (items.isEmpty) throw ArgumentError.value(items, 'items', 'Empty.');
    if (!createdAt.isUtc) {
      throw ArgumentError.value(createdAt, 'createdAt', 'Must be UTC.');
    }
    if (!portionScale.isFinite || portionScale <= 0) {
      throw ArgumentError.value(portionScale, 'portionScale');
    }
  }

  final int id;
  final String requestId;
  final MealLogSource source;
  final DateTime createdAt;
  final double portionScale;
  final List<MealLogItem> items;
  final String? imagePath;
  final double? totalCalories;
  final double? totalProtein;
  final double? totalCarbohydrate;
  final double? totalFat;

  List<String> get names => items.map((item) => item.name).toList(growable: false);

  factory MealLog.fromAnalysis({
    required int id,
    required MealLogSource source,
    required MealAnalysis analysis,
    required double portionScale,
    required DateTime createdAt,
    String? imagePath,
  }) {
    return MealLog(
      id: id,
      requestId: analysis.requestId,
      source: source,
      createdAt: createdAt.toUtc(),
      portionScale: portionScale,
      imagePath: imagePath,
      totalCalories: analysis.totalCalories(portionScale),
      totalProtein: analysis.totalProtein(portionScale),
      totalCarbohydrate: analysis.totalCarbohydrate(portionScale),
      totalFat: analysis.totalFat(portionScale),
      items: analysis.items
          .map(
            (item) => MealLogItem(
              id: item.id,
              name: item.name,
              portion: item.portion == null
                  ? null
                  : MealPortion(
                      amount: item.portion!.amount * portionScale,
                      unit: item.portion!.unit,
                    ),
              nutrition: MealNutrition(
                caloriesKcal: item.nutrition.caloriesKcal == null
                    ? null
                    : item.nutrition.caloriesKcal! * portionScale,
                proteinGrams: item.nutrition.proteinGrams == null
                    ? null
                    : item.nutrition.proteinGrams! * portionScale,
                carbohydrateGrams: item.nutrition.carbohydrateGrams == null
                    ? null
                    : item.nutrition.carbohydrateGrams! * portionScale,
                fatGrams: item.nutrition.fatGrams == null
                    ? null
                    : item.nutrition.fatGrams! * portionScale,
              ),
            ),
          )
          .toList(),
    );
  }
}
