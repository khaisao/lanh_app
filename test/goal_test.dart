import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/goal/goal.dart';

void main() {
  test('goal JSON round trips with versioned fields', () {
    final created = DateTime.utc(2026, 11, 16, 12);
    final goal = Goal(
      type: GoalType.lose,
      currentWeight: 70,
      targetWeight: 62,
      targetDate: DateTime.utc(2027, 2, 16),
      createdAt: created,
      updatedAt: created,
    );
    final decoded = Goal.decode(goal.encode());
    expect(decoded?.type, GoalType.lose);
    expect(decoded?.currentWeight, 70);
    expect(decoded?.targetDate, DateTime.utc(2027, 2, 16));
    expect(decoded?.schedule, GoalSchedule.byDate);
  });
}
