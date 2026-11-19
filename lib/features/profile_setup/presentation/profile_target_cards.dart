import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/energy_estimate.dart';
import '../domain/goal_policy.dart';

/// Rounds a kg/week rate to two decimals, half up. The epsilon absorbs
/// binary error, so 0.145 shows as 0,15 rather than 0,14.
double roundRate(double value) => (value * 100 + 1e-9).roundToDouble() / 100;

/// Locale formatting shared by the Target step.
final class ProfileTargetFormat {
  ProfileTargetFormat(this.strings)
    : _kg = NumberFormat.decimalPattern(strings.localeName)
        ..maximumFractionDigits = 1,
      _rate = NumberFormat.decimalPattern(strings.localeName)
        ..minimumFractionDigits = 2
        ..maximumFractionDigits = 2,
      _whole = NumberFormat.decimalPattern(strings.localeName)
        ..maximumFractionDigits = 0,
      _date = DateFormat.yMd(strings.localeName);

  final AppLocalizations strings;
  final NumberFormat _kg;
  final NumberFormat _whole;
  final NumberFormat _rate;
  final DateFormat _date;

  String kg(double value) => _kg.format(value);
  String rate(double value) => _rate.format(roundRate(value));
  String date(DateTime value) => _date.format(value);

  /// A kcal value rounded for display.
  String kcal(double value) => _whole.format(roundKcal(value));

  String percent(double current, double target) =>
      ((target - current).abs() / current * 100).round().toString();

  String delta(double current, double target) => kg((target - current).abs());
}

/// Plan card from Profile Setup Target: glass when idle, solid primary with a
/// check when chosen.
class ProfileTargetPlanCard extends StatelessWidget {
  const ProfileTargetPlanCard({
    super.key,
    required this.title,
    required this.suggestion,
    required this.selected,
    required this.format,
    required this.onPressed,
  });

