import 'package:lanh_app/features/goal/goal.dart';

import '../domain/goal_policy.dart';

enum ProfileTargetMode { suggested, custom }

enum ProfileTargetTiming { none, date }

/// Immutable choices on the Target step. Only [targetKg] and [targetDate] are
/// saved; the rest is how the user reached them.
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
  final int? customKg;
  final ProfileTargetTiming timing;
  final DateTime? date;

  double? get targetKg =>
      mode == ProfileTargetMode.suggested ? suggestedKg : customKg?.toDouble();

  /// A deadline is optional and only exists when the user chose one.
  DateTime? get targetDate =>
      mode == ProfileTargetMode.custom && timing == ProfileTargetTiming.date
      ? date
      : null;

  ProfileTargetDraft copyWith({
    ProfileTargetMode? mode,
    double? Function()? suggestedKg,
    int? Function()? customKg,
    ProfileTargetTiming? timing,
    DateTime? Function()? date,
  }) => ProfileTargetDraft(
    mode: mode ?? this.mode,
    suggestedKg: suggestedKg == null ? this.suggestedKg : suggestedKg(),
    customKg: customKg == null ? this.customKg : customKg(),
    timing: timing ?? this.timing,
    date: date == null ? this.date : date(),
  );

  /// Keeps choices that are still valid for the current body values and
  /// preselects Lành's first suggestion, as in the design.
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
    return copyWith(
      suggestedKg: () => suggestions.contains(suggestedKg)
          ? suggestedKg
          : suggestions.firstOrNull,
      customKg: () => options.contains(customKg) ? customKg : null,
    );
  }
}
