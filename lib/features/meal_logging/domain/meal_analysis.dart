import 'meal_photo_repository.dart';

/// Units the meal analysis service may report for a component portion.
enum MealPortionUnit { gram, milliliter, serving, piece }

/// A positive amount in the unit reported for that one component.
final class MealPortion {
  MealPortion({required this.amount, required this.unit}) {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Must be finite and > 0.');
    }
  }

  final double amount;
  final MealPortionUnit unit;
}

/// Estimated nutrients for one component. `null` means unknown, never zero.
final class MealNutrition {
  MealNutrition({
    this.caloriesKcal,
    this.proteinGrams,
    this.carbohydrateGrams,
    this.fatGrams,
  }) {
    for (final value in [
      caloriesKcal,
      proteinGrams,
      carbohydrateGrams,
      fatGrams,
    ]) {
      if (value != null && (!value.isFinite || value < 0)) {
        throw ArgumentError.value(
          value,
          'nutrition',
          'Must be finite and >= 0.',
        );
      }
    }
  }

  final double? caloriesKcal;
  final double? proteinGrams;
  final double? carbohydrateGrams;
  final double? fatGrams;
}

final class MealAnalysisItem {
  MealAnalysisItem({
    required this.id,
    required this.name,
    required this.portion,
    required this.nutrition,
  }) {
    if (name.trim().isEmpty) throw ArgumentError.value(name, 'name');
  }

  final String id;
  final String name;
  final MealPortion? portion;
  final MealNutrition nutrition;
}

/// An unsaved AI estimate of a photographed or described meal.
///
/// Totals add values at full precision; callers round only for display. A
/// whole-meal [scale] multiplies every component by the same factor.
final class MealAnalysis {
  MealAnalysis({required this.requestId, required List<MealAnalysisItem> items})
    : items = List.unmodifiable(items) {
    if (items.isEmpty) throw ArgumentError.value(items, 'items', 'Empty.');
  }

  final String requestId;
  final List<MealAnalysisItem> items;

  double? totalCalories([double scale = 1]) =>
      _sum((item) => item.nutrition.caloriesKcal, scale);
  double? totalProtein([double scale = 1]) =>
      _sum((item) => item.nutrition.proteinGrams, scale);
  double? totalCarbohydrate([double scale = 1]) =>
      _sum((item) => item.nutrition.carbohydrateGrams, scale);
  double? totalFat([double scale = 1]) =>
      _sum((item) => item.nutrition.fatGrams, scale);

  /// Components whose calories the service could not estimate.
  int get itemsMissingCalories =>
      items.where((item) => item.nutrition.caloriesKcal == null).length;

  double? _sum(double? Function(MealAnalysisItem) value, double scale) {
    final known = items.map(value).whereType<double>();
    if (known.isEmpty) return null;
    return known.fold<double>(0, (sum, item) => sum + item) * scale;
  }
}

enum MealAnalysisFailureKind {
  /// The photo or description contains no food the service could identify.
  noFood,

  /// The service rejected the photo bytes or format, or the request input.
  invalidPhoto,

  /// The device could not reach the service.
  network,

  /// The service or its model is busy, down or too slow.
  unavailable,

  /// This build has no analysis service configured.
  notConfigured,

  /// The service answered with something the app cannot use.
  unexpected,
}

final class MealAnalysisFailure implements Exception {
  const MealAnalysisFailure(this.kind);

  final MealAnalysisFailureKind kind;

  @override
  String toString() => 'MealAnalysisFailure(${kind.name})';
}

abstract interface class MealAnalysisRepository {
  /// Sends [photo] for estimation. Retrying with the same [requestId] refers
  /// to the same draft. Completing [cancel] abandons the request.
  ///
  /// Throws [MealAnalysisFailure] on every expected failure.
  Future<MealAnalysis> analyzePhoto(
    MealPhoto photo, {
    required String requestId,
    Future<void>? cancel,
  });

  /// Sends a meal [description] the user confirmed, for example a voice
  /// transcript. Same identity, cancellation and failure rules as photos.
  Future<MealAnalysis> analyzeText(
    String description, {
    required String requestId,
    Future<void>? cancel,
  });
}

/// Longest meal description sent for analysis (voice or typed).
const maxMealDescriptionLength = 500;
