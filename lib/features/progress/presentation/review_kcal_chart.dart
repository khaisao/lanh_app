import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/weekly_review.dart';
import 'review_parts.dart';

/// "Kcal 7 ngày": one bar per day against the dashed plan line. Bars within
/// the plan are green, over it peach; an unlogged day is a dotted stub, not
/// a zero bar.
class ReviewKcalChart extends StatelessWidget {
  const ReviewKcalChart({super.key, required this.review});

  final WeeklyReview review;

  static const _height = AppSizes.chart;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final number = NumberFormat.decimalPattern(strings.localeName)
      ..maximumFractionDigits = 0;
    final target = review.target;
    final top = math.max(
      review.kcal.whereType<double>().fold<double>(0, math.max),
      (target ?? 0) * 1.15,
    );
    final scale = top <= 0 ? 0.0 : _height / top;
    final over = review.overDays;
    return ReviewCard(
      key: const Key('review-chart'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReviewCardTitle(
            icon: 'ph-calendar-dots',
            title: strings.reviewChartTitle,
          ),
          const SizedBox(height: AppSpacing.md),
          if (target != null)
            Text(number.format(target), style: AppTypography.micro),
          SizedBox(
            height: _height,
            child: Stack(
              children: [
                if (target != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: target * scale,
                    child: const ExcludeSemantics(child: _DashedLine()),
                  ),
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final kcal in review.kcal)
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: _Bar(
                              height: kcal == null ? null : kcal * scale,
                              over: review.isOver(kcal),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < review.days.length; i++)
                Expanded(
                  child: Semantics(
                    label: strings.reviewChartDay(
                      DateFormat.EEEE(strings.localeName)
                          .format(review.days[i]),
                      review.kcal[i] == null
                          ? strings.reviewNotLogged
                          : '${number.format(review.kcal[i])} kcal',
                    ),
                    excludeSemantics: true,
                    child: Column(
                      children: [
                        Text(
                          strings.dayStripWeekday(
                            review.days[i].weekday.toString(),
                          ),
                          style: AppTypography.micro,
                        ),
                        Text(
                          review.kcal[i] == null
                              ? strings.reviewNotLogged
                              : number.format(review.kcal[i]),
                          textAlign: TextAlign.center,
                          style: AppTypography.micro.copyWith(
                            fontWeight: FontWeight.w700,
                            color: review.isOver(review.kcal[i])
                                ? AppColors.accentForeground
                                : review.kcal[i] == null
                                ? AppColors.mutedForeground
                                : AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (over > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              spacing: AppSpacing.xs,
              children: [
                const AppGradientIconWell(
                  icon: 'ph-info',
                  gradient: [AppColors.accent, AppColors.card],
                  color: AppColors.accentForeground,
                  size: AppSizes.iconTile,
                  iconSize: AppSizes.iconSm,
                ),
                Expanded(
                  child: Text(
                    strings.reviewOverDays(over),
                    key: const Key('review-over-days'),
                    style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.over});

  /// Null for a day without meals.
  final double? height;
  final bool over;

  @override
  Widget build(BuildContext context) {
    final value = height;
    if (value == null) {
      return Container(
        width: AppSpacing.lg,
        height: AppSpacing.xxs,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      );
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: math.max(value, AppSpacing.xxs)),
      duration: AppMotion.of(context, AppMotion.progressFill),
      curve: AppMotion.selectionCurve,
      builder: (context, animated, _) => Container(
        width: AppSpacing.lg,
        height: animated,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadii.pill),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: over
                ? const [AppColors.overTop, AppColors.overBottom]
                : const [AppColors.meterFillEnd, AppColors.primary],
          ),
        ),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 1,
    width: double.infinity,
    child: CustomPaint(painter: _DashPainter()),
  );
}

class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mutedForeground
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(math.min(x + 4, size.width), 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => false;
}
