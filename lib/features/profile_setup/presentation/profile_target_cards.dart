import 'package:app_ui/app_ui.dart';
import 'package:intl/intl.dart';
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
}

/// Plan card from Profile Setup Target: the shared choice card with the
/// target weight (`font-heading text-2xl`) over its weeks and expected date.
/// Screen readers also hear the plan name, pace and daily kcal.
class ProfileTargetPlanCard extends StatelessWidget {
  const ProfileTargetPlanCard({
    super.key,
    required this.icon,
    required this.title,
    required this.suggestion,
    required this.selected,
    required this.format,
    required this.onPressed,
  });

  final String icon;
  final String title;
  final TargetSuggestion suggestion;
  final bool selected;
  final ProfileTargetFormat format;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = format.strings;
    final estimate = suggestion.estimate;
    final kg = '${format.kg(suggestion.targetKg)} kg';
    final rate = strings.profileTargetRateApprox(
      format.rate(estimate.rateKgPerWeek),
    );
    final weeks = strings.profileTargetWeeksShort(estimate.weeks);
    final date = format.date(estimate.projectedDate);
    final kcal = estimate.dailyKcal == null
        ? null
        : strings.profileTargetDailyKcal(format.kcal(estimate.dailyKcal!));
    Widget meta(String icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        AppIcon.asset(
          icon,
          size: AppSizes.iconMeta,
          color: AppColors.mutedForeground,
        ),
        Flexible(child: Text(text, style: AppTypography.label)),
      ],
    );
    return AppSelectionTile.custom(
      icon: icon,
      selected: selected,
      onPressed: onPressed,
      semanticLabel: [
        title,
        kg,
        rate,
        weeks,
        strings.profileEstimateDate(date),
        ?kcal,
      ].join(', '),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.stepGap,
        children: [
          Text(kg, style: AppTypography.setupNumber.copyWith(height: 1)),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: [
              meta('ph-clock', weeks),
              meta('ph-calendar-blank', date),
            ],
          ),
        ],
      ),
    );
  }
}
