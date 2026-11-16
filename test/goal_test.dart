import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/features/goal/goal.dart';

class _GoalRepository implements GoalRepository {
  Goal? value;
  @override
  Future<Goal?> read() async => value;
  @override
  Future<void> save(Goal goal) async => value = goal;
  @override
  Future<void> clear() async => value = null;
}

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

  test('controller persists a log-only goal', () async {
    final goals = _GoalRepository();
    final container = ProviderContainer.test(
      overrides: [goalRepositoryProvider.overrideWithValue(goals)],
    );
    final now = DateTime.now();
    await container
        .read(goalControllerProvider.notifier)
        .save(Goal(type: GoalType.logOnly, createdAt: now, updatedAt: now));
    expect(goals.value?.type, GoalType.logOnly);
    container.dispose();
  });
}
