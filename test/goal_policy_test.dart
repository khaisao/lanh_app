import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/goal/domain/goal.dart';
import 'package:lanh_app/features/profile_setup/domain/goal_policy.dart';

void main() {
  final today = DateTime(2026, 1, 1);

  group('loss', () {
    test(
      'suggests 5%, 7% (DPP) and 10% in whole kg at the NHLBI gentle pace',
      () {
        final suggestions = suggestTargets(
          goal: GoalType.lose,
          currentKg: 62,
          heightCm: 165,
          today: today,
        );
        expect(suggestions.map((s) => s.targetKg), [59, 58, 56]);
        // 10% of 62 kg over 26 weeks.
        expect(suggestions.first.estimate.rateKgPerWeek, closeTo(0.2385, 1e-4));
        expect(suggestions.first.estimate.weeks, 13);
        expect(suggestions.last.estimate.weeks, 26);
        expect(suggestions.first.estimate.pace, GoalPace.gentle);
        expect(suggestions.first.estimate.projectedDate, DateTime(2026, 4, 2));
      },
    );

    test('never goes below WHO BMI 18.5 and collapses duplicates', () {
      // 18.5 x 1.65² = 50.37 kg, so the floor is 51 kg.
      final options = selectableTargets(
        goal: GoalType.lose,
        currentKg: 53,
        heightCm: 165,
      );
      expect(options, [51, 52]);
      final suggestions = suggestTargets(
        goal: GoalType.lose,
        currentKg: 53,
        heightCm: 165,
        today: today,
      );
      expect(suggestions.map((s) => s.targetKg), [51]);
      // 5% of 53 kg rounds to 50 kg, below the floor, so the card is clamped.
      expect(suggestions.single.clamped, isTrue);
    });

    test('offers nothing when already under BMI 18.5', () {
      expect(
        selectableTargets(goal: GoalType.lose, currentKg: 49, heightCm: 165),
        isEmpty,
      );
      expect(
        suggestTargets(goal: GoalType.lose, currentKg: 49, heightCm: 165),
        isEmpty,
      );
    });

    test('classifies a chosen date against NHS/CDC 0.5–1 kg per week', () {
      GoalPace pace(DateTime date) => estimateAdultGoal(
        goal: GoalType.lose,
        currentWeight: 80,
        targetWeight: 72,
        targetDate: date,
        today: today,
      )!.pace;
      // 8 kg in 2 weeks = 4 kg/week.
      expect(pace(DateTime(2026, 1, 15)), GoalPace.tooFast);
      // 8 kg in 12 weeks ≈ 0.67 kg/week.
      expect(pace(DateTime(2026, 3, 26)), GoalPace.common);
      // 8 kg in 30 weeks ≈ 0.27 kg/week.
      expect(pace(DateTime(2026, 7, 30)), GoalPace.gentle);
    });

    test('earliest date respects the lower of 1 kg and 1% per week', () {
      // 1% of 80 kg = 0.8 kg/week, so 8 kg needs 70 days.
      expect(
        earliestSafeDate(
          goal: GoalType.lose,
          currentKg: 80,
          targetKg: 72,
          today: today,
        ),
        DateTime(2026, 3, 12),
      );
      final atLimit = estimateAdultGoal(
        goal: GoalType.lose,
        currentWeight: 80,
        targetWeight: 72,
        targetDate: DateTime(2026, 3, 12),
        today: today,
      )!;
      expect(atLimit.pace, isNot(GoalPace.tooFast));
    });

    test('rejects targets on the wrong side or invalid values', () {
      expect(
        estimateAdultGoal(
          goal: GoalType.lose,
          currentWeight: 60,
          targetWeight: 64,
        ),
        isNull,
      );
      expect(
        estimateAdultGoal(
          goal: GoalType.lose,
          currentWeight: double.nan,
          targetWeight: 50,
        ),
        isNull,
      );
      expect(
        estimateAdultGoal(
          goal: GoalType.maintain,
          currentWeight: 60,
          targetWeight: 58,
        ),
        isNull,
      );
    });
  });

  group('gain', () {
    test('suggests +5%, +7% and +10% capped at BMI 22.9', () {
      final suggestions = suggestTargets(
        goal: GoalType.gain,
        currentKg: 50,
        heightCm: 165,
        today: today,
      );
      expect(suggestions.map((s) => s.targetKg), [53, 54, 55]);
      // 0.25% of 50 kg per week.
      expect(suggestions.first.estimate.rateKgPerWeek, 0.125);
      expect(suggestions.first.estimate.weeks, 24);
      expect(
        selectableTargets(
          goal: GoalType.gain,
          currentKg: 50,
          heightCm: 165,
        ).last,
        // 22.9 × 1.65² = 62.3 kg.
        62,
      );
    });

    test('offers nothing at or above BMI 22.9', () {
      expect(
        suggestTargets(goal: GoalType.gain, currentKg: 62.5, heightCm: 165),
        isEmpty,
      );
    });

    test('flags gain faster than 0.5% of body weight per week', () {
      final estimate = estimateAdultGoal(
        goal: GoalType.gain,
        currentWeight: 50,
        targetWeight: 55,
        targetDate: DateTime(2026, 2, 12),
        today: today,
      )!;
      expect(estimate.pace, GoalPace.tooFast);
    });
  });
}
