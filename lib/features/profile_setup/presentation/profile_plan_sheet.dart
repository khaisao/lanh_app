import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/body_metrics.dart';
import '../domain/profile.dart';
import 'profile_activity_step.dart';
import 'profile_setup_widgets.dart';
import 'profile_target_cards.dart';

/// Which variant of the plan sheet to show (Plan Ready, Plan Ready Gain,
/// Plan Ready Maintain and Plan Ready No Kcal in the Sleek project).
enum ProfilePlanKind { lose, gain, maintain, noKcal }

/// What the plan sheet shows. Built from the setup answers; kcal values are
/// already rounded for display and [budgetKcal] is what gets saved.
final class ProfilePlanSummary {
  const ProfilePlanSummary({
    required this.kind,
    required this.goal,
    required this.currentKg,
    required this.activity,
    this.budgetKcal,
    this.bodyKcal,
    this.targetKg,
    this.rateKgPerWeek,
    this.projectedDate,
    this.bmi,
  });

  final ProfilePlanKind kind;
  final GoalType goal;
  final double currentKg;
  final ActivityLevel activity;
  final int? budgetKcal;
  final int? bodyKcal;
  final double? targetKg;
  final double? rateKgPerWeek;
  final DateTime? projectedDate;
  final double? bmi;
}

/// Shows the plan as a modal bottom sheet. Returns true for "Bắt đầu" and
/// false or null for "Chỉnh lại", a drag down or a tap outside.
Future<bool?> showProfilePlanSheet(
  BuildContext context,
  ProfilePlanSummary summary,
) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0x00FFFFFF),
    barrierColor: AppColors.foreground.withValues(alpha: 0.25),
    // Slides up with a little overshoot, as in the export.
    sheetAnimationStyle: reduceMotion
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: AppMotion.planSheet,
            curve: AppMotion.planSheetCurve,
            reverseDuration: AppMotion.feedbackRelease,
          ),
    builder: (context) => ProfilePlanSheet(summary: summary),
  );
}

/// The "Kế hoạch của bạn" sheet: mascot, the daily kcal budget with an
/// energy bar, three icon tiles and Start / Edit. Few words; every part
/// arrives in sequence and Reduce Motion shows the final state at once.
class ProfilePlanSheet extends StatelessWidget {
  const ProfilePlanSheet({super.key, required this.summary});

