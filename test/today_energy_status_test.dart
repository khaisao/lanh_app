import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/today/domain/today_energy_status.dart';

void main() {
  TodayEnergyStatus status(GoalType goal, int target, double logged) =>
      TodayEnergyStatus.of(goal: goal, target: target, logged: logged)!;

  test('maintain range is ±10 % on the 50-kcal step', () {
    expect(maintainRangeFor(2100), const TodayEnergyRange(1900, 2300));
    expect(maintainRangeFor(1850), const TodayEnergyRange(1650, 2050));
  });

  test('no plan gives no status', () {
    for (final (goal, target) in const [
      (GoalType.logOnly, 2000),
      (null, 2000),
      (GoalType.gain, null),
      (GoalType.lose, 0),
    ]) {
      expect(
        TodayEnergyStatus.of(goal: goal, target: target, logged: 500),
        isNull,
      );
    }
  });

  test('gain is below until the target, then reached', () {
    final below = status(GoalType.gain, 2500, 980);
    expect(below.state, TodayEnergyState.gainBelow);
    expect(below.remaining, 1520);
    expect(below.fill, closeTo(.392, .001));
    expect(below.overflowEnd, isNull);

    final reached = status(GoalType.gain, 2500, 2540);
    expect(reached.state, TodayEnergyState.gainReached);
    expect(reached.state.isDone, isTrue);
    expect(reached.fill, 1);
    expect(reached.overflowEnd, isNull);
  });

  test('lose is within, at plan, or over by whole kcal', () {
    expect(status(GoalType.lose, 1800, 980).remaining, 820);
    expect(
      status(GoalType.lose, 1800, 1799.6).state,
      TodayEnergyState.loseAtPlan,
    );
    final over = status(GoalType.lose, 1800, 2050);
    expect(over.state, TodayEnergyState.loseOver);
    expect(over.over, 250);
    expect(over.fill, closeTo(1800 / 2050, 1e-9));
    expect(over.overflowEnd, 1);
  });

  test('maintain is below, within or above its range', () {
    final below = status(GoalType.maintain, 2100, 980);
    expect(below.state, TodayEnergyState.maintainBelow);
    expect(below.gapToRange, const TodayEnergyRange(920, 1320));
    expect(below.zone!.$1, closeTo(.76, .001));
    expect(below.zone!.$2, closeTo(.92, .001));

    final edge = status(GoalType.maintain, 2100, 2300);
    expect(edge.state, TodayEnergyState.maintainWithin);

    final above = status(GoalType.maintain, 2100, 2450);
    expect(above.state, TodayEnergyState.maintainAbove);
    expect(above.over, 150);
    expect(above.fill, closeTo(.92, .001));
    expect(above.overflowEnd, closeTo(.98, .001));

    final far = status(GoalType.maintain, 2100, 4000);
    expect(far.overflowEnd, closeTo(.98, .001));
    expect(far.zone!.$2, lessThan(far.overflowEnd!));
  });
}
