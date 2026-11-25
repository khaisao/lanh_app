import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/features/water/water.dart';
import 'package:lanh_app/features/weight/weight.dart';

import 'domain/weekly_review.dart';

/// Nhìn lại for the seven days before today, built from the saved meals,
/// water and weigh-ins. Loading or failing while any source does.
final weeklyReviewProvider = Provider<AsyncValue<WeeklyReview>>((ref) {
  final meals = ref.watch(recentMealLogsProvider);
  final water = ref.watch(recentWaterProvider);
  final weights = ref.watch(weightHistoryProvider);
  final goal = ref.watch(profileGoalProvider);
  for (final source in [meals, water, weights, goal]) {
    if (source.hasError) {
      return AsyncError(source.error!, source.stackTrace ?? StackTrace.empty);
    }
  }
  if (!meals.hasValue || !water.hasValue || !weights.hasValue) {
    return const AsyncLoading();
  }
  final kcalByDay = <DateTime, double>{};
  for (final meal in meals.requireValue) {
    final local = meal.createdAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    // A logged meal makes the day logged even if its kcal is unknown.
    kcalByDay[day] = (kcalByDay[day] ?? 0) + (meal.totalCalories ?? 0);
  }
  return AsyncData(
    WeeklyReview.of(
      today: DateTime.now(),
      kcalByDay: kcalByDay,
      waterByDay: water.requireValue,
      weights: [
        for (final entry in weights.requireValue)
          (day: entry.day, kg: entry.kg),
      ],
      goal: switch (goal.value?.type) {
        GoalType.lose => ReviewGoal.lose,
        GoalType.gain => ReviewGoal.gain,
        GoalType.maintain => ReviewGoal.maintain,
        GoalType.logOnly || null => ReviewGoal.none,
      },
      target: ref.watch(profileEnergyTargetProvider),
      waterGoal: ref.watch(waterGoalGlassesProvider),
    ),
  );
});

/// Retries every source of [weeklyReviewProvider].
void retryWeeklyReview(WidgetRef ref) {
  ref
    ..invalidate(recentMealLogsProvider)
    ..invalidate(recentWaterProvider)
    ..invalidate(weightHistoryProvider);
}
