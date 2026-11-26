import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/today_energy_status.dart';
import 'today_dashboard.dart';

/// Home kcal card from the Sleek Home 01–11 screens: goal icon well, the
/// logged kcal against the plan, a flat read-only meter and one status line.
/// The meter has no thumb or marker, so it never reads as a slider.
class TodayEnergyCard extends StatefulWidget {
  const TodayEnergyCard({
    super.key,
    required this.status,
    this.pastDay = false,
  });

  final TodayEnergyStatus status;

  /// A finished past day: the status reads as a result, not "còn … hôm nay".
  final bool pastDay;

  @override
  State<TodayEnergyCard> createState() => _TodayEnergyCardState();
}

class _TodayEnergyCardState extends State<TodayEnergyCard> {
  @override
  void didUpdateWidget(TodayEnergyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A meal that completes the plan gets a short tap; opening Home on an
    // already complete day does not.
    if (!widget.pastDay &&
        !oldWidget.status.state.isDone &&
        widget.status.state.isDone) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final format = NumberFormat.decimalPattern(strings.localeName);
    final status = widget.status;
    String kcal(int value) => format.format(value);
    final (goalIcon, goalLabel) = switch (status.goal) {
      GoalType.gain => ('ph-plant', strings.todayGoalGain),
      GoalType.lose => ('ph-leaf', strings.todayGoalLose),
      _ => ('ph-scales', strings.todayGoalMaintain),
    };
    final range = status.range;
    final rangeText = range == null
        ? null
        : '${kcal(range.lower)}–${kcal(range.upper)}';
    final sentence = widget.pastDay
        ? _pastSentence(strings, status, kcal)
        : switch (status.state) {
            TodayEnergyState.gainBelow => strings.todayGainLeft(
              kcal(status.remaining),
            ),
            TodayEnergyState.gainReached => strings.todayGainReached,
            TodayEnergyState.loseWithin => strings.todayLoseLeft(
              kcal(status.remaining),
            ),
            TodayEnergyState.loseAtPlan => strings.todayLoseAtPlan,
            TodayEnergyState.loseOver => strings.todayLoseOver(
              kcal(status.over),
            ),
            TodayEnergyState.maintainBelow => strings.todayMaintainBelow(
              // Word joiners keep "920–1.320" on one line.
              '${kcal(status.gapToRange.lower)}⁠–⁠'
              '${kcal(status.gapToRange.upper)}',
            ),
            TodayEnergyState.maintainWithin => strings.todayMaintainWithin,
            TodayEnergyState.maintainAbove => strings.todayMaintainAbove(
              kcal(status.over),
            ),
          };
    return TodayCard(
      key: ValueKey('today-energy-${status.goal.name}'),
      padding: const EdgeInsets.all(AppSpacing.card),
      radius: AppRadii.glassInner,
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TodayEnergyHeader(icon: goalIcon, label: goalLabel, estimated: true),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xxs,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              AppRollingText(
                kcal(status.logged),
                key: const Key('today-energy-value'),
                style: AppTypography.numericLarge,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.stepGap),
                child: Text(
                  range == null
                      ? strings.todayOfTarget(kcal(status.target))
                      : strings.todayKcal,
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ExcludeSemantics(child: TodayEnergyMeter(status: status)),
          if (rangeText != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _RangeLabel(
              zone: status.zone!,
              text: strings.todayMaintainRangeLabel(rangeText),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _StatusRow(state: status.state, sentence: sentence),
        ],
      ),
    );
  }
}

String _pastSentence(
  AppLocalizations strings,
  TodayEnergyStatus status,
  String Function(int) kcal,
) => switch (status.state) {
  TodayEnergyState.gainBelow => strings.dayGainBelow(kcal(status.remaining)),
  TodayEnergyState.gainReached => strings.dayGainReached,
  TodayEnergyState.loseWithin => strings.dayLoseWithin(kcal(status.remaining)),
  TodayEnergyState.loseAtPlan => strings.dayLoseAtPlan,
  TodayEnergyState.loseOver => strings.dayLoseOver(kcal(status.over)),
  TodayEnergyState.maintainBelow => strings.dayMaintainBelow,
  TodayEnergyState.maintainWithin => strings.todayMaintainWithin,
  TodayEnergyState.maintainAbove => strings.dayMaintainAbove(kcal(status.over)),
};

/// Goal icon well, label and the "Ước tính" chip shared by every Home kcal
/// card variant, including the plan-less and error cards.
class TodayEnergyHeader extends StatelessWidget {
  const TodayEnergyHeader({
    super.key,
    required this.label,
    this.icon,
    this.estimated = false,
    this.warning = false,
  });

