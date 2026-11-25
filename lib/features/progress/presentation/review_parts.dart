import 'package:app_ui/app_ui.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/weekly_review.dart';

/// The glass card every Nhìn lại block sits on, as on Home.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.fill,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? fill;

  @override
  Widget build(BuildContext context) => AppGlassCard(
    padding: padding,
    radius: AppRadii.glassInner,
    shadows: AppShadows.glassCard,
    fill: fill,
    child: child,
  );
}

class ReviewCardTitle extends StatelessWidget {
  const ReviewCardTitle({super.key, required this.icon, required this.title});

  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    spacing: AppSpacing.sm,
    children: [
      AppGradientIconWell(
        icon: icon,
        gradient: [AppColors.secondary, AppColors.card],
        color: AppColors.primary,
        size: AppSizes.iconTile,
        iconSize: AppSizes.iconSm,
      ),
      Expanded(
        child: Semantics(
          header: true,
          child: Text(title, style: AppTypography.cardTitle),
        ),
      ),
    ],
  );
}

class ReviewErrorCard extends StatelessWidget {
  const ReviewErrorCard({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ReviewCard(
      key: const Key('review-error'),
      child: Row(
        children: [
          Expanded(
            child: Text(
              strings.reviewReadError,
              style: AppTypography.bodySmall,
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(strings.retry)),
        ],
      ),
    );
  }
}

/// Fewer than three logged days: how many more are needed.
class ReviewThinCard extends StatelessWidget {
  const ReviewThinCard({super.key, required this.review});

  final WeeklyReview review;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ReviewCard(
      key: const Key('review-thin'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          ReviewCardTitle(
            icon: 'ph-plant',
            title: strings.reviewMoreDays(review.daysToAnalysis),
          ),
          ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                value: review.loggedDays / reviewDays,
                minHeight: AppSpacing.xs,
                backgroundColor: AppColors.muted,
                color: AppColors.primary,
              ),
            ),
          ),
          Text(
            strings.reviewLoggedOf(review.loggedDays, reviewDays),
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

/// The week's answer to the goal, from the first and last weigh-in.
class ReviewVerdictCard extends StatelessWidget {
  const ReviewVerdictCard({super.key, required this.review});

  final WeeklyReview review;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final goal = switch (review.goal) {
      ReviewGoal.lose => strings.reviewGoalLose,
      ReviewGoal.gain => strings.reviewGoalGain,
      ReviewGoal.maintain => strings.reviewGoalMaintain,
      ReviewGoal.none => strings.reviewGoalNone,
    };
    final (icon, background, foreground, title) = switch (review.verdict) {
      ReviewVerdict.onTrack => (
        switch (review.goal) {
          ReviewGoal.gain => 'ph-plant',
          ReviewGoal.maintain => 'ph-scales',
          _ => 'ph-leaf',
        },
        AppColors.secondary,
        AppColors.primary,
        strings.reviewOnTrack,
      ),
      ReviewVerdict.offTrack => (
        'ph-info',
        AppColors.accent,
        AppColors.accentForeground,
        strings.reviewOffTrack,
      ),
      ReviewVerdict.unknown => (
        'ph-scales',
        AppColors.secondary,
        AppColors.primary,
        strings.reviewNoTrend,
      ),
    };
    return ReviewCard(
      key: Key('review-verdict-${review.verdict.name}'),
      fill: review.verdict == ReviewVerdict.onTrack
          ? AppColors.secondary.withValues(alpha: .6)
          : null,
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          AppGradientIconWell(
            icon: icon,
            gradient: [background, AppColors.card],
            color: foreground,
            size: AppSizes.iconTile,
            iconSize: AppSizes.iconSm,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(title, style: AppTypography.cardTitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Four numbers of the week: weight, kcal, logged days and water.
class ReviewStatGrid extends StatelessWidget {
  const ReviewStatGrid({super.key, required this.review});

  final WeeklyReview review;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final whole = NumberFormat.decimalPattern(strings.localeName)
      ..maximumFractionDigits = 0;
    final tenth = NumberFormat.decimalPatternDigits(
      locale: strings.localeName,
      decimalDigits: 1,
    );
    final weight = review.latestWeight;
    final kcal = review.averageKcal;
    final water = review.averageWater;
    final target = review.target;
    final overAverage = kcal != null && review.isOver(kcal);
    final tiles = [
      _StatTile(
        key: const Key('review-stat-weight'),
        icon: 'ph-scales',
        label: strings.weightTitle,
        value: weight == null ? strings.reviewNoData : tenth.format(weight.kg),
        unit: weight == null ? null : strings.weightUnit,
        caption: strings.reviewWeighIns(review.weights.length),
      ),
      _StatTile(
        key: const Key('review-stat-kcal'),
        icon: 'ph-fire',
        background: overAverage ? AppColors.accent : AppColors.energyTint,
        foreground: overAverage ? AppColors.accentForeground : AppColors.energy,
        label: strings.reviewKcal,
        value: kcal == null ? strings.reviewNoData : whole.format(kcal),
        unit: kcal == null ? null : 'kcal',
        caption: target == null
            ? strings.todayTargetUnavailable
            : strings.reviewPlan(whole.format(target)),
        meter: kcal == null || target == null || target <= 0
            ? null
            : kcal / target,
      ),
      _StatTile(
        key: const Key('review-stat-days'),
        icon: 'ph-calendar-check',
        label: strings.reviewLoggedDays,
        value: '${review.loggedDays}/$reviewDays',
        caption: strings.reviewEnough,
      ),
      _StatTile(
        key: const Key('review-stat-water'),
        icon: 'ph-drop',
        background: AppColors.waterTint,
        foreground: AppColors.waterDeep,
        label: strings.reviewWater,
        value: water == null ? strings.reviewNoData : tenth.format(water),
        unit: water == null ? null : strings.reviewGlasses,
        caption: water == null
            ? strings.reviewNoWater
            : strings.reviewWaterDays(review.waterGoalDays, review.waterDays),
        glasses: water == null || review.waterGoal == null
            ? null
            : (filled: water.round(), goal: review.waterGoal!),
      ),
    ];
    return Column(
      spacing: AppSpacing.sm,
      children: [
        for (var row = 0; row < tiles.length; row += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.sm,
              children: [
                Expanded(child: tiles[row]),
                Expanded(child: tiles[row + 1]),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    this.unit,
    this.meter,
    this.glasses,
    this.background = AppColors.secondary,
    this.foreground = AppColors.primary,
  });

  final String icon;
  final String label;
  final String value;
  final String? unit;
  final String caption;

  /// Logged against the plan; above 1 the rest of the bar turns peach.
  final double? meter;

  /// Average glasses against the goal, drawn as a row of dots.
  final ({int filled, int goal})? glasses;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final ratio = meter;
    return ReviewCard(
      child: Semantics(
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: AppSpacing.xs,
              children: [
                AppGradientIconWell(
                  icon: icon,
                  gradient: [background, AppColors.card],
                  color: foreground,
                  size: AppSizes.iconTile,
                  iconSize: AppSizes.iconSm,
                ),
                Expanded(child: Text(label, style: AppTypography.caption)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: value, style: AppTypography.metricValue),
                  if (unit case final text?)
                    TextSpan(text: ' $text', style: AppTypography.caption),
                ],
              ),
            ),
            Text(caption, style: AppTypography.caption),
            if (glasses case final row?) ...[
              const SizedBox(height: AppSpacing.xs),
              ExcludeSemantics(
                child: Row(
                  key: const Key('review-water-dots'),
                  spacing: AppSpacing.xxs,
                  children: [
                    for (var i = 0; i < row.goal; i++)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < row.filled
                              ? AppColors.waterDeep
                              : AppColors.border,
                        ),
                        child: const SizedBox.square(
                          dimension: AppSpacing.stepGap,
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (ratio != null) ...[
              const SizedBox(height: AppSpacing.xs),
              ExcludeSemantics(child: _PlanMeter(ratio: ratio)),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanMeter extends StatelessWidget {
  const _PlanMeter({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    final within = ratio > 1 ? 1 / ratio : ratio;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: SizedBox(
        height: AppSpacing.stepGap,
        child: Row(
          key: const Key('review-plan-meter'),
          // Stretch so the coloured parts take the bar's height.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: (within * 1000).round().clamp(1, 1000),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.meterFillEnd],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: ((1 - within) * 1000).round().clamp(0, 1000),
              child: ColoredBox(
                color: ratio > 1 ? AppColors.accent : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Đáng chú ý": patterns of the week. The MVP knows the weekend gap only;
/// food-type findings need the meal API to classify dishes.
class ReviewFindings extends StatelessWidget {
  const ReviewFindings({super.key, required this.review});

  final WeeklyReview review;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final number = NumberFormat.decimalPattern(strings.localeName)
      ..maximumFractionDigits = 0;
    final weekend = review.weekendGap;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Semantics(
          header: true,
          child: Text(strings.reviewNotable, style: AppTypography.sectionTitle),
        ),
        ReviewCard(
          key: const Key('review-findings'),
          child: weekend == null
              ? Text(strings.reviewNothing, style: AppTypography.bodySmall)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.sm,
                  children: [
                    const AppGradientIconWell(
                      icon: 'ph-calendar-dots',
                      gradient: [AppColors.energyTint, AppColors.card],
                      color: AppColors.energy,
                      size: AppSizes.iconTile,
                      iconSize: AppSizes.iconSm,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.reviewWeekend(number.format(weekend.gap)),
                            key: const Key('review-weekend'),
                            style: AppTypography.cardTitle,
                          ),
                          Text(
                            strings.reviewWeekendTip,
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
