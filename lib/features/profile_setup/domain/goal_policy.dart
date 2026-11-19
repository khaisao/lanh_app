import 'package:lanh_app/features/goal/domain/goal.dart';

final class GoalEstimate {
  const GoalEstimate({
    required this.rateKgPerWeek,
    required this.weeks,
    required this.status,
    this.targetDate,
  });

  final double rateKgPerWeek;
  final int weeks;
  final GoalEstimateStatus status;
  final DateTime? targetDate;
}

enum GoalEstimateStatus { recommended, slower, tooFast, caution }

GoalEstimate? estimateAdultGoal({
  required GoalType goal,
  required double currentWeight,
  required double targetWeight,
  DateTime? targetDate,
  DateTime? today,
}) {
  if (goal == GoalType.maintain ||
      !currentWeight.isFinite ||
      !targetWeight.isFinite ||
      currentWeight <= 0 ||
      targetWeight <= 0) {
    return null;
  }
  final delta = (targetWeight - currentWeight).abs();
  if (delta == 0) return null;
  final now = DateTime(
    today?.year ?? DateTime.now().year,
    today?.month ?? DateTime.now().month,
    today?.day ?? DateTime.now().day,
  );
  final defaultRate = goal == GoalType.lose ? 0.5 : currentWeight * 0.25 / 100;
  final maximumRate = goal == GoalType.lose ? 1.0 : currentWeight * 0.5 / 100;
  final weeks = targetDate == null
      ? (delta / defaultRate).ceil().clamp(1, 520)
      : (targetDate.difference(now).inDays / 7).clamp(0.01, 520.0);
  final rate = targetDate == null ? defaultRate : delta / weeks;
  final status = goal == GoalType.lose
      ? rate > maximumRate
            ? GoalEstimateStatus.tooFast
            : rate < defaultRate
            ? GoalEstimateStatus.slower
            : GoalEstimateStatus.recommended
      : rate > maximumRate
      ? GoalEstimateStatus.caution
      : GoalEstimateStatus.recommended;
  return GoalEstimate(
    rateKgPerWeek: rate,
    weeks: weeks.ceil(),
    status: status,
    targetDate: targetDate ?? now.add(Duration(days: (weeks * 7).ceil())),
  );
}
