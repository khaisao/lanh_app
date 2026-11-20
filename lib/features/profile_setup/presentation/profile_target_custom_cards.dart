import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/goal_policy.dart';
import 'profile_setup_widgets.dart';
import 'profile_target_cards.dart';

/// "Cân nặng mong muốn" from Profile Setup Target Custom: the chosen weight
/// and a half-kilogram slider between − and + buttons. [options] are the
/// healthy targets for the goal, ascending.
class ProfileTargetWeightCard extends StatelessWidget {
  const ProfileTargetWeightCard({
    super.key,
    required this.kg,
    required this.options,
    required this.format,
    required this.onChanged,
  });

  final double kg;
  final List<double> options;
  final ProfileTargetFormat format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = format.strings;
    final index = options.indexOf(kg);
    void select(int next) {
      if (next == index || next < 0 || next >= options.length) return;
      HapticFeedback.selectionClick();
      onChanged(options[next]);
    }

    return AppGlassCard(
      key: const Key('profile-target-weight'),
      strokeWidth: AppChoice.strokeWidth,
      padding: const EdgeInsets.all(AppSpacing.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.sm,
            children: [
              Expanded(
                child: Text(
                  strings.profileTargetWeight,
                  style: AppTypography.label,
                ),
              ),
              // The slider announces the value; with a single option there
              // is no slider, so the value is read here instead.
              ExcludeSemantics(
                excluding: options.length > 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: AppSpacing.xxs,
                  children: [
                    AppRollingText(
                      format.kg(kg),
                      key: const Key('profile-target-custom-value'),
                      style: AppTypography.numericLarge.copyWith(
                        color: AppColors.primary,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      'kg',
                      style: AppTypography.sectionTitle.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              AppGlassIconButton(
                key: const Key('profile-target-decrease'),
                icon: 'ph-minus-bold',
                tooltip: strings.profileTargetDecrease,
                color: AppColors.foreground,
                iconSize: AppSizes.iconSm,
                onPressed: index > 0 ? () => select(index - 1) : null,
              ),
              Expanded(
                child: options.length < 2
                    ? const SizedBox.shrink()
                    : Semantics(
                        label: strings.profileTargetWeight,
                        child: Slider(
                          key: const Key('profile-target-slider'),
                          value: kg,
                          min: options.first,
                          max: options.last,
                          divisions: options.length - 1,
                          semanticFormatterCallback: (value) =>
                              '${format.kg(value)} kg',
                          onChanged: (value) =>
                              select(options.indexOf(_snap(value))),
                        ),
                      ),
              ),
              AppGlassIconButton(
                key: const Key('profile-target-increase'),
                icon: 'ph-plus-bold',
                tooltip: strings.profileTargetIncrease,
                color: AppColors.foreground,
                iconSize: AppSizes.iconSm,
                onPressed: index < options.length - 1
                    ? () => select(index + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Rounds a slider position to the nearest half kilogram.
  static double _snap(double value) =>
      (value / WeightPlanPolicy.targetStepKg).round() *
      WeightPlanPolicy.targetStepKg;
}

/// The second custom card: the "Hẹn ngày đạt mục tiêu" switch, the chosen
/// date when on, and the plan estimate for the current choices.
class ProfileTargetTimingCard extends StatelessWidget {
  const ProfileTargetTimingCard({
    super.key,
    required this.goal,
    required this.date,
    required this.dateMoved,
    required this.estimate,
    required this.format,
    required this.onDateEnabled,
    required this.onPickDate,
  });

  final GoalType goal;

  /// The deadline, or null when the switch is off.
  final DateTime? date;
  final bool dateMoved;
  final GoalEstimate? estimate;
  final ProfileTargetFormat format;
  final ValueChanged<bool> onDateEnabled;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final strings = format.strings;
    final date = this.date;
    return AppGlassCard(
      strokeWidth: AppChoice.strokeWidth,
      padding: const EdgeInsets.all(AppSpacing.card),
      // The date row opens and closes smoothly with the switch.
      child: AppAnimatedSize(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MergeSemantics(
              child: InkWell(
                key: const Key('profile-target-date-switch'),
                borderRadius: BorderRadius.circular(AppRadii.md),
                onTap: () => onDateEnabled(date == null),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppSizes.action),
                  // `gap-2` here (not the card's `gap-3`) keeps the label on
                  // one line on 360 dp phones beside the 60 dp switch.
                  child: Row(
                    spacing: AppSpacing.xs,
                    children: [
                      const AppIconWell(icon: 'ph-calendar-blank'),
                      Expanded(
                        child: Text(
                          strings.profileTargetSetDate,
                          style: AppTypography.choiceTitle,
                        ),
                      ),
                      Switch(
                        value: date != null,
                        onChanged: onDateEnabled,
                        // The whole 56 dp row is the touch target, so the
                        // switch needs no padded height of its own.
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (date != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _DateRow(
                label: strings.profileTargetDate,
                date: format.date(date),
                onTap: onPickDate,
              ),
              if (dateMoved)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      strings.profileTargetDateMoved,
                      key: const Key('profile-target-date-moved'),
                      style: AppTypography.caption,
                    ),
                  ),
                ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.card),
              child: Divider(
                height: AppBorders.hairline,
                color: AppColors.border,
              ),
            ),
            _Estimate(goal: goal, estimate: estimate, format: format),
          ],
        ),
      ),
    );
  }
}

/// `min-h-14 rounded-2xl bg-secondary/60` row: tap anywhere to change the date.
class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.date,
    required this.onTap,
  });

  /// Spoken name of the row ("Ngày muốn đạt").
  final String label;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$label, $date',
    excludeSemantics: true,
    // Excluding the InkWell's semantics drops its tap; re-expose it.
    onTap: onTap,
    child: Material(
      key: const Key('profile-target-date'),
      color: AppColors.secondary.withValues(alpha: 0.6),
      shape: const AppSquircleBorder(
        radius: AppRadii.glassInner,
        side: BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.action),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              spacing: AppSpacing.sm,
              children: [
                const AppIcon.asset(
                  'ph-calendar-check',
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    date,
                    style: AppTypography.cardTitle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const AppIcon.asset(
                  'ph-caret-right',
                  size: AppSizes.iconSm,
                  color: AppColors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// "Ước tính kế hoạch": weekly change, weeks needed and the daily budget as
/// three tinted rows. Missing values read "—".
class _Estimate extends StatelessWidget {
  const _Estimate({
    required this.goal,
    required this.estimate,
    required this.format,
  });

  final GoalType goal;
  final GoalEstimate? estimate;
  final ProfileTargetFormat format;

  @override
  Widget build(BuildContext context) {
    final strings = format.strings;
    final estimate = this.estimate;
    final sign = goal == GoalType.lose ? '−' : '+';
    final kcal = estimate?.dailyKcal;
    return Semantics(
      key: const Key('profile-plan-estimate'),
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.xs,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              strings.profilePlanEstimateTitle,
              style: AppTypography.sectionTitle,
            ),
          ),
          _EstimateRow(
            key: const Key('profile-estimate-rate'),
            tint: AppColors.chartBlue,
            icon: 'ph-gauge',
            label: strings.profileTargetPerWeek,
            value: estimate == null
                ? null
                : '$sign${format.rate(estimate.rateKgPerWeek)}',
            unit: 'kg',
          ),
          _EstimateRow(
            key: const Key('profile-estimate-weeks'),
            tint: AppColors.chartGold,
            icon: 'ph-hourglass-medium',
            label: strings.profileTargetNeeds,
            value: estimate == null ? null : '${estimate.weeks}',
            unit: strings.profileUnitWeeks,
          ),
          _EstimateRow(
            key: const Key('profile-estimate-kcal'),
            tint: AppColors.accent,
            icon: 'ph-bowl-food',
            label: strings.profileTargetEatPerDay,
            value: kcal == null ? null : format.kcal(kcal),
            unit: 'kcal',
          ),
        ],
      ),
    );
  }
}

/// One estimate row: `min-h-14 rounded-2xl` tinted with [tint], an icon
/// circle, the label and the value with its unit on the right.
class _EstimateRow extends StatelessWidget {
  const _EstimateRow({
    super.key,
    required this.tint,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final Color tint;
  final String icon;
  final String label;
  final String? value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return MergeSemantics(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: tint.withValues(alpha: 0.15),
          shape: AppSquircleBorder(
            radius: AppRadii.glassInner,
            side: BorderSide(color: tint.withValues(alpha: 0.3)),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.action),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              spacing: AppSpacing.sm,
              children: [
                ProfileIconCircle(
                  icon: icon,
                  background: AppColors.card.withValues(alpha: 0.8),
                  color: AppColors.foreground,
                ),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.fieldLabel.copyWith(
                      color: AppColors.foreground.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                // Shrinks rather than overflowing on narrow or large-text
                // screens.
                Flexible(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: value == null
                          ? Text(
                              '—',
                              style: AppTypography.metricValue.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              spacing: AppSpacing.xxs,
                              children: [
                                AppRollingText(
                                  value,
                                  style: AppTypography.metricValue,
                                ),
                                Text(
                                  unit,
                                  style: AppTypography.choiceTitle.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
