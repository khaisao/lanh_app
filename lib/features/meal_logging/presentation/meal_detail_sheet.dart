import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/meal_log.dart';
import '../meal_logging_providers.dart';

/// Opens the saved-meal sheet (Sleek "Sheet · Phân tích món"). [canDelete]
/// is false on past days, which Home shows read-only.
Future<void> showMealDetailSheet(
  BuildContext context,
  MealLog meal, {
  required bool canDelete,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: AppColors.card,
  barrierColor: AppColors.modalBarrier,
  constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
  shape: const RoundedRectangleBorder(
    side: BorderSide(color: AppColors.border),
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
  ),
  sheetAnimationStyle: AnimationStyle(
    duration: AppMotion.duration(context),
    reverseDuration: AppMotion.duration(context),
  ),
  builder: (_) => MealDetailSheet(meal: meal, canDelete: canDelete),
);

/// Share of a meal's energy from protein, carbohydrate and fat (4/4/9 kcal
/// per gram), or null when any of the three is unknown or all are zero.
({double protein, double carbohydrate, double fat})? mealEnergySplit(
  MealLog meal,
) {
  final protein = meal.totalProtein;
  final carbohydrate = meal.totalCarbohydrate;
  final fat = meal.totalFat;
  if (protein == null || carbohydrate == null || fat == null) return null;
  final total = protein * 4 + carbohydrate * 4 + fat * 9;
  if (total <= 0) return null;
  return (
    protein: protein * 4 / total,
    carbohydrate: carbohydrate * 4 / total,
    fat: fat * 9 / total,
  );
}

class MealDetailSheet extends ConsumerStatefulWidget {
  const MealDetailSheet({
    super.key,
    required this.meal,
    required this.canDelete,
  });

  final MealLog meal;
  final bool canDelete;

  @override
  ConsumerState<MealDetailSheet> createState() => _MealDetailSheetState();
}

class _MealDetailSheetState extends ConsumerState<MealDetailSheet> {
  bool _deleting = false;

  Future<void> _delete() async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.mealDeleteTitle),
        actions: [
          TextButton(
            key: const Key('meal-delete-cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          TextButton(
            key: const Key('meal-delete-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.destructive),
            child: Text(strings.mealDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _deleting) return;
    setState(() => _deleting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(mealLogRepositoryProvider).delete(widget.meal.id);
      ref.invalidate(todayMealLogsProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      messenger.showSnackBar(SnackBar(content: Text(strings.mealDeleteError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final meal = widget.meal;
    final kcal = meal.totalCalories;
    final number = NumberFormat.decimalPattern(strings.localeName)
      ..maximumFractionDigits = 0;
    final local = meal.createdAt.toLocal();
    final when =
        '${DateFormat('EEEE d/M', strings.localeName).format(local)}'
        ' · ${DateFormat.Hm(strings.localeName).format(local)}';
    final split = mealEnergySplit(meal);
    return SingleChildScrollView(
      key: const Key('meal-detail-sheet'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    meal.names.join(', '),
                    style: AppTypography.title,
                  ),
                ),
              ),
              AppNavigationButton.close(
                key: const Key('meal-detail-close'),
                tooltip: strings.close,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xxs,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(
                kcal == null ? strings.mealReviewUnknown : number.format(kcal),
                key: const Key('meal-detail-kcal'),
                style: AppTypography.numericHero,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  strings.mealReviewKcal,
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
          Text(when, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.xxs,
              children: [
                const AppIcon.asset(
                  'ph-sparkle',
                  size: AppSizes.iconXs,
                  color: AppColors.foreground,
                ),
                Flexible(
                  child: Text(
                    strings.mealDetailEstimated,
                    style: AppTypography.label,
                  ),
                ),
              ],
            ),
          ),
          if (split != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _EnergySplit(split: split),
          ],
          if (widget.canDelete) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(color: AppColors.border),
            Center(
              child: TextButton(
                key: const Key('meal-delete'),
                onPressed: _deleting ? null : _delete,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.destructive,
                  minimumSize: const Size(
                    AppSizes.readableWidth / 2,
                    AppSizes.compactAction,
                  ),
                ),
                child: Text(strings.mealDelete),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EnergySplit extends StatelessWidget {
  const _EnergySplit({required this.split});

  final ({double protein, double carbohydrate, double fat}) split;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final parts = [
      (strings.mealProtein, split.protein, AppColors.protein),
      (strings.mealCarbohydrate, split.carbohydrate, AppColors.chartGold),
      (strings.mealFat, split.fat, AppColors.chartPeach),
    ];
    final percent = NumberFormat.percentPattern(strings.localeName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Row(
          children: [
            for (final (label, share, color) in parts)
              Expanded(
                child: Semantics(
                  label: '$label ${percent.format(share)}',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        percent.format(share),
                        style: AppTypography.metricValue,
                      ),
                      Row(
                        spacing: AppSpacing.xxs,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox.square(
                              dimension: AppSpacing.xs,
                            ),
                          ),
                          Flexible(
                            child: Text(label, style: AppTypography.caption),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        ExcludeSemantics(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: SizedBox(
              height: AppSpacing.xs,
              child: Row(
                key: const Key('meal-energy-bar'),
                // Stretch so the colour boxes take the bar's height.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (_, share, color) in parts)
                    if (share > 0)
                      Expanded(
                        flex: (share * 1000).round().clamp(1, 1000),
                        child: ColoredBox(color: color),
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
