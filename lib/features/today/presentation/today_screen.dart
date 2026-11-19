import 'dart:async';
import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    final mealLogs = ref.watch(todayMealLogsProvider);
    final goal = savedGoal.value?.type;
    final loading = savedGoal.isLoading;
    final failed = savedGoal.hasError;
    final loggedMeals = mealLogs.asData?.value ?? const <MealLog>[];
    final totalCalories = loggedMeals
        .map((meal) => meal.totalCalories)
        .whereType<double>()
        .fold<double>(0, (sum, value) => sum + value);
    final hasCalories = loggedMeals.any((meal) => meal.totalCalories != null);
    final numberFormat = NumberFormat.decimalPattern(strings.localeName)
      ..maximumFractionDigits = 0;

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
        value: hasCalories
            ? numberFormat.format(totalCalories)
            : strings.todayNoEnergy,
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
          if (mealLogs.isLoading) ...[
            const TodayCard(child: Center(child: CircularProgressIndicator())),
          ] else if (mealLogs.hasError) ...[
            TodayCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xs,
                children: [
                  Text(
                    strings.todayMealReadError,
                    style: AppTypography.bodySmall,
                  ),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      TextButton(
                        onPressed: () => ref.invalidate(todayMealLogsProvider),
                        child: Text(strings.retry),
                      ),
                      AppButton.secondary(
                        onPressed: () =>
                            unawaited(showMealMethodSheet(context)),
                        child: Text(strings.logMeal),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (loggedMeals.isEmpty) ...[
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
          ] else ...[
            TodayCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var index = 0; index < loggedMeals.length; index++) ...[
                    if (index > 0)
                      const Divider(
                        height: 1,
                        indent: AppSpacing.md,
                        endIndent: AppSpacing.md,
                      ),
                    _mealRow(context, loggedMeals[index], numberFormat),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _mealRow(
    BuildContext context,
    MealLog meal,
    NumberFormat numberFormat,
  ) {
    final strings = AppLocalizations.of(context);
    final imagePath = meal.imagePath;
    final photo = imagePath == null || !File(imagePath).existsSync()
        ? null
        : FileImage(File(imagePath));
    final energy = meal.totalCalories == null
        ? '${strings.mealReviewUnknown} ${strings.mealReviewKcal}'
        : '${numberFormat.format(meal.totalCalories)} ${strings.mealReviewKcal}';
    final time = DateFormat.Hm(strings.localeName)
        .format(meal.createdAt.toLocal());
    return TodayMealRow(
      name: meal.items.length == 1
          ? meal.items.single.name
          : meal.items.map((item) => item.name).join(', '),
      time: time,
      energy: energy,
      photo: photo,
    );
  }
}
