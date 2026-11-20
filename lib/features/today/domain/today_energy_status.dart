import 'dart:math' as math;

import 'package:lanh_app/features/goal/goal.dart';

/// Where today's logged energy stands against the saved daily plan.
enum TodayEnergyState {
  gainBelow,
  gainReached,
  loseWithin,
  loseAtPlan,
  loseOver,
  maintainBelow,
  maintainWithin,
  maintainAbove;

  /// The plan is met for today: gain reached, lose exactly at plan, or
  /// maintain inside its range.
  bool get isDone =>
      this == gainReached || this == loseAtPlan || this == maintainWithin;

  /// Logged energy went past the plan (lose) or above the range (maintain).
  bool get isOver => this == loseOver || this == maintainAbove;
}

/// A closed kcal range, both ends on the plan's 50-kcal display step.
final class TodayEnergyRange {
  const TodayEnergyRange(this.lower, this.upper);

  final int lower;
  final int upper;

  @override
  bool operator ==(Object other) =>
      other is TodayEnergyRange && other.lower == lower && other.upper == upper;

  @override
  int get hashCode => Object.hash(lower, upper);
}

/// The kcal step every plan number is shown in (see the plan sheet).
const todayEnergyStep = 50;

/// Maintenance window around a daily target: ±10 %, each end rounded to the
/// 50-kcal step. 2.100 kcal gives 1.900–2.300, as in the Sleek Home design.
TodayEnergyRange maintainRangeFor(int target) {
  int step(double value) => (value / todayEnergyStep).round() * todayEnergyStep;
  return TodayEnergyRange(step(target * 0.9), step(target * 1.1));
}

/// Today's energy against a gain, lose or maintain plan, plus the meter
/// geometry the Home card draws. Values are compared as whole kcal, the
/// precision the card displays.
final class TodayEnergyStatus {
  TodayEnergyStatus._({
    required this.goal,
    required this.target,
    required this.logged,
    required this.range,
    required this.state,
  });

  /// Null when there is no plan to compare against: a log-only or missing
  /// goal, or no positive kcal target.
  static TodayEnergyStatus? of({
    required GoalType? goal,
    required int? target,
    required double logged,
  }) {
    if (target == null || target <= 0 || !logged.isFinite || logged < 0) {
      return null;
    }
    final kcal = logged.round();
    switch (goal) {
      case GoalType.gain:
        return TodayEnergyStatus._(
          goal: GoalType.gain,
          target: target,
          logged: kcal,
          range: null,
          state: kcal >= target
              ? TodayEnergyState.gainReached
              : TodayEnergyState.gainBelow,
        );
      case GoalType.lose:
        return TodayEnergyStatus._(
          goal: GoalType.lose,
          target: target,
          logged: kcal,
          range: null,
          state: kcal < target
              ? TodayEnergyState.loseWithin
              : kcal == target
              ? TodayEnergyState.loseAtPlan
              : TodayEnergyState.loseOver,
        );
      case GoalType.maintain:
        final range = maintainRangeFor(target);
        return TodayEnergyStatus._(
          goal: GoalType.maintain,
          target: target,
          logged: kcal,
          range: range,
          state: kcal < range.lower
              ? TodayEnergyState.maintainBelow
              : kcal <= range.upper
              ? TodayEnergyState.maintainWithin
              : TodayEnergyState.maintainAbove,
        );
      case GoalType.logOnly || null:
        return null;
    }
  }

  final GoalType goal;
  final int target;
  final int logged;

  /// The maintenance window; null for gain and lose.
  final TodayEnergyRange? range;
  final TodayEnergyState state;

  /// kcal still to log before the gain target or the lose plan is used up.
  int get remaining => math.max(0, target - logged);

  /// kcal past the lose plan or above the maintain range.
  int get over => switch (state) {
    TodayEnergyState.loseOver => logged - target,
    TodayEnergyState.maintainAbove => logged - range!.upper,
    _ => 0,
  };

  /// kcal needed to reach each end of the maintain range from below.
  TodayEnergyRange get gapToRange =>
      TodayEnergyRange(range!.lower - logged, range!.upper - logged);

  /// The kcal value the full meter width stands for. Gain fills to its
  /// target; lose grows past the plan so an overrun stays visible; maintain
  /// keeps its range at 76–92 % of the track, as in the design, and grows
  /// when the day goes far above it.
  double get scale => switch (goal) {
    GoalType.gain => target.toDouble(),
    GoalType.lose => math.max(target, logged).toDouble(),
    _ => math.max(range!.upper / 0.92, logged / 0.98),
  };

  /// Width fraction of the green fill: what was logged up to the plan.
  double get fill => switch (goal) {
    GoalType.gain => math.min(logged / target, 1.0),
    GoalType.lose => math.min(logged, target) / scale,
    _ => math.min(logged, range!.upper) / scale,
  };

  /// Width fraction where the warm overrun segment ends; null without one.
  double? get overflowEnd => state.isOver ? logged / scale : null;

  /// The maintain range as fractions of the track; null for gain and lose.
  (double, double)? get zone =>
      range == null ? null : (range!.lower / scale, range!.upper / scale);
}
