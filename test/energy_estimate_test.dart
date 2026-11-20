import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/profile_setup/domain/energy_estimate.dart';
import 'package:lanh_app/features/profile_setup/domain/goal_policy.dart';
import 'package:lanh_app/features/profile_setup/domain/profile.dart';

EnergyEstimate _woman({
  int age = 32,
  double height = 165,
  double weight = 61.5,
  ActivityLevel activity = ActivityLevel.sitting,
}) => estimateEnergy(
  ageYears: age,
  heightCm: height,
  weightKg: weight,
  sex: ProfileSex.female,
  activity: activity,
)!;

void main() {
  final today = DateTime(2026, 1, 1);

  test('Mifflin-St Jeor resting energy for women and men', () {
    // 10×61.5 + 6.25×165 − 5×32 − 161.
    expect(
      restingEnergyKcal(
        weightKg: 61.5,
        heightCm: 165,
        ageYears: 32,
        sex: ProfileSex.female,
      ),
      closeTo(1325.25, 1e-9),
    );
    // 10×85 + 6.25×175 − 5×40 + 5.
    expect(
      restingEnergyKcal(
        weightKg: 85,
        heightCm: 175,
        ageYears: 40,
        sex: ProfileSex.male,
      ),
      closeTo(1748.75, 1e-9),
    );
  });

  test('maps each activity answer to an FAO/WHO/UNU PAL', () {
    expect(physicalActivityLevel(ActivityLevel.sitting), 1.40);
    expect(physicalActivityLevel(ActivityLevel.light), 1.55);
    expect(physicalActivityLevel(ActivityLevel.moderate), 1.75);
    expect(physicalActivityLevel(ActivityLevel.heavy), 2.00);
    expect(physicalActivityLevel(ActivityLevel.variable), 1.40);
    expect(physicalActivityRange(ActivityLevel.variable), (1.40, 1.75));
    expect(physicalActivityRange(ActivityLevel.light), isNull);
  });

  test('total energy, range and floor', () {
    final energy = _woman();
    expect(energy.totalKcal, closeTo(1855.35, 0.01));
    expect(energy.floorKcal, closeTo(1325.25, 0.01));
    expect(roundKcal(energy.totalKcal), 1850);

    final variable = _woman(activity: ActivityLevel.variable);
    expect(variable.totalRangeKcal!.$1, closeTo(1855.35, 0.01));
    expect(variable.totalRangeKcal!.$2, closeTo(2319.19, 0.01));

    // Small older woman: resting energy below 1,200, so 1,200 is the floor.
    final small = _woman(age: 55, height: 152, weight: 58);
    expect(small.restingKcal, closeTo(1094, 0.01));
    expect(small.floorKcal, 1200);
  });

  test('no estimate for teens or missing values', () {
    expect(_estimate(age: 19), isNull);
    expect(_estimate(activity: null), isNull);
    expect(_estimate(height: 90), isNull);
    expect(_estimate(), isNotNull);
  });

  test('budget subtracts about 1,100 kcal per kg/week and keeps the floor', () {
    final energy = _woman();
    expect(dailyKcalForRate(1), closeTo(1100, 1e-9));
    expect(
      energy.budgetKcal(lose: true, rateKgPerWeek: 0.2),
      closeTo(1635.35, 0.01),
    );
    // 0.5 kg/week would need 1,305 kcal, below resting energy.
    expect(energy.budgetKcal(lose: true, rateKgPerWeek: 0.5), energy.floorKcal);
    // Gain surplus is capped at 500 kcal/day.
    expect(
      energy.budgetKcal(lose: false, rateKgPerWeek: 1),
      closeTo(2355.35, 0.01),
    );
  });

  test('energy floor caps the loss pace and refuses a too-fast date', () {
    final energy = _woman();
    // (1855.35 − 1325.25) × 7 / 7700 ≈ 0.48 kg/week.
    expect(energy.maximumLossKgPerWeek, closeTo(0.4819, 0.0001));
    expect(
      maximumRateKgPerWeek(GoalType.lose, 61.5, energy: energy),
      closeTo(0.4819, 0.0001),
    );
    final tooFast = estimateAdultGoal(
      goal: GoalType.lose,
      currentWeight: 61.5,
      targetWeight: 58.5,
      targetDate: DateTime(2026, 2, 12),
      today: today,
      energy: energy,
    )!;
    // 3 kg in 6 weeks = 0.5 kg/week: fine for NHS, too fast for this body.
    expect(tooFast.pace, GoalPace.tooFast);
    expect(tooFast.dailyKcal, isNull);
    expect(
      earliestSafeDate(
        goal: GoalType.lose,
        currentKg: 61.5,
        targetKg: 58.5,
        today: today,
        energy: energy,
      ),
      DateTime(2026, 2, 14),
    );
  });

  test('gentle plan shows its daily budget and slows at the floor', () {
    final plan = suggestTargets(
      goal: GoalType.lose,
      currentKg: 61.5,
      heightCm: 165,
      today: today,
      energy: _woman(),
    ).first;
    expect(plan.estimate.dailyKcal, closeTo(1595.2, 0.1));
    expect(plan.estimate.energyLimited, isFalse);

    // Very small, sedentary adult: the floor is above the gentle budget.
    final tight = estimateEnergy(
      ageYears: 70,
      heightCm: 150,
      weightKg: 56,
      sex: ProfileSex.female,
      activity: ActivityLevel.sitting,
    )!;
    final slowed = estimateAdultGoal(
      goal: GoalType.lose,
      currentWeight: 56,
      targetWeight: 53,
      today: today,
      energy: tight,
    )!;
    expect(slowed.energyLimited, isTrue);
    expect(slowed.rateKgPerWeek, closeTo(tight.maximumLossKgPerWeek, 1e-9));
    expect(slowed.dailyKcal, closeTo(1200, 0.01));
  });

  test('no loss plan when the floor leaves no room for a deficit', () {
    final none = estimateEnergy(
      ageYears: 80,
      heightCm: 145,
      weightKg: 48,
      sex: ProfileSex.female,
      activity: ActivityLevel.sitting,
    )!;
    expect(none.allowsLoss, isFalse);
    expect(lossPlanAllowed(GoalType.lose, none), isFalse);
    expect(
      suggestTargets(
        goal: GoalType.lose,
        currentKg: 48,
        heightCm: 145,
        energy: none,
      ),
      isEmpty,
    );
    expect(lossPlanAllowed(GoalType.gain, none), isTrue);
  });
}

EnergyEstimate? _estimate({
  int age = 32,
  double height = 165,
  ActivityLevel? activity = ActivityLevel.sitting,
}) => estimateEnergy(
  ageYears: age,
  heightCm: height,
  weightKg: 61.5,
  sex: ProfileSex.female,
  activity: activity,
);
