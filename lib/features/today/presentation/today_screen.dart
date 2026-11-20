import 'dart:async';
import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/features/water/water.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/today_energy_status.dart';
import 'today_dashboard.dart';
import 'today_energy_card.dart';
import 'today_loading_and_error.dart';

/// Home: today's kcal against the plan, water and the meal journal, with
/// the loading, read-error and just-saved states of the Sleek Home design.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final savedGoal = ref.watch(profileGoalProvider);
    final target = ref.watch(profileEnergyTargetProvider);
    final mealLogs = ref.watch(todayMealLogsProvider);
    final justSaved = ref.watch(lastSavedMealProvider);
    final water = ref.watch(todayWaterProvider);
    final waterGoal = ref.watch(waterGoalGlassesProvider);
    final numberFormat = NumberFormat.decimalPattern(strings.localeName)
      ..maximumFractionDigits = 0;

    ref.listen(lastSavedMealProvider, (_, meal) {
      if (meal != null) _confirmSaved(context, ref, meal, numberFormat);
    });

    // A refresh keeps the previous value, so saving a meal never flashes
    // the placeholders; only a first read shows them.
    final mealsLoading = !mealLogs.hasValue && !mealLogs.hasError;
    final goalLoading = !savedGoal.hasValue && !savedGoal.hasError;
    final loggedMeals = mealLogs.value ?? const <MealLog>[];
    final totalCalories = loggedMeals
        .map((meal) => meal.totalCalories)
        .whereType<double>()
        .fold<double>(0, (sum, value) => sum + value);

    return TodayDashboard(
      energy: savedGoal.hasError
          ? TodayEnergyErrorCard(
              onRetry: () {
                ref.invalidate(savedProfileProvider);
                ref.invalidate(goalControllerProvider);
              },
            )
          : goalLoading || mealsLoading
          ? const TodayEnergySkeleton()
          : _energy(
              context,
              goal: savedGoal.value?.type,
              target: target,
              total: totalCalories,
              hasCalories: loggedMeals.any((m) => m.totalCalories != null),
              mealsFailed: mealLogs.hasError,
              numberFormat: numberFormat,
            ),
      water: WaterCard(
        glasses: water.value,
        goal: waterGoal,
        failed: water.hasError && !water.hasValue,
        onAdd: () =>
            _changeWater(context, ref.read(todayWaterProvider.notifier).add),
        onRemove: () =>
            _changeWater(context, ref.read(todayWaterProvider.notifier).remove),
        onRetry: () => ref.invalidate(todayWaterProvider),
      ),
      journal: TodayJournal(
        entries: [
          if (mealsLoading)
            const TodayJournalSkeleton()
          else if (mealLogs.hasError)
            TodayJournalErrorCard(
              onRetry: () => ref.invalidate(todayMealLogsProvider),
              onLog: () => unawaited(showMealMethodSheet(context)),
            )
          else if (loggedMeals.isEmpty)
            TodayFirstMealCard(
              onLog: () => unawaited(showMealMethodSheet(context)),
            )
          else
            TodayCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var index = 0; index < loggedMeals.length; index++) ...[
                    if (index > 0)
                      const Divider(
                        height: AppBorders.hairline,
                        thickness: AppBorders.hairline,
                        color: AppColors.border,
                        indent: AppSpacing.md,
                        endIndent: AppSpacing.md,
                      ),
                    _mealRow(
                      context,
                      loggedMeals[index],
                      numberFormat,
                      highlighted: loggedMeals[index].id == justSaved?.id,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Runs a water change; the count is already restored when it fails.
  void _changeWater(BuildContext context, Future<void> Function() change) {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).waterSaveError;
    change().catchError((Object _) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    });
  }

  Widget _energy(
    BuildContext context, {
    required GoalType? goal,
    required int? target,
    required double total,
    required bool hasCalories,
    required bool mealsFailed,
    required NumberFormat numberFormat,
  }) {
    final strings = AppLocalizations.of(context);
    final status = mealsFailed
        ? null
        : TodayEnergyStatus.of(goal: goal, target: target, logged: total);
    if (status != null) return TodayEnergyCard(status: status);
    // Outside the designed Home: no plan, or the journal could not be read.
    return TodayEnergyPlainCard(
      label: switch (goal) {
        GoalType.gain => strings.todayGoalGain,
        GoalType.lose => strings.todayGoalLose,
        GoalType.maintain => strings.todayGoalMaintain,
        GoalType.logOnly || null => strings.todayEnergy,
      },
      value: hasCalories && !mealsFailed
          ? numberFormat.format(total)
          : strings.todayNoEnergy,
      unit: strings.todayLoggedKcal,
      footer: mealsFailed
          ? strings.todayMealReadError
          : switch (goal) {
              GoalType.gain || GoalType.lose => strings.todayTargetUnavailable,
              GoalType.maintain => strings.todayRangeUnavailable,
              _ => strings.todayEmptyBody,
            },
      action: goal == null && !mealsFailed
          ? TextButton(
              onPressed: () => context.push('/profile-setup'),
              child: Text(strings.profileGoal),
            )
          : null,
    );
  }

  /// Sleek Home 14: a short glass pill above the dock names the saved meal;
  /// its row is highlighted until the pill closes.
  void _confirmSaved(
    BuildContext context,
    WidgetRef ref,
    MealLog meal,
    NumberFormat numberFormat,
  ) {
    final strings = AppLocalizations.of(context);
    final name = _mealName(meal);
    final kcal = meal.totalCalories;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger
        .showSnackBar(
          SnackBar(
            key: const Key('today-saved-toast'),
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            backgroundColor: AppColors.card,
            shape: const StadiumBorder(
              side: BorderSide(color: AppColors.glassEdge),
            ),
            margin: EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              0,
              AppSpacing.gutter,
              // Just above the floating dock; the Scaffold already sits
              // inside the safe area.
              AppSizes.nav + AppSpacing.navBottom + AppSpacing.sm,
            ),
            content: Row(
              spacing: AppSpacing.xs,
              children: [
                const ExcludeSemantics(
                  child: AppIcon.asset(
                    'ph-check-circle-fill',
                    size: AppSizes.iconSm,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: Text(
                    kcal == null
                        ? strings.todaySavedMealNoKcal(name)
                        : strings.todaySavedMeal(
                            name,
                            numberFormat.format(kcal),
                          ),
                    style: AppTypography.fieldLabel.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .closed
        .then((_) {
          // Only clear the meal this pill was about.
          final notifier = ref.read(lastSavedMealProvider.notifier);
          if (ref.read(lastSavedMealProvider)?.id == meal.id) notifier.clear();
        });
  }

  static String _mealName(MealLog meal) => meal.items.length == 1
      ? meal.items.single.name
      : meal.items.map((item) => item.name).join(', ');

  Widget _mealRow(
    BuildContext context,
    MealLog meal,
    NumberFormat numberFormat, {
    required bool highlighted,
  }) {
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
      key: ValueKey('today-meal-${meal.id}'),
      name: _mealName(meal),
      time: time,
      energy: energy,
      photo: photo,
      highlighted: highlighted,
    );
  }
}
