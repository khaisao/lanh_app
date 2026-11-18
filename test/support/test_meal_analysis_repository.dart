import 'dart:async';

import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_photo_repository.dart';

/// Holds each analysis call open until the test completes or fails it.
class TestMealAnalysisRepository implements MealAnalysisRepository {
  final requests = <String>[];
  final cancelled = <String>[];
  final descriptions = <String>[];
  Completer<MealAnalysis>? _pending;

  bool get hasPending => _pending != null && !_pending!.isCompleted;

  @override
  Future<MealAnalysis> analyzePhoto(
    MealPhoto photo, {
    required String requestId,
    Future<void>? cancel,
  }) {
    requests.add(requestId);
    final pending = _pending = Completer<MealAnalysis>();
    unawaited(cancel?.then((_) => cancelled.add(requestId)));
    return pending.future;
  }

  @override
  Future<MealAnalysis> analyzeText(
    String description, {
    required String requestId,
    Future<void>? cancel,
  }) {
    descriptions.add(description);
    requests.add(requestId);
    final pending = _pending = Completer<MealAnalysis>();
    unawaited(cancel?.then((_) => cancelled.add(requestId)));
    return pending.future;
  }

  void succeed([MealAnalysis? analysis]) =>
      _pending!.complete(analysis ?? sampleMealAnalysis());

  void fail([MealAnalysisFailureKind kind = MealAnalysisFailureKind.noFood]) =>
      _pending!.completeError(MealAnalysisFailure(kind));
}

/// Test fixture only: never injected into the app as user data.
MealAnalysis sampleMealAnalysis() => MealAnalysis(
  requestId: 'request-1',
  items: [
    MealAnalysisItem(
      id: 'com-trang',
      name: 'Cơm trắng',
      portion: MealPortion(amount: 180, unit: MealPortionUnit.gram),
      nutrition: MealNutrition(
        caloriesKcal: 200,
        proteinGrams: 4,
        carbohydrateGrams: 44,
        fatGrams: 0.4,
      ),
    ),
    MealAnalysisItem(
      id: 'ga-rau-xao',
      name: 'Gà và rau xào',
      portion: MealPortion(amount: 240, unit: MealPortionUnit.gram),
      nutrition: MealNutrition(
        caloriesKcal: 380,
        proteinGrams: 30,
        carbohydrateGrams: 12,
        fatGrams: 22,
      ),
    ),
  ],
);
