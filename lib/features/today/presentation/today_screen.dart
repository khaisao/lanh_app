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
import 'package:lanh_app/features/weight/weight.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/today_energy_status.dart';
import 'today_dashboard.dart';
import 'today_day_strip.dart';
import 'today_energy_card.dart';
import 'today_loading_and_error.dart';
import 'today_selected_day.dart';

/// Home: today's kcal against the plan, water and the meal journal, with
/// the loading, read-error and just-saved states of the Sleek Home design.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final savedGoal = ref.watch(profileGoalProvider);
    final target = ref.watch(profileEnergyTargetProvider);
    final justSaved = ref.watch(lastSavedMealProvider);
    final waterGoal = ref.watch(waterGoalGlassesProvider);
    final numberFormat = NumberFormat.decimalPattern(strings.localeName)
      ..maximumFractionDigits = 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = ref.watch(todaySelectedDayProvider);
    final day = picked ?? today;
    final isToday = picked == null;

    final recentMeals = ref.watch(recentMealLogsProvider);
    final mealDays = {
      for (final meal in recentMeals.value ?? const <MealLog>[])
        _localDay(meal.createdAt),
    };
    // Today keeps its own providers (save, delete and water taps refresh
    // them); a past day is a read-only slice of the recent history.
    final mealLogs = isToday
        ? ref.watch(todayMealLogsProvider)
        : recentMeals.whenData(
            (meals) => meals
                .where((meal) => _localDay(meal.createdAt) == day)
                .toList(growable: false),
          );
    final water = isToday
        ? ref.watch(todayWaterProvider)
        : ref.watch(recentWaterProvider).whenData((days) => days[day] ?? 0);

    ref.listen(lastSavedMealProvider, (_, meal) {
      if (meal == null) return;
      // A new meal is always today's, so Home shows the day it landed on.
      ref.read(todaySelectedDayProvider.notifier).showToday();
      _confirmSaved(context, ref, meal, numberFormat);
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
      title: isToday ? strings.today : _dayTitle(strings, day),
      subtitle: isToday ? _dayTitle(strings, day) : null,
      onBackToToday: isToday
          ? null
          : ref.read(todaySelectedDayProvider.notifier).showToday,
      days: TodayDayStrip(
        today: today,
        selected: day,
        mealDays: mealDays,
        onSelect: (value) => ref
            .read(todaySelectedDayProvider.notifier)
            .select(value, today: today),
      ),
      energy: savedGoal.hasError
          ? TodayEnergyErrorCard(
              onRetry: () {
                ref.invalidate(savedProfileProvider);
                ref.invalidate(goalControllerProvider);
              },
            )
          : goalLoading || mealsLoading
          ? const TodayEnergySkeleton()
          : !isToday && !mealLogs.hasError && loggedMeals.isEmpty
          ? const TodayEmptyDayCard()
          : _energy(
              context,
              goal: savedGoal.value?.type,
              target: target,
              total: totalCalories,
              hasCalories: loggedMeals.any((m) => m.totalCalories != null),
              mealsFailed: mealLogs.hasError,
              pastDay: !isToday,
              numberFormat: numberFormat,
            ),
      water: WaterCard(
        key: ValueKey('water-$day'),
        glasses: water.value,
        goal: waterGoal,
        failed: water.hasError && !water.hasValue,
        readOnly: !isToday,
        onAdd: () =>
            _changeWater(context, ref.read(todayWaterProvider.notifier).add),
        onRemove: () =>
            _changeWater(context, ref.read(todayWaterProvider.notifier).remove),
        onRetry: () =>
            ref.invalidate(isToday ? todayWaterProvider : recentWaterProvider),
      ),
      weight: _weight(context, ref, day: day, today: today, isToday: isToday),
      journal: TodayJournal(
        entries: [
          if (mealsLoading)
            const TodayJournalSkeleton()
          else if (mealLogs.hasError)
            TodayJournalErrorCard(
              onRetry: () => ref.invalidate(
                isToday ? todayMealLogsProvider : recentMealLogsProvider,
              ),
              onLog: isToday
                  ? () => unawaited(showMealMethodSheet(context))
                  : null,
            )
          else if (loggedMeals.isEmpty)
            isToday
                ? TodayFirstMealCard(
                    onLog: () => unawaited(showMealMethodSheet(context)),
                  )
                : const TodayNoMealsCard()
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
                      onTap: () => unawaited(
                        showMealDetailSheet(
                          context,
                          loggedMeals[index],
                          canDelete: isToday,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  static DateTime _localDay(DateTime at) {
    final local = at.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// "Thứ Bảy, 21/11" with the first letter capitalised.
  static String _dayTitle(AppLocalizations strings, DateTime day) {
    final text = DateFormat('EEEE, d/M', strings.localeName).format(day);
    return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
  }

  /// The latest weigh-in up to [day]. Before any is logged, the weight from
  /// profile setup stands in, dated the day the goal was saved.
  Widget _weight(
    BuildContext context,
    WidgetRef ref, {
    required DateTime day,
    required DateTime today,
    required bool isToday,
  }) {
    final history = ref.watch(weightHistoryProvider);
    final goal = ref.watch(profileGoalProvider).value;
    final latest = latestWeightOnOrBefore(
      history.value ?? const <WeightEntry>[],
      day,
    );
    final profileDay = goal == null ? null : weightDay(goal.createdAt);
    final useProfile =
        latest == null &&
        goal?.currentWeight != null &&
        profileDay != null &&
        !profileDay.isAfter(day);
    return WeightCard(
      kg: latest?.kg ?? (useProfile ? goal!.currentWeight : null),
      day: latest?.day ?? (useProfile ? profileDay : null),
      today: today,
      failed: history.hasError && !history.hasValue,
      onRetry: () => ref.invalidate(weightHistoryProvider),
      onUpdate: isToday ? () => unawaited(showWeightSheet(context)) : null,
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
    required bool pastDay,
    required NumberFormat numberFormat,
  }) {
    final strings = AppLocalizations.of(context);
    final status = mealsFailed
        ? null
        : TodayEnergyStatus.of(goal: goal, target: target, logged: total);
    if (status != null) {
      return TodayEnergyCard(status: status, pastDay: pastDay);
    }
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
    required VoidCallback onTap,
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
      onTap: onTap,
    );
  }
}