  final String title;
  final TargetSuggestion suggestion;
  final bool selected;
  final ProfileTargetFormat format;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // Text and icons cross-fade with the card's glass → primary fill.
      tween: Tween(end: selected ? 1 : 0),
      duration: AppMotion.of(context, AppMotion.selection),
      curve: AppMotion.selectionCurve,
      builder: (context, t, _) => _build(
        Color.lerp(AppColors.foreground, AppColors.primaryForeground, t)!,
      ),
    );
  }

  Widget _build(Color foreground) {
    final strings = format.strings;
    final estimate = suggestion.estimate;
    final soft = foreground.withValues(alpha: 0.8);
    final rate = strings.profileTargetRateApprox(
      format.rate(estimate.rateKgPerWeek),
    );
    final weeks = strings.profileTargetWeeksShort(estimate.weeks);
    final date = strings.profileEstimateDate(
      format.date(estimate.projectedDate),
    );
    final kcal = estimate.dailyKcal == null
        ? null
        : strings.profileTargetDailyKcal(format.kcal(estimate.dailyKcal!));
    final stat = AppTypography.label.copyWith(color: foreground);
    Widget item(String icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.stepGap,
      children: [
        AppIcon.asset(icon, size: AppSizes.iconXs, color: foreground),
        Flexible(child: Text(text, style: stat)),
      ],
    );
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      excludeSemantics: true,
      label:
          '$title, ${format.kg(suggestion.targetKg)} kg, $rate, $weeks, $date${kcal == null ? '' : ', $kcal'}',
      child: Stack(
        children: [
          AppGlassCard(
            tone: selected ? AppGlassTone.primary : AppGlassTone.glass,
            onPressed: () {
              if (!selected) HapticFeedback.selectionClick();
              onPressed();
            },
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.card,
              AppSpacing.card,
              AppSizes.action,
              AppSpacing.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.label.copyWith(
                    color: soft,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: AppSpacing.xs,
                  children: [
                    Text(
                      format.kg(suggestion.targetKg),
                      style: AppTypography.numericHero.copyWith(
                        color: foreground,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      'kg',
                      style: AppTypography.cardTitle.copyWith(color: soft),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    item('ph-gauge', rate),
                    item('ph-hourglass-medium', weeks),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    item('ph-calendar-check', date),
                    if (kcal != null) item('ph-fire', kcal),
                  ],
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: AppSpacing.card,
            end: AppSpacing.card,
            child: IgnorePointer(
              child: AppRadioMark(selected: selected, inverse: true),
            ),
          ),
        ],
      ),
    );
  }
}

/// Solid primary summary card (`bg-primary shadow-lg shadow-primary/25`).
class ProfilePrimaryCard extends StatelessWidget {
  const ProfilePrimaryCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AppGlassCard(
    tone: AppGlassTone.primary,
    padding: const EdgeInsets.all(AppSpacing.card),
    child: DefaultTextStyle.merge(
      style: const TextStyle(color: AppColors.primaryForeground),
      child: child,
    ),
  );
}

/// Horizontal whole-kilogram chips inside a glass card.
class ProfileTargetKgPicker extends StatefulWidget {
  const ProfileTargetKgPicker({
    super.key,
    required this.label,
    required this.helper,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String helper;
  final List<int> options;
  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  State<ProfileTargetKgPicker> createState() => _ProfileTargetKgPickerState();
}

class _ProfileTargetKgPickerState extends State<ProfileTargetKgPicker> {
  static const _chipExtent =
      AppSizes.avatarLarge + AppSpacing.xs + AppSpacing.xs;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    final index = widget.selected == null
        ? widget.options.length - 1
        : widget.options.indexOf(widget.selected!);
    _scroll = ScrollController(
      initialScrollOffset:
          (index - 2).clamp(0, widget.options.length) * _chipExtent,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chipHeight = MediaQuery.textScalerOf(context).scale(AppSizes.action);
    // The chip row runs edge to edge inside the card, so chips scroll out
    // under the card's rounded edge instead of being cut inside its padding,
    // and leaves room above and below for the chosen chip's lift.
    const lift = AppSpacing.xxs;
    const inset = EdgeInsets.symmetric(horizontal: AppSpacing.card);
    return AppGlassCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.card),
      child: Semantics(
        label: widget.label,
        explicitChildNodes: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm - lift,
          children: [
            Padding(
              padding: inset,
              child: Text(widget.label, style: AppTypography.label),
            ),
            SizedBox(
              height: chipHeight + lift * 2,
              child: ListView.separated(
                key: const Key('profile-target-kg-picker'),
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                padding: inset.copyWith(top: lift, bottom: lift),
                itemCount: widget.options.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final kg = widget.options[index];
                  final selected = kg == widget.selected;
                  return Semantics(
                    checked: selected,
                    inMutuallyExclusiveGroup: true,
                    button: true,
                    label: '$kg kg',
                    excludeSemantics: true,
                    // The chosen chip lifts slightly; Material animates its
                    // fill and outline.
                    child: AnimatedScale(
                      scale: selected ? 1.06 : 1,
                      duration: AppMotion.of(context, AppMotion.selectionPop),
                      curve: Curves.easeOutBack,
                      child: Material(
                        key: Key('profile-target-kg-$kg'),
                        animationDuration: AppMotion.of(
                          context,
                          AppMotion.selection,
                        ),
                        color: selected ? AppColors.primary : AppGlass.recessed,
                        shape: AppSquircleBorder(
                          radius: AppRadii.glassInner,
                          side: BorderSide(
                            color: selected ? AppColors.primary : AppGlass.edge,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            if (!selected) HapticFeedback.selectionClick();
                            widget.onSelected(kg);
                          },
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: AppSizes.avatarLarge + AppSpacing.xs,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: AppMotion.of(
                                    context,
                                    AppMotion.selection,
                                  ),
                                  style: AppTypography.sectionTitle.copyWith(
                                    color: selected
                                        ? AppColors.primaryForeground
                                        : AppColors.foreground,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                  child: Text('$kg'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: inset,
              child: Text(widget.helper, style: AppTypography.caption),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Ước tính kế hoạch" card: pace, duration and a pace verdict.
class ProfilePlanEstimateCard extends StatelessWidget {
  const ProfilePlanEstimateCard({
    super.key,
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
    final verdict = switch (estimate?.pace) {
      GoalPace.gentle => strings.profilePaceGentle,
      GoalPace.common =>
        goal == GoalType.lose
            ? strings.profilePaceCommonLose
            : strings.profilePaceCommonGain,
      GoalPace.tooFast => strings.profilePaceTooFast,
      null => strings.profileTargetCustomEmpty,
    };
    final onPrimary = AppColors.primaryForeground;
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: onPrimary.withValues(alpha: 0.8),
                height: 20 / 14,
              ),
            ),
          ),
          Flexible(
            child: AppRollingText(
              value,
              alignment: AlignmentDirectional.centerEnd,
              textAlign: TextAlign.end,
              style: AppTypography.bodySmall.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w700,
                height: 20 / 14,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
    return Semantics(
      key: const Key('profile-plan-estimate'),
      container: true,
      child: ProfilePrimaryCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.profilePlanEstimateTitle,
                    style: AppTypography.cardTitle.copyWith(
                      fontFamily: AppFonts.heading,
                      fontWeight: FontWeight.w700,
                      color: onPrimary,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: onPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.denseGap,
                      vertical: AppSpacing.navLabelGap,
                    ),
                    child: Text(
                      strings.profileEstimate,
                      style: AppTypography.micro.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: ShapeDecoration(
                color: onPrimary.withValues(alpha: 0.1),
                shape: const AppSquircleBorder(radius: AppRadii.glassInner),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    row(
                      strings.profilePlanRate,
                      estimate == null
                          ? '—'
                          : strings.profileTargetRateApprox(
                              format.rate(estimate.rateKgPerWeek),
                            ),
                    ),
                    Divider(
                      height: AppBorders.hairline,
                      color: onPrimary.withValues(alpha: 0.2),
                    ),
                    row(
                      strings.profilePlanDuration,
                      estimate == null
                          ? '—'
                          : strings.profilePlanDurationValue(estimate.weeks),
                    ),
                    if (estimate?.dailyKcal case final kcal?) ...[
                      Divider(
                        height: AppBorders.hairline,
                        color: onPrimary.withValues(alpha: 0.2),
                      ),
                      row(
                        strings.profilePlanDailyKcal,
                        strings.profileEnergyValue(format.kcal(kcal)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              verdict,
              key: const Key('profile-plan-verdict'),
              style: AppTypography.label.copyWith(color: onPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              strings.profileEstimateCaption,
              style: AppTypography.micro.copyWith(
                color: onPrimary.withValues(alpha: 0.8),
                height: 1.625,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
