import 'package:app_ui/app_ui.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Seven-day strip under the Home title (Sleek "Hôm nay"): the last six days
/// and today. The shown day is a filled circle, today keeps a ring while
/// another day is shown, and days with a saved meal get a dot.
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
      radius: AppRadii.glassInner,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      shadows: AppShadows.glassCard,
      child: Row(
        children: [
          for (final day in days)
            Expanded(
              child: _Day(
                day: day,
                selected: day == selected,
                isToday: day == today,
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
    required this.isToday,
    required this.hasMeal,
    required this.label,
    required this.weekday,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool isToday;
  final bool hasMeal;
  final String label;
  final String weekday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: Key('today-day-${day.month}-${day.day}'),
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.action),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xxs,
            children: [
              Text(
                weekday,
                style: AppTypography.micro.copyWith(
                  color: selected
                      ? AppColors.primary
                      : AppColors.mutedForeground,
                  fontWeight: selected ? FontWeight.w700 : null,
                ),
              ),
              AnimatedContainer(
                duration: AppMotion.of(context, AppMotion.selection),
                curve: AppMotion.selectionCurve,
                constraints: const BoxConstraints(
                  minWidth: AppSizes.dayCircle,
                  minHeight: AppSizes.dayCircle,
                ),
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  shape: CircleBorder(
                    side: isToday && !selected
                        ? const BorderSide(color: AppColors.primary)
                        : BorderSide.none,
                  ),
                  color: selected ? AppColors.primary : null,
                ),
                child: Text(
                  '${day.day}',
                  style: AppTypography.cardTitle.copyWith(
                    color: selected
                        ? AppColors.primaryForeground
                        : AppColors.foreground,
                  ),
                ),
              ),
              // Kept empty on days without meals so every column aligns.
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasMeal ? AppColors.primary : Colors.transparent,
                ),
                child: const SizedBox.square(dimension: AppSpacing.xxs),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
