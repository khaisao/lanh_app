import 'package:app_ui/app_ui.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Seven-day strip under the Home title (Sleek "Hôm nay"): the last six days
/// and today, a dot under days with a saved meal, the shown day filled.
class TodayDayStrip extends StatelessWidget {
  const TodayDayStrip({
    super.key,
    required this.today,
    required this.selected,
    required this.mealDays,
    required this.onSelect,
  });

  final DateTime today;
  final DateTime selected;
  final Set<DateTime> mealDays;
  final ValueChanged<DateTime> onSelect;

  static const length = 7;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final days = [
      for (var back = length - 1; back >= 0; back--)
        DateTime(today.year, today.month, today.day - back),
    ];
    return AppGlassCard(
      key: const Key('today-day-strip'),
      stadium: true,
      padding: const EdgeInsets.all(AppSpacing.stepGap),
      shadows: AppShadows.glassCard,
      child: Row(
        children: [
          for (final day in days)
            Expanded(
              child: _Day(
                day: day,
                selected: day == selected,
                hasMeal: mealDays.contains(day),
                label: strings.dayStripLabel(
                  DateFormat.EEEE(strings.localeName).format(day),
                  DateFormat('d/M', strings.localeName).format(day),
                ),
                weekday: strings.dayStripWeekday(day.weekday.toString()),
                onTap: () => onSelect(day),
              ),
            ),
        ],
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({
    required this.day,
    required this.selected,
    required this.hasMeal,
    required this.label,
    required this.weekday,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool hasMeal;
  final String label;
  final String weekday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryForeground : AppColors.foreground;
    return Semantics(
      key: Key('today-day-${day.month}-${day.day}'),
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.selection),
          curve: AppMotion.selectionCurve,
          constraints: const BoxConstraints(minHeight: AppSizes.action),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.meterFillEnd, AppColors.primary],
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                weekday,
                style: AppTypography.micro.copyWith(
                  color: selected
                      ? AppColors.primaryForeground
                      : AppColors.mutedForeground,
                ),
              ),
              Text(
                '${day.day}',
                style: AppTypography.cardTitle.copyWith(color: color),
              ),
              const SizedBox(height: AppSpacing.xxs),
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasMeal
                      ? (selected
                            ? AppColors.primaryForeground
                            : AppColors.primary)
                      : Colors.transparent,
                ),
                child: const SizedBox.square(dimension: AppSpacing.stepGap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
