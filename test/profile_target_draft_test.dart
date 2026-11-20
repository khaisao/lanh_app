import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/goal/domain/goal.dart';
import 'package:lanh_app/features/profile_setup/domain/goal_policy.dart';
import 'package:lanh_app/features/profile_setup/presentation/profile_target_draft.dart';

void main() {
  DateTime earliest(double targetKg) => earliestSafeDate(
    goal: GoalType.lose,
    currentKg: 62.5,
    targetKg: targetKg,
  );

  ProfileTargetDraft custom(double kg, DateTime date) => ProfileTargetDraft(
    mode: ProfileTargetMode.custom,
    customKg: kg,
    timing: ProfileTargetTiming.date,
    date: date,
  );

  DateTime? deadline(ProfileTargetDraft draft) =>
      draft.deadline(goal: GoalType.lose, currentKg: 62.5);

  group('deadline', () {
    test('moves past a picked day that is too soon for the target', () {
      expect(deadline(custom(55, earliest(58))), earliest(55));
    });

    test('keeps a reachable day as picked', () {
      final later = earliest(55).add(const Duration(days: 30));
      expect(deadline(custom(55, later)), later);
    });

    test('returns to the picked day when the target comes back', () {
      final picked = earliest(58);
      final draft = custom(55, picked);
      expect(deadline(draft), earliest(55));
      expect(deadline(draft.copyWith(customKg: () => 58)), picked);
    });

    test('is null while the switch is off or in suggested mode', () {
      final draft = custom(55, earliest(55));
      expect(
        deadline(draft.copyWith(timing: ProfileTargetTiming.none)),
        isNull,
      );
      expect(
        deadline(draft.copyWith(mode: ProfileTargetMode.suggested)),
        isNull,
      );
    });
  });

  group('reconcile', () {
    ProfileTargetDraft reconcile(
      ProfileTargetDraft draft, {
      required GoalType goal,
      required double currentKg,
    }) => draft.reconcile(goal: goal, currentKg: currentKg, heightCm: 160);

    test('starts the custom target at Lành’s first plan', () {
      final draft = reconcile(
        const ProfileTargetDraft(),
        goal: GoalType.lose,
        currentKg: 62.5,
      );
      // 5% of 62.5 kg rounds to 59 kg.
      expect(draft.suggestedKg, 59);
      expect(draft.customKg, 59);
    });

    test('replaces a custom target the new body values rule out', () {
      // 61.5 kg was valid at 62.5 kg; at 60 kg the plan restarts at 57 kg.
      final draft = reconcile(
        const ProfileTargetDraft(customKg: 61.5),
        goal: GoalType.lose,
        currentKg: 60,
      );
      expect(draft.customKg, 57);
    });

    test('keeps a custom target that is still valid', () {
      final draft = reconcile(
        const ProfileTargetDraft(customKg: 55.5),
        goal: GoalType.lose,
        currentKg: 60,
      );
      expect(draft.customKg, 55.5);
    });

    test('a one-step gain range uses its only target', () {
      // 22.9 × 1.60² = 58.6 kg: from 58.2 kg the only targets are 58.5 kg.
      final draft = reconcile(
        const ProfileTargetDraft(),
        goal: GoalType.gain,
        currentKg: 58.2,
      );
      expect(
        selectableTargets(goal: GoalType.gain, currentKg: 58.2, heightCm: 160),
        [58.5],
      );
      expect(draft.customKg, 58.5);
    });
  });
}
