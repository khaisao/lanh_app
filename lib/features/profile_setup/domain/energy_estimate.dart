import 'dart:math' as math;

import 'body_metrics.dart';
import 'profile.dart';

/// Adult daily energy estimate for Profile Setup. A planning estimate, not a
/// measurement or medical advice; teens get no number.
///
/// Sources:
/// - Resting energy: Mifflin‑St Jeor (Am J Clin Nutr 1990). It tends to
///   overestimate in several Asian samples, so Lành picks the lower PAL in
///   each band to avoid inflating the budget.
/// - Total energy = resting × physical activity level (PAL). Bands from the
///   FAO/WHO/UNU 2004 Human energy requirements report: sedentary/light
///   1.40–1.69, active 1.70–1.99, vigorous 2.00–2.40; NASEM 2023 typical
///   values ≈1.4 / 1.6 / 1.75 / 2.05.
/// - Deficit: ≈7,700 kcal per kg, valid for early weight change only
///   (Hall et al., Lancet 2011), so the budget is re-estimated from the new
///   weight rather than fixed.
/// - Floor: never below resting energy, nor 1,200 kcal (women) / 1,500 kcal
///   (men), the lower ends NHLBI gives for weight-loss eating plans.
abstract final class EnergyPolicy {
  static const kcalPerKg = 7700.0;
  static const daysPerWeek = 7.0;
  static const minimumFemaleKcal = 1200.0;
  static const minimumMaleKcal = 1500.0;
  static const maximumGainSurplusKcal = 500.0;

  /// Below this the deficit is too small to plan a loss at all.
  static const minimumLossKgPerWeek = 0.1;
  static const displayStepKcal = 50;

  /// Bounds for a budget the user types in.
  static const maximumBudgetKcal = 5000;
}

/// Physical activity level used for each answer on "Một ngày thường".
double physicalActivityLevel(ActivityLevel level) => switch (level) {
  ActivityLevel.sitting => 1.40,
  ActivityLevel.light => 1.55,
  ActivityLevel.moderate => 1.75,
  ActivityLevel.heavy => 2.00,
  // Unknown schedules use the low end so the budget is not overstated.
  ActivityLevel.variable => 1.40,
};

/// The PAL range shown when the answer does not pin one value.
(double, double)? physicalActivityRange(ActivityLevel level) =>
    level == ActivityLevel.variable ? (1.40, 1.75) : null;

/// Mifflin‑St Jeor resting energy in kcal/day.
double restingEnergyKcal({
  required double weightKg,
  required double heightCm,
  required int ageYears,
  required ProfileSex sex,
}) =>
    10 * weightKg +
    6.25 * heightCm -
    5 * ageYears +
    (sex == ProfileSex.male ? 5 : -161);

/// Rounds a kcal value for display only; calculations keep full precision.
int roundKcal(double kcal) =>
    (kcal / EnergyPolicy.displayStepKcal).round() *
    EnergyPolicy.displayStepKcal;

/// Converts a weekly weight change to a daily energy difference.
double dailyKcalForRate(double kgPerWeek) =>
    kgPerWeek * EnergyPolicy.kcalPerKg / EnergyPolicy.daysPerWeek;

final class EnergyEstimate {
  const EnergyEstimate({
    required this.restingKcal,
    required this.totalKcal,
    required this.floorKcal,
    this.totalRangeKcal,
  });

  final double restingKcal;

  /// Estimated energy used per day (resting × PAL).
  final double totalKcal;

  /// Present when the activity answer is a range rather than one value.
  final (double, double)? totalRangeKcal;

  /// Lowest daily budget Lành will suggest or accept.
  final double floorKcal;

  /// Fastest loss whose budget stays at or above [floorKcal].
  double get maximumLossKgPerWeek => math.max(
    0,
    (totalKcal - floorKcal) * EnergyPolicy.daysPerWeek / EnergyPolicy.kcalPerKg,
  );

  bool get allowsLoss =>
      maximumLossKgPerWeek >= EnergyPolicy.minimumLossKgPerWeek;

  /// Daily budget for a plan. Loss subtracts the deficit, gain adds a
  /// surplus capped at [EnergyPolicy.maximumGainSurplusKcal], maintain keeps
  /// the estimate. The result never drops below [floorKcal].
  double budgetKcal({required bool lose, required double rateKgPerWeek}) {
    final change = dailyKcalForRate(rateKgPerWeek.abs());
    final budget = lose
        ? totalKcal - change
        : totalKcal + math.min(change, EnergyPolicy.maximumGainSurplusKcal);
    return math.max(budget, floorKcal);
  }
}

/// Energy estimate for an adult, or null when Lành should not compute one:
/// missing or implausible values or ages under [BodyLimits.adultAge].
EnergyEstimate? estimateEnergy({
  required int? ageYears,
  required double? heightCm,
  required double? weightKg,
  required ProfileSex? sex,
  required ActivityLevel? activity,
}) {
  if (ageYears == null ||
      heightCm == null ||
      weightKg == null ||
      sex == null ||
      activity == null) {
    return null;
  }
  if (ageYears < BodyLimits.adultAge ||
      ageYears > BodyLimits.maxAge ||
      heightCm < BodyLimits.minHeightCm ||
      heightCm > BodyLimits.maxHeightCm ||
      weightKg < BodyLimits.minWeightKg ||
      weightKg > BodyLimits.maxWeightKg) {
    return null;
  }
  final resting = restingEnergyKcal(
    weightKg: weightKg,
    heightCm: heightCm,
    ageYears: ageYears,
    sex: sex,
  );
  final range = physicalActivityRange(activity);
  return EnergyEstimate(
    restingKcal: resting,
    totalKcal: resting * physicalActivityLevel(activity),
    totalRangeKcal: range == null
        ? null
        : (resting * range.$1, resting * range.$2),
    floorKcal: math.max(
      resting,
      sex == ProfileSex.female
          ? EnergyPolicy.minimumFemaleKcal
          : EnergyPolicy.minimumMaleKcal,
    ),
  );
}