  final ProfilePlanSummary summary;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final stacked = MediaQuery.textScalerOf(context).scale(12) > 16;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        maxWidth: AppSizes.contentMax,
      ),
      child: _SheetSurface(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.sm,
            AppSpacing.pageHorizontal,
            AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            key: const Key('profile-plan-sheet'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: AppSizes.avatar,
                  height: AppSpacing.stepGap,
                  decoration: BoxDecoration(
                    color: AppColors.mutedForeground.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Center(child: _CelebratingMascot()),
              const SizedBox(height: AppSpacing.sm),
              Text(
                strings.planTitle,
                textAlign: TextAlign.center,
                style: AppTypography.sectionTitle.copyWith(
                  fontFamily: AppFonts.heading,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.card),
              AppEntrance(
                index: 2,
                child: summary.kind == ProfilePlanKind.noKcal
                    ? const _NoKcalCard()
                    : _BudgetCard(summary: summary),
              ),
              const SizedBox(height: AppSpacing.md),
              _Tiles(summary: summary, stacked: stacked),
              const SizedBox(height: AppSpacing.lg),
              AppEntrance(
                index: 6,
                child: AppShineOnce(
                  child: AppButton(
                    key: const Key('profile-plan-start'),
                    fullWidth: true,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context, true);
                    },
                    label: strings.planStart,
                    trailingIcon: 'ph-arrow-right-bold',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.denseGap),
              AppEntrance(
                index: 7,
                child: AppGlassCard(
                  key: const Key('profile-plan-edit'),
                  stadium: true,
                  shadows: const [],
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context, false),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: AppSizes.compactAction,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: AppSpacing.xs,
                      children: [
                        const AppIcon.asset(
                          'ph-arrow-counter-clockwise',
                          size: AppSizes.iconSm,
                          color: AppColors.foreground,
                        ),
                        Flexible(
                          child: Text(
                            strings.planEdit,
                            style: AppTypography.button,
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
    );
  }
}

/// `rounded-t-[2rem] bg-card/85 backdrop-blur-2xl border-card/80` with the
/// upward glass shadow.
class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.vertical(top: Radius.circular(AppRadii.xl));
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Color(0x593B2F25),
            blurRadius: 50,
            spreadRadius: -20,
            offset: Offset(0, -20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppGlass.blurStrong,
            sigmaY: AppGlass.blurStrong,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: MediaQuery.highContrastOf(context)
                  ? AppColors.card
                  : AppColors.card.withValues(alpha: 0.85),
              borderRadius: radius,
              border: const Border(
                top: BorderSide(color: AppGlass.edge),
                left: BorderSide(color: AppGlass.edge),
                right: BorderSide(color: AppGlass.edge),
              ),
            ),
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ),
    );
  }
}

/// Mascot that hops once (rise, overshoot, settle) with twinkling sparkles.
class _CelebratingMascot extends StatefulWidget {
  const _CelebratingMascot();

  @override
  State<_CelebratingMascot> createState() => _CelebratingMascotState();
}

class _CelebratingMascotState extends State<_CelebratingMascot>
    with TickerProviderStateMixin {
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: AppMotion.planMascotHop,
  );
  late final AnimationController _twinkle = AnimationController(
    vsync: this,
    duration: AppMotion.planSparkle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _hop.value = 1;
      _twinkle.stop();
    } else if (_hop.isDismissed) {
      _hop.forward();
      _twinkle.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _hop.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rise = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 12.0, end: -6.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 45),
    ]).animate(CurvedAnimation(parent: _hop, curve: Curves.easeOut));
    final scale = Tween(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _hop, curve: Curves.easeOutBack));
    Widget spark(double size, Color color, double phase) => AnimatedBuilder(
      animation: _twinkle,
      builder: (context, child) {
        final t = (_twinkle.value + phase) % 1;
        final glow = 0.45 + 0.55 * math.sin(t * math.pi);
        return Opacity(
          opacity: glow,
          child: Transform.scale(scale: 0.8 + 0.2 * glow, child: child),
        );
      },
      child: AppIcon.asset('ph-sparkle-fill', size: size, color: color),
    );
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: AppSizes.planMascot,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _hop,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, rise.value),
                child: Transform.scale(scale: scale.value, child: child),
              ),
              child: const AppMascot(size: AppSizes.planMascot),
            ),
            Positioned(
              top: -4,
              left: 4,
              child: spark(16, AppColors.chartGold, 0),
            ),
            Positioned(
              top: 0,
              right: -8,
              child: spark(12, AppColors.chartPeach, 0.4),
            ),
            Positioned(
              bottom: 8,
              left: -12,
              child: spark(10, AppColors.chartPeach, 0.7),
            ),
            Positioned(
              bottom: -4,
              right: 0,
              child: spark(14, AppColors.chartGold, 0.2),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Mỗi ngày nên nạp" budget: the number counts up and the energy bar fills.
/// Loss: green "Nạp" of the body's use plus a striped "Bớt". Gain: the body's
/// use plus a gold "Thêm". Maintain: a full bar equal to the body's use.
class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.summary});

  final ProfilePlanSummary summary;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final format = NumberFormat.decimalPattern(strings.localeName);
    final budget = summary.budgetKcal!;
    final body = summary.bodyKcal!;
    final delta = (budget - body).abs();
    final kind = summary.kind;
    final animate = !MediaQuery.disableAnimationsOf(context);
    // Share of the bar drawn in primary: what to eat out of the body's use
    // (loss), the body's use out of the budget (gain), all of it (maintain).
    final fill = switch (kind) {
      ProfilePlanKind.lose => body == 0 ? 1.0 : budget / body,
      ProfilePlanKind.gain => budget == 0 ? 1.0 : body / budget,
      _ => 1.0,
    }.clamp(0.0, 1.0);
    final label = AppTypography.micro.copyWith(fontWeight: FontWeight.w600);
    return Semantics(
      key: const Key('profile-plan-budget'),
      container: true,
      label:
          '${strings.planDailyLabel} ${format.format(budget)} kcal, ${strings.profileEstimate}',
      child: AppGlassCard(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSpacing.stepGap,
                    children: [
                      const AppIcon.asset(
                        'ph-bowl-food',
                        size: AppSizes.iconXs,
                        color: AppColors.accentForeground,
                      ),
                      Flexible(
                        child: Text(
                          strings.planDailyLabel,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _EstimatePill(text: strings.profileEstimate),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ExcludeSemantics(
              child: TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: animate ? 0 : budget.toDouble(),
                  end: budget.toDouble(),
                ),
                duration: animate ? AppMotion.planCount : Duration.zero,
                curve: const Interval(0.25, 1, curve: Curves.easeOutCubic),
                builder: (context, value, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: AppSpacing.stepGap,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          format.format(value.round()),
                          key: const Key('profile-plan-kcal'),
                          style: AppTypography.numericHero.copyWith(
                            height: 1,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'kcal',
                      style: AppTypography.cardTitle.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (kind == ProfilePlanKind.lose)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  strings.planBodyUsesApprox(format.format(body)),
                  style: label.copyWith(color: AppColors.mutedForeground),
                ),
              ),
            const SizedBox(height: AppSpacing.xxs),
            _EnergyBar(fill: fill, kind: kind, animate: animate),
            const SizedBox(height: AppSpacing.xs),
            if (kind == ProfilePlanKind.maintain)
              Text(
                strings.planMatchesBody,
                textAlign: TextAlign.center,
                style: label.copyWith(color: AppColors.primary),
              )
            else
              Row(
                spacing: AppSpacing.sm,
                children: [
                  Expanded(
                    child: Text(
                      kind == ProfilePlanKind.lose
                          ? strings.planEat(format.format(budget))
                          : strings.planBodyUses(format.format(body)),
                      style: label.copyWith(color: AppColors.primary),
                    ),
                  ),
                  Text(
                    kind == ProfilePlanKind.lose
                        ? strings.planCut(format.format(delta))
                        : strings.planAdd(format.format(delta)),
                    style: label.copyWith(color: AppColors.accentForeground),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _EstimatePill extends StatelessWidget {
  const _EstimatePill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.secondary,
      borderRadius: BorderRadius.circular(AppRadii.pill),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.navLabelGap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xxs,
        children: [
          const AppIcon.asset(
            'ph-info',
            size: AppSizes.iconXs - 4,
            color: AppColors.secondaryForeground,
          ),
          Flexible(
            child: Text(
              text,
              style: AppTypography.micro.copyWith(
                color: AppColors.secondaryForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// The 12 dp energy bar. The primary part grows from zero; the rest is a
/// striped peach "cut" (loss) or a soft gold "add" (gain).
class _EnergyBar extends StatelessWidget {
  const _EnergyBar({
    required this.fill,
    required this.kind,
    required this.animate,
  });

  final double fill;
  final ProfilePlanKind kind;
  final bool animate;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: SizedBox(
        height: AppSpacing.sm,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (kind == ProfilePlanKind.lose)
              const CustomPaint(painter: _StripePainter())
            else
              ColoredBox(
                color: kind == ProfilePlanKind.gain
                    ? AppColors.chartGold.withValues(alpha: 0.4)
                    : AppColors.muted,
              ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: animate ? 0 : fill, end: fill),
              duration: animate ? AppMotion.planBar : Duration.zero,
              curve: const Interval(0.3, 1, curve: Curves.easeOutCubic),
              builder: (context, value, _) => FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: value,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadii.pill),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// `bg-chart-4/30` with 45° accent stripes (3 px on, 4 px off).
class _StripePainter extends CustomPainter {
  const _StripePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.chartPeach.withValues(alpha: 0.3),
    );
    final stripe = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3;
    for (var x = -size.height; x < size.width + size.height; x += 7) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        stripe,
      );
    }
  }

  @override
  bool shouldRepaint(_StripePainter oldDelegate) => false;
}

/// Teens: no kcal number, a calm explanation instead.
class _NoKcalCard extends StatelessWidget {
  const _NoKcalCard();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AppGlassCard(
      key: const Key('profile-plan-no-kcal'),
      padding: const EdgeInsets.all(AppSpacing.card),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          // `size-12` circle with a 24 px leaf.
          const ProfileIconCircle(
            icon: 'ph-leaf',
            background: AppColors.secondary,
            color: AppColors.primary,
            dimension: AppSizes.choiceIcon,
            iconSize: AppSizes.iconLg,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xxs,
              children: [
                Text(
                  strings.planNoKcalTitle,
                  style: AppTypography.cardTitle.copyWith(
                    fontFamily: AppFonts.heading,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(strings.planNoKcalTeen, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Three icon tiles that rise in one after another.
class _Tiles extends StatelessWidget {
  const _Tiles({required this.summary, required this.stacked});

  final ProfilePlanSummary summary;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final kg = NumberFormat.decimalPattern(strings.localeName)
      ..maximumFractionDigits = 1;
    final rate = NumberFormat.decimalPattern(strings.localeName)
      ..minimumFractionDigits = 2
      ..maximumFractionDigits = 2;
    final activity = switch (summary.activity) {
      ActivityLevel.sitting => strings.profileActivityShortSitting,
      ActivityLevel.light => strings.profileActivityShortLight,
      ActivityLevel.moderate => strings.profileActivityShortModerate,
      ActivityLevel.heavy => strings.profileActivityShortHeavy,
      ActivityLevel.variable => strings.profileActivityShortVariable,
    };
    const goalTone = (AppColors.secondary, AppColors.primary);
    final goldTone = (
      AppColors.chartGold.withValues(alpha: 0.25),
      AppColors.accentForeground,
    );
    final blueTone = (
      AppColors.chartBlue.withValues(alpha: 0.25),
      AppColors.foreground,
    );
    final tiles = <(String, (Color, Color), String, String)>[
      ...switch (summary.kind) {
        ProfilePlanKind.lose || ProfilePlanKind.gain => [
          (
            'ph-flag-checkered',
            goalTone,
            '${kg.format(summary.targetKg)} kg',
            strings.planTileTarget,
          ),
          (
            'ph-gauge',
            goldTone,
            '${rate.format(roundRate(summary.rateKgPerWeek!))} kg',
            strings.planTilePerWeek,
          ),
          (
            'ph-calendar-check',
            blueTone,
            DateFormat.yMd(strings.localeName).format(summary.projectedDate!),
            strings.planTileDue,
          ),
        ],
        ProfilePlanKind.maintain => [
          (
            'ph-scales',
            goalTone,
            '${kg.format(summary.currentKg)} kg',
            strings.planTileHold,
          ),
          (
            ProfileActivityStep.icon(summary.activity),
            goldTone,
            activity,
            strings.planTileActivity,
          ),
          (
            'ph-heart',
            blueTone,
            summary.bmi == null ? 'BMI —' : 'BMI ${kg.format(summary.bmi)}',
            switch (summary.bmi) {
              null => strings.planTileBmi,
              final bmi => switch (adultBmiCategory(bmi)) {
                AdultBmiCategory.underweight => strings.planBmiShortUnderweight,
                AdultBmiCategory.healthy => strings.planBmiShortHealthy,
                AdultBmiCategory.overweight => strings.planBmiShortOverweight,
                AdultBmiCategory.obesity => strings.planBmiShortObesity,
              },
            },
          ),
        ],
        ProfilePlanKind.noKcal => [
          (
            'ph-target',
            goalTone,
            switch (summary.goal) {
              GoalType.gain => strings.profileGain,
              GoalType.lose => strings.profileLose,
              _ => strings.profileMaintain,
            },
            strings.planTileGoal,
          ),
          (
            'ph-scales',
            goldTone,
            '${kg.format(summary.currentKg)} kg',
            strings.planTileNow,
          ),
          (
            ProfileActivityStep.icon(summary.activity),
            blueTone,
            activity,
            strings.planTileActivity,
          ),
        ],
      },
    ];
    final children = [
      for (final (index, (icon, tone, value, label)) in tiles.indexed)
        AppEntrance(
          index: 3 + index,
          child: _Tile(
            key: Key('profile-plan-tile-$index'),
            icon: icon,
            background: tone.$1,
            color: tone.$2,
            value: value,
            label: label,
          ),
        ),
    ];
    if (stacked) {
      return Column(spacing: AppSpacing.xs, children: children);
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.xs,
        children: [for (final tile in children) Expanded(child: tile)],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.icon,
    required this.background,
    required this.color,
    required this.value,
    required this.label,
  });

  final String icon;
  final Color background;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: AppGlassCard(
        radius: AppRadii.glassInner,
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProfileIconCircle(icon: icon, background: background, color: color),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: AppTypography.cardTitle.copyWith(
                  fontFamily: AppFonts.heading,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.micro.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
