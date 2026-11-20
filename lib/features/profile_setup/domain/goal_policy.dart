import 'dart:math' as math;

import 'package:lanh_app/features/goal/goal.dart';

import 'body_metrics.dart';
import 'energy_estimate.dart';

/// Adult weight-plan policy for the Target step. Every number is a planning
/// estimate, not medical advice, and only applies from [BodyLimits.adultAge];
/// teens skip the numeric target entirely.
///
/// Weight loss
/// - Targets: 5%, 7% and 10% of current weight. NIH/NHLBI obesity guidance
///   names 5–10% of baseline as the clinically meaningful first goal; 7% is
///   the Diabetes Prevention Program goal (Knowler et al., NEJM 2002), the
///   best-tested middle step.
/// - Gentle pace: 10% of baseline over 26 weeks, the NHLBI "about 10% in six
///   months" schedule (≈0.38% of body weight per week).
/// - Common pace: NHS and CDC describe 0.5–1 kg (1–2 lb) per week as steady,
///   safe loss.
/// - Upper guard: the lower of 1 kg/week (NHS/CDC) and 1% of body weight per
///   week (Helms et al., JISSN 2014: 0.5–1%/week to preserve lean mass).
/// - Floor: never suggest or offer a target below WHO BMI 18.5.
/// - Energy guard: with an [EnergyEstimate], loss is never faster than the
///   pace whose daily budget stays at the energy floor; the gentle plan
///   slows down to that pace instead of asking the user to eat less.
///
/// Weight gain
/// - Targets: +5%, +7% and +10% (the same steps as loss; no trial sets a
///   gain step), never above BMI 22.9 (WHO
///   normal range for Asian adults).
/// - Gentle pace 0.25% and upper guard 0.5% of body weight per week
///   (Iraki et al., Sports 2019, gradual lean gain).
abstract final class WeightPlanPolicy {
  static const suggestionFractions = [0.05, 0.07, 0.10];
  static const lossGentleFractionPerWeek = 0.10 / 26;
  static const lossCommonMinKgPerWeek = 0.5;
  static const lossMaxKgPerWeek = 1.0;
  static const lossMaxFractionPerWeek = 0.01;
  static const gainGentleFractionPerWeek = 0.0025;
  static const gainMaxFractionPerWeek = 0.005;
  static const minimumPlanDays = 7;
  static const maximumPlanWeeks = 520;

  /// Custom targets move in half-kilogram steps; suggestions stay whole.
  static const targetStepKg = 0.5;
}

enum GoalPace {
  /// Below the common range: slower, easy to sustain.
  gentle,

  /// Inside the NHS/CDC 0.5–1 kg/week range (loss) or 0.25–0.5%/week (gain).
  common,

  /// Faster than the upper guard; the plan should not be accepted as is.
  tooFast,
}

final class GoalEstimate {
  const GoalEstimate({
    required this.rateKgPerWeek,
    required this.weeks,
    required this.pace,
    required this.projectedDate,
    this.dailyKcal,
    this.energyLimited = false,
  });

  final double rateKgPerWeek;
  final int weeks;
  final GoalPace pace;
  final DateTime projectedDate;

  /// Daily energy budget for this pace, when an energy estimate exists and
  /// the pace is acceptable.
  final double? dailyKcal;

  /// True when the energy floor slowed the gentle pace.
  final bool energyLimited;
}

final class TargetSuggestion {
  const TargetSuggestion({
    required this.fraction,
    required this.targetKg,
    required this.estimate,
    this.clamped = false,
  });

  /// The nominal step (0.05 or 0.10) that produced this suggestion.
  final double fraction;

  /// True when the BMI bound moved the target away from the nominal step,
  /// so the card should show the real change instead of 5%/7%/10%.
  final bool clamped;
  final double targetKg;
  final GoalEstimate estimate;
}

bool _isWeightGoal(GoalType goal) =>
    goal == GoalType.lose || goal == GoalType.gain;

bool _validWeight(double value) => value.isFinite && value > 0;

