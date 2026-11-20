import 'package:lanh_app/features/goal/goal.dart';

import '../domain/energy_estimate.dart';
import '../domain/goal_policy.dart';

enum ProfileTargetMode { suggested, custom }

enum ProfileTargetTiming { none, date }

/// Immutable choices on the Target step. Only [targetKg] and the [deadline]
/// are saved; the rest is how the user reached them.
final class ProfileTargetDraft {
  const ProfileTargetDraft({
    this.mode = ProfileTargetMode.suggested,
    this.suggestedKg,
    this.customKg,
    this.timing = ProfileTargetTiming.none,
    this.date,
  });

  final ProfileTargetMode mode;
  final double? suggestedKg;
  final double? customKg;
  final ProfileTargetTiming timing;

  /// The day the user picked. It is never overwritten: [deadline] moves past
  /// it when the custom target needs more time, and comes back when it does
  /// not.
  final DateTime? date;

  double? get targetKg =>
      mode == ProfileTargetMode.suggested ? suggestedKg : customKg;

  /// The saved deadline: the picked [date], or the earliest safe date for the
  /// custom target when the picked day has become too soon. Null unless the
  /// user set a date in custom mode.
  DateTime? deadline({
    required GoalType goal,
    required double currentKg,
    EnergyEstimate? energy,
  }) {
    final date = this.date;
    final target = customKg;
    if (mode != ProfileTargetMode.custom ||
        timing != ProfileTargetTiming.date ||
        date == null ||
        target == null) {
      return null;
    }
    final earliest = earliestSafeDate(
      goal: goal,
      currentKg: currentKg,
      targetKg: target,
      energy: energy,
    );
    return date.isBefore(earliest) ? earliest : date;
  }

  ProfileTargetDraft copyWith({
    ProfileTargetMode? mode,
    double? Function()? suggestedKg,
    double? Function()? customKg,
    ProfileTargetTiming? timing,
    DateTime? Function()? date,
  }) => ProfileTargetDraft(
    mode: mode ?? this.mode,
    suggestedKg: suggestedKg == null ? this.suggestedKg : suggestedKg(),
    customKg: customKg == null ? this.customKg : customKg(),
    timing: timing ?? this.timing,
    date: date == null ? this.date : date(),
  );

  /// Keeps choices that are still valid for the current body values. The
  /// suggestion defaults to Lành's first plan, as in the design; the custom
  /// target defaults to that plan too, or to the healthy target nearest the
  /// current weight when there is no plan.
  ProfileTargetDraft reconcile({
    required GoalType goal,
    required double currentKg,
    required double heightCm,
  }) {
    final suggestions = suggestTargets(
      goal: goal,
      currentKg: currentKg,
      heightCm: heightCm,
    ).map((item) => item.targetKg).toList();
    final options = selectableTargets(
      goal: goal,
      currentKg: currentKg,
      heightCm: heightCm,
    );
    final suggested = suggestions.contains(suggestedKg)
        ? suggestedKg
        : suggestions.firstOrNull;
    final nearest = goal == GoalType.lose
        ? options.lastOrNull
        : options.firstOrNull;
    return copyWith(
      suggestedKg: () => suggested,
      customKg: () =>
          options.contains(customKg) ? customKg : suggested ?? nearest,
    );
  }
}
