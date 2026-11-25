/// The goal a week is judged against. Log-only and missing goals have no
/// direction, so the verdict stays neutral.
enum ReviewGoal { lose, gain, maintain, none }

enum ReviewVerdict {
  /// Weight moved the way the goal asks.
  onTrack,

  /// Weight moved against the goal.
  offTrack,

  /// Fewer than two weigh-ins in the week, or no goal direction.
  unknown,
}

/// Days Nhìn lại looks back on: the seven days before today.
const reviewDays = 7;

/// Below this many logged days the week is too thin to analyse.
const reviewMinLoggedDays = 3;

/// Weekend days must average this much more than weekdays to be noted.
const reviewWeekendGapKcal = 200;

/// A maintain goal is on track while weight stays within this many kg.
const reviewMaintainToleranceKg = 0.5;

/// One weigh-in on a local day.
typedef ReviewWeight = ({DateTime day, double kg});

/// Weekend days ate more than weekdays, on average per logged day.
final class WeekendGap {
  const WeekendGap({required this.weekendKcal, required this.weekdayKcal});

  final double weekendKcal;
  final double weekdayKcal;

  double get gap => weekendKcal - weekdayKcal;
}

/// The seven days before [today]: logged kcal against the plan, water,
/// weigh-ins and the weekend pattern. Days without meals are missing, not
/// zero, so averages divide by the days that were logged.
final class WeeklyReview {
  WeeklyReview._({
    required this.days,
    required this.kcal,
    required this.target,
    required this.overLimit,
    required this.water,
    required this.waterGoal,
    required this.weights,
    required this.goal,
  });

  factory WeeklyReview.of({
    required DateTime today,
    required Map<DateTime, double> kcalByDay,
    required Map<DateTime, int> waterByDay,
    required List<ReviewWeight> weights,
    required ReviewGoal goal,
    int? target,
    int? waterGoal,
  }) {
    final start = DateTime(today.year, today.month, today.day - reviewDays);
    final days = [
      for (var i = 0; i < reviewDays; i++)
        DateTime(start.year, start.month, start.day + i),
    ];
    final end = DateTime(today.year, today.month, today.day);
    bool inWeek(DateTime day) => !day.isBefore(start) && day.isBefore(end);
    final inRange = weights.where((w) => inWeek(w.day)).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    return WeeklyReview._(
      days: days,
      kcal: [for (final day in days) kcalByDay[day]],
      target: target,
      overLimit: target == null
          ? null
          : switch (goal) {
              ReviewGoal.lose => target.toDouble(),
              // The top of the ±10 % maintain band on Home.
              ReviewGoal.maintain => target * 1.1,
              ReviewGoal.gain || ReviewGoal.none => null,
            },
      water: [for (final day in days) waterByDay[day]],
      waterGoal: waterGoal,
      weights: inRange,
      goal: goal,
    );
  }

  /// The reviewed days, oldest first.
  final List<DateTime> days;

  /// Logged kcal per day of [days]; null when nothing was logged.
  final List<double?> kcal;

  /// The daily plan, when the profile has one.
  final int? target;

  /// A day above this kcal went over the plan; null when the goal has no
  /// upper limit (gain) or there is no plan.
  final double? overLimit;

  /// Glasses per day of [days]; null when none were logged.
  final List<int?> water;
  final int? waterGoal;

  /// Weigh-ins inside the week, oldest first.
  final List<ReviewWeight> weights;
  final ReviewGoal goal;

  int get loggedDays => kcal.whereType<double>().length;

  bool get thin => loggedDays < reviewMinLoggedDays;

  /// Logged days still needed before the analysis shows.
  int get daysToAnalysis => thin ? reviewMinLoggedDays - loggedDays : 0;

  double? get averageKcal => _average(kcal.whereType<double>());

  bool isOver(double? dayKcal) =>
      dayKcal != null && overLimit != null && dayKcal.round() > overLimit!;

  int get overDays => kcal.where(isOver).length;

  double? get averageWater =>
      _average(water.whereType<int>().map((glasses) => glasses.toDouble()));

  int get waterGoalDays {
    final goal = waterGoal;
    if (goal == null) return 0;
    return water.whereType<int>().where((glasses) => glasses >= goal).length;
  }

  int get waterDays => water.whereType<int>().length;

  ReviewWeight? get latestWeight => weights.isEmpty ? null : weights.last;

  /// Last minus first weigh-in of the week; null with fewer than two.
  double? get weightChange =>
      weights.length < 2 ? null : weights.last.kg - weights.first.kg;

  ReviewVerdict get verdict {
    final change = weightChange;
    if (change == null) return ReviewVerdict.unknown;
    final good = switch (goal) {
      ReviewGoal.lose => change < 0,
      ReviewGoal.gain => change > 0,
      ReviewGoal.maintain => change.abs() <= reviewMaintainToleranceKg,
      ReviewGoal.none => null,
    };
    return switch (good) {
      true => ReviewVerdict.onTrack,
      false => ReviewVerdict.offTrack,
      null => ReviewVerdict.unknown,
    };
  }

  /// Weekend (Saturday, Sunday) average minus weekday average, when both
  /// have logged days and the gap reaches [reviewWeekendGapKcal].
  WeekendGap? get weekendGap {
    final weekend = <double>[];
    final weekdays = <double>[];
    for (var i = 0; i < days.length; i++) {
      final value = kcal[i];
      if (value == null) continue;
      final day = days[i].weekday;
      (day == DateTime.saturday || day == DateTime.sunday ? weekend : weekdays)
          .add(value);
    }
    final weekendKcal = _average(weekend);
    final weekdayKcal = _average(weekdays);
    if (weekendKcal == null || weekdayKcal == null) return null;
    final gap = WeekendGap(weekendKcal: weekendKcal, weekdayKcal: weekdayKcal);
    return gap.gap >= reviewWeekendGapKcal ? gap : null;
  }

  static double? _average(Iterable<double> values) {
    if (values.isEmpty) return null;
    return values.fold<double>(0, (sum, value) => sum + value) / values.length;
  }
}