  final String label;
  final String? icon;
  final bool estimated;

  /// Uses the warm accent well (read errors).
  final bool warning;

  @override
  Widget build(BuildContext context) => Row(
    spacing: AppSpacing.sm,
    children: [
      if (icon case final name?)
        ExcludeSemantics(
          child: SizedBox.square(
            dimension: AppSizes.energyIconWell,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                gradient: AppGradients.well(
                  warning ? AppColors.accent : AppColors.secondary,
                ),
                shape: const AppSquircleBorder(
                  radius: AppRadii.glassInner,
                  side: BorderSide(color: AppMenu.wellEdge),
                ),
              ),
              child: Center(
                child: AppIcon.asset(
                  name,
                  size: AppSizes.iconMd,
                  color: warning
                      ? AppColors.accentForeground
                      : AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      Expanded(
        // Label left, chip right; the chip drops below at large text sizes
        // instead of pushing the row over.
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xxs,
          children: [
            Semantics(
              header: true,
              child: Text(
                label,
                style: AppTypography.fieldLabel.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (estimated)
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppRadii.pill),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.denseGap,
                    vertical: AppSpacing.navLabelGap,
                  ),
                  child: Text(
                    AppLocalizations.of(context).todayEstimated,
                    style: AppTypography.micro.copyWith(
                      color: AppColors.accentForeground,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

/// Flat `h-3` meter: a muted track, the green gradient fill, a warm overrun
/// segment past the plan, and for maintain the range painted on the track
/// (striped while below, solid once inside). Fill and overrun grow from 0 on
/// first build and animate between values; Reduce Motion draws them at once.
class TodayEnergyMeter extends StatelessWidget {
  const TodayEnergyMeter({super.key, required this.status});

  final TodayEnergyStatus status;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.todayMeter);
    final zone = status.zone;
    final meter = SizedBox(
      key: const Key('today-energy-meter'),
      height: AppSizes.energyMeter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFE6DECD), AppColors.muted],
                        stops: [0, .4],
                      ),
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: status.overflowEnd ?? 0),
                  duration: duration,
                  curve: AppMotion.todayMeterCurve,
                  builder: (context, end, _) => end <= status.fill
                      ? const SizedBox.shrink()
                      : Positioned(
                          key: const Key('today-energy-overrun'),
                          left: 0,
                          width: width * end,
                          top: 0,
                          bottom: 0,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(AppRadii.pill),
                              ),
                            ),
                          ),
                        ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: status.fill),
                  duration: duration,
                  curve: AppMotion.todayMeterCurve,
                  builder: (context, fill, _) => Positioned(
                    key: const Key('today-energy-fill'),
                    left: 0,
                    width: width * fill,
                    top: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.meterFillEnd],
                        ),
                        borderRadius: status.overflowEnd == null
                            ? BorderRadius.circular(AppRadii.pill)
                            : const BorderRadius.horizontal(
                                left: Radius.circular(AppRadii.pill),
                              ),
                        border: const Border(
                          top: BorderSide(color: Color(0x59FFFFFF)),
                        ),
                      ),
                    ),
                  ),
                ),
                // Drawn last and translucent so the range stays visible
                // over the fill, as in Sleek Home 10–11.
                if (zone != null)
                  Positioned(
                    key: const Key('today-energy-zone'),
                    left: width * zone.$1,
                    width: width * (zone.$2 - zone.$1),
                    top: 0,
                    bottom: 0,
                    child: status.state == TodayEnergyState.maintainWithin
                        ? ColoredBox(
                            color: AppColors.primary.withValues(alpha: .4),
                          )
                        : const CustomPaint(painter: _ZoneStripes()),
                  ),
              ],
            ),
          );
        },
      ),
    );
    // The plan just met: one light sweep after the fill settles.
    return status.state.isDone
        ? AppShineOnce(
            key: ValueKey('today-energy-shine-${status.state.name}'),
            duration: AppMotion.planShine,
            delayFraction: .35,
            child: meter,
          )
        : meter;
  }
}