DateTime _day(DateTime? value) {
  final date = value ?? DateTime.now();
  return DateTime(date.year, date.month, date.day);
}

// Calendar arithmetic that stays on midnight across daylight-saving changes.
DateTime _addDays(DateTime day, int days) =>
    DateTime(day.year, day.month, day.day + days);

/// The slowest sensible pace Lành proposes when no date is set, slowed to
/// the energy floor when [energy] requires it.
double gentleRateKgPerWeek(
  GoalType goal,
  double currentKg, {
  EnergyEstimate? energy,
}) => goal == GoalType.lose
    ? math.min(
        currentKg * WeightPlanPolicy.lossGentleFractionPerWeek,
        energy?.maximumLossKgPerWeek ?? double.infinity,
      )
    : currentKg * WeightPlanPolicy.gainGentleFractionPerWeek;

/// The fastest pace Lành accepts for a chosen date.
double maximumRateKgPerWeek(
  GoalType goal,
  double currentKg, {
  EnergyEstimate? energy,
}) => goal == GoalType.lose
    ? [
        WeightPlanPolicy.lossMaxKgPerWeek,
        currentKg * WeightPlanPolicy.lossMaxFractionPerWeek,
        energy?.maximumLossKgPerWeek ?? double.infinity,
      ].reduce(math.min)
    : currentKg * WeightPlanPolicy.gainMaxFractionPerWeek;

/// False when eating at the energy floor still would not produce a loss
/// worth planning, so no loss plan is offered.
bool lossPlanAllowed(GoalType goal, EnergyEstimate? energy) =>
    goal != GoalType.lose || (energy?.allowsLoss ?? true);

GoalPace _paceFor(
  GoalType goal,
  double currentKg,
  double rate,
  EnergyEstimate? energy,
) {
  // A small tolerance keeps a date picked exactly at the limit acceptable.
  if (rate > maximumRateKgPerWeek(goal, currentKg, energy: energy) * 1.001) {
    return GoalPace.tooFast;
  }
  final commonMin = goal == GoalType.lose
      ? WeightPlanPolicy.lossCommonMinKgPerWeek
      : currentKg * WeightPlanPolicy.gainGentleFractionPerWeek;
  return rate >= commonMin - 1e-9 ? GoalPace.common : GoalPace.gentle;
}

/// Pace, duration and projected date for an adult weight goal. Without a
/// [targetDate] the gentle pace is used. Returns null for maintain/log-only,
/// invalid weights, or a target on the wrong side of the current weight.
GoalEstimate? estimateAdultGoal({
  required GoalType goal,
  required double currentWeight,
  required double targetWeight,
  DateTime? targetDate,
  DateTime? today,
  EnergyEstimate? energy,
}) {
  if (!_isWeightGoal(goal) ||
      !_validWeight(currentWeight) ||
      !_validWeight(targetWeight) ||
      !lossPlanAllowed(goal, energy)) {
    return null;
  }
  final delta = goal == GoalType.lose
      ? currentWeight - targetWeight
      : targetWeight - currentWeight;
  if (delta <= 0) return null;
  final now = _day(today);
  double? budget(double rate, GoalPace pace) => pace == GoalPace.tooFast
      ? null
      : energy?.budgetKcal(lose: goal == GoalType.lose, rateKgPerWeek: rate);
  if (targetDate == null) {
    final rate = gentleRateKgPerWeek(goal, currentWeight, energy: energy);
    final weeks = (delta / rate).ceil().clamp(
      1,
      WeightPlanPolicy.maximumPlanWeeks,
    );
    final pace = _paceFor(goal, currentWeight, rate, energy);
    return GoalEstimate(
      rateKgPerWeek: rate,
      weeks: weeks,
      pace: pace,
      projectedDate: _addDays(now, weeks * 7),
      dailyKcal: budget(rate, pace),
      energyLimited: rate < gentleRateKgPerWeek(goal, currentWeight) - 1e-9,
    );
  }
  final date = _day(targetDate);
  final days = (date.difference(now).inHours / 24).round();
  if (days <= 0) return null;
  final rate = delta / (days / 7);
  final pace = _paceFor(goal, currentWeight, rate, energy);
  return GoalEstimate(
    rateKgPerWeek: rate,
    weeks: (days / 7).ceil(),
    pace: pace,
    projectedDate: date,
    dailyKcal: budget(rate, pace),
  );
}

