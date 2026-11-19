import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/goal/domain/goal.dart';
import 'package:lanh_app/features/profile_setup/domain/goal_policy.dart';

void main() {
  test('adult loss defaults to a gradual pace', () {
    final estimate = estimateAdultGoal(
      goal: GoalType.lose,
      currentWeight: 80,
      targetWeight: 72,
      today: DateTime(2026, 1, 1),
    );
    expect(estimate, isNotNull);
    expect(estimate!.rateKgPerWeek, 0.5);
    expect(estimate.weeks, 16);
    expect(estimate.status, GoalEstimateStatus.recommended);
  });

  test('adult loss rejects an overly fast chosen date', () {
    final estimate = estimateAdultGoal(
      goal: GoalType.lose,
      currentWeight: 80,
      targetWeight: 72,
      targetDate: DateTime(2026, 1, 15),
      today: DateTime(2026, 1, 1),
    );
    expect(estimate!.status, GoalEstimateStatus.tooFast);
  });
}