/// The maintain range drawn flat on the track: diagonal primary stripes.
class _ZoneStripes extends CustomPainter {
  const _ZoneStripes();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.primary.withValues(alpha: .18),
    );
    final stripe = Paint()
      ..color = AppColors.primary.withValues(alpha: .35)
      ..strokeWidth = 4;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (var x = -size.height; x < size.width + size.height; x += 8) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        stripe,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ZoneStripes oldDelegate) => false;
}

class _RangeLabel extends StatelessWidget {
  const _RangeLabel({required this.zone, required this.text});

  final (double, double) zone;
  final String text;

  @override
  Widget build(BuildContext context) => Align(
    // Centres under the range while staying inside the card.
    alignment: Alignment((zone.$1 + zone.$2) - 1, 0),
    child: Text(
      text,
      key: const Key('today-energy-range'),
      style: AppTypography.label.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    ),
  );
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.state, required this.sentence});

  final TodayEnergyState state;
  final String sentence;

  @override
  Widget build(BuildContext context) {
    final (icon, background, foreground) = state.isDone
        ? ('ph-check-bold', AppColors.primary, AppColors.primaryForeground)
        : state.isOver
        ? ('ph-info-bold', AppColors.accent, AppColors.accentForeground)
        : state == TodayEnergyState.loseWithin
        ? ('ph-check-bold', AppColors.secondary, AppColors.primary)
        : ('ph-target', AppColors.secondary, AppColors.primary);
    return Row(
      spacing: AppSpacing.denseGap,
      children: [
        ExcludeSemantics(
          child: AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.selection),
            width: AppSizes.energyStatusIcon,
            height: AppSizes.energyStatusIcon,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcon.asset(
                icon,
                key: ValueKey('today-energy-status-$icon'),
                size: AppSizes.iconXs,
                color: foreground,
              ),
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.selection),
            layoutBuilder: (current, previous) => Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [...previous, ?current],
            ),
            child: Text(
              sentence,
              key: ValueKey(sentence),
              style: AppTypography.fieldLabel.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The kcal card when there is no plan to measure against (log-only, no
/// goal, or no kcal target yet). Not part of the Home design, which assumes
/// every user has a plan; kept so older profiles still read correctly.
class TodayEnergyPlainCard extends StatelessWidget {
  const TodayEnergyPlainCard({
    super.key,
    required this.label,
    required this.value,
    required this.footer,
    this.unit,
    this.action,
  });

  final String label;
  final String value;
  final String? unit;
  final String footer;
  final Widget? action;

  @override
  Widget build(BuildContext context) => TodayCard(
    key: const ValueKey('today-energy-plain'),
    padding: const EdgeInsets.all(AppSpacing.card),
    radius: AppRadii.glassInner,
    raised: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.md,
      children: [
        TodayEnergyHeader(label: label),
        Wrap(
          spacing: AppSpacing.xxs,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(value, style: AppTypography.numericLarge),
            if (unit case final text?)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.stepGap),
                child: Text(text, style: AppTypography.bodySmall),
              ),
          ],
        ),
        Text(footer, style: AppTypography.bodySmall),
        ?action,
      ],
    ),
  );
}