/// Targets a user may pick, in ascending [WeightPlanPolicy.targetStepKg]
/// steps. Loss stops at BMI 18.5 and gain at BMI 22.9, and both stay on the
/// goal's side of the current weight; the list is empty when the current
/// weight already sits at that bound.
List<double> selectableTargets({
  required GoalType goal,
  required double currentKg,
  required double heightCm,
}) {
  if (!_isWeightGoal(goal) ||
      !_validWeight(currentKg) ||
      !_validWeight(heightCm)) {
    return const [];
  }
  const step = WeightPlanPolicy.targetStepKg;
  // Work in whole steps so every value is an exact multiple of 0.5 kg.
  final (int first, int last) = goal == GoalType.lose
      ? (
          (weightAtBmi(bmi: BmiThresholds.underweight, heightCm: heightCm) /
                  step)
              .ceil(),
          (currentKg / step).ceil() - 1,
        )
      : (
          (currentKg / step).floor() + 1,
          (weightAtBmi(bmi: BmiThresholds.healthyMax, heightCm: heightCm) /
                  step)
              .floor(),
        );
  return [for (var index = first; index <= last; index++) index * step];
}

/// Lành's 5%, 7% and 10% suggestions, rounded to whole kilograms and clamped to
/// [selectableTargets]. Duplicates collapse into one card.
List<TargetSuggestion> suggestTargets({
  required GoalType goal,
  required double currentKg,
  required double heightCm,
  DateTime? today,
  EnergyEstimate? energy,
}) {
  final options = selectableTargets(
    goal: goal,
    currentKg: currentKg,
    heightCm: heightCm,
  );
  if (options.isEmpty || !lossPlanAllowed(goal, energy)) return const [];
  // Suggestions stay on whole kilograms inside the selectable range.
  final low = options.first.ceilToDouble();
  final high = options.last.floorToDouble();
  final suggestions = <TargetSuggestion>[];
  for (final fraction in WeightPlanPolicy.suggestionFractions) {
    final raw = goal == GoalType.lose
        ? currentKg * (1 - fraction)
        : currentKg * (1 + fraction);
    final rounded = raw.roundToDouble();
    // A range narrower than one kilogram has no whole value; use its edge.
    final target = low > high
        ? options.first
        : rounded.clamp(low, high).toDouble();
    if (suggestions.any((item) => item.targetKg == target)) continue;
    final estimate = estimateAdultGoal(
      goal: goal,
      currentWeight: currentKg,
      targetWeight: target,
      today: today,
      energy: energy,
    );
    if (estimate == null) continue;
    suggestions.add(
      TargetSuggestion(
        fraction: fraction,
        targetKg: target,
        estimate: estimate,
        clamped: target != rounded,
      ),
    );
  }
  return suggestions;
}

/// The first date that keeps the plan within [maximumRateKgPerWeek].
DateTime earliestSafeDate({
  required GoalType goal,
  required double currentKg,
  required double targetKg,
  DateTime? today,
  EnergyEstimate? energy,
}) {
  final now = _day(today);
  final delta = (targetKg - currentKg).abs();
  if (!_isWeightGoal(goal) || !_validWeight(currentKg) || delta == 0) {
    return _addDays(now, WeightPlanPolicy.minimumPlanDays);
  }
  final maximum = maximumRateKgPerWeek(goal, currentKg, energy: energy);
  if (maximum <= 0) {
    return _addDays(now, WeightPlanPolicy.maximumPlanWeeks * 7);
  }
  final days = (delta / maximum * 7).ceil();
  return _addDays(now, math.max(days, WeightPlanPolicy.minimumPlanDays));
}
