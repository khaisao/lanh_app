import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'today_dashboard.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final savedGoal = ref.watch(profileGoalProvider);
    final goal = savedGoal.value?.type;
    final loading = savedGoal.isLoading;
    final failed = savedGoal.hasError;

    final heading = switch (goal) {
      GoalType.gain => strings.todayGainGoal,
      GoalType.lose => strings.todayLosePlan,
      GoalType.maintain => strings.todayMaintainRange,
      GoalType.logOnly || null => strings.todayEnergy,
    };
    final hint = switch (goal) {
      GoalType.gain || GoalType.lose => strings.todayTargetUnavailable,
      GoalType.maintain => strings.todayRangeUnavailable,
      _ => strings.todayEmptyBody,
    };

    return TodayDashboard(
      energy: TodayEnergyCard(
        mode: goal,
        heading: heading,
        value: strings.todayNoEnergy,
        footer: loading
            ? strings.todayLoadingProfile
            : failed
            ? strings.todayProfileReadError
            : hint,
        action: failed
            ? TextButton(
                onPressed: () {
                  ref.invalidate(savedProfileProvider);
                  ref.invalidate(goalControllerProvider);
                },
                child: Text(strings.retry),
              )
            : !loading && goal == null
            ? TextButton(
                onPressed: () => context.push('/profile-setup'),
                child: Text(strings.profileGoal),
              )
            : null,
      ),
      water: TodayWaterCard(value: strings.todayNoWater),
      journal: TodayJournal(
        entries: [
          TodayCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                Text(strings.todayNoMeals, style: AppTypography.bodySmall),
                AppButton.secondary(
                  onPressed: () => unawaited(showMealMethodSheet(context)),
                  child: Text(strings.logMeal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
