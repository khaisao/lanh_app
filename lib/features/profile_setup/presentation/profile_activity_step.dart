import 'package:app_ui/app_ui.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/energy_estimate.dart';
import '../domain/profile.dart';
import 'profile_setup_widgets.dart';

/// "Một ngày thường": the activity answer and, for adults, the daily energy
/// it implies. It comes before the Target step so plans can show kcal.
class ProfileActivityStep extends StatelessWidget {
  const ProfileActivityStep({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.energy,
    required this.showsEnergy,
    this.notice,
  });

  final ActivityLevel? selected;
  final ValueChanged<ActivityLevel> onSelected;

  /// Null when no estimate is possible yet or Lành must not compute one.
  final EnergyEstimate? energy;

  /// False for teens, where [notice] explains instead.
  final bool showsEnergy;
  final Widget? notice;

  static String icon(ActivityLevel level) => switch (level) {
    ActivityLevel.sitting => 'ph-armchair',
    ActivityLevel.light => 'ph-footprints',
    ActivityLevel.moderate => 'ph-person-simple-walk',
    ActivityLevel.heavy => 'ph-barbell',
    ActivityLevel.variable => 'ph-calendar-dots',
  };

  static String label(AppLocalizations strings, ActivityLevel level) =>
      switch (level) {
        ActivityLevel.sitting => strings.profileSitting,
        ActivityLevel.light => strings.profileLight,
        ActivityLevel.moderate => strings.profileModerate,
        ActivityLevel.heavy => strings.profileHeavy,
        ActivityLevel.variable => strings.profileVariable,
      };

  static String _hint(AppLocalizations strings, ActivityLevel level) =>
      switch (level) {
        ActivityLevel.sitting => strings.profileActivitySittingHint,
        ActivityLevel.light => strings.profileActivityLightHint,
        ActivityLevel.moderate => strings.profileActivityModerateHint,
        ActivityLevel.heavy => strings.profileActivityHeavyHint,
        ActivityLevel.variable => strings.profileActivityVariableHint,
      };

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.card,
      children: [
        AppEntrance(
          index: 0,
          child: ProfileStepHeading(title: strings.profileActivityHeading),
        ),
        if (notice case final notice?) AppEntrance(index: 1, child: notice),
        Semantics(
          label: strings.profileActivity,
          explicitChildNodes: true,
          child: Column(
            spacing: AppSpacing.denseGap,
            children: [
              for (final (index, level) in ActivityLevel.values.indexed)
                AppEntrance(
                  index: index + 2,
                  child: AppSelectionTile(
                    key: Key('profile-activity-${level.name}'),
                    icon: icon(level),
                    label: label(strings, level),
                    description: _hint(strings, level),
                    selected: selected == level,
                    onPressed: () => onSelected(level),
                  ),
                ),
            ],
          ),
        ),
        if (showsEnergy)
          AppEntrance(
            index: ActivityLevel.values.length + 2,
            child: ProfileEnergyCard(energy: energy),
          ),
      ],
    );
  }
}

/// Centred glass card with the estimated daily energy (a 56 dp fire circle,
/// "Cơ thể bạn dùng khoảng", the kcal number and a disclaimer), or a prompt
/// to pick a level.
class ProfileEnergyCard extends StatelessWidget {
  const ProfileEnergyCard({super.key, required this.energy});

  final EnergyEstimate? energy;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final format = NumberFormat.decimalPattern(strings.localeName);
    final energy = this.energy;
    final range = energy?.totalRangeKcal;
    final number = energy == null
        ? null
        : range == null
        ? format.format(roundKcal(energy.totalKcal))
        : '${format.format(roundKcal(range.$1))}–'
              '${format.format(roundKcal(range.$2))}';
    return Semantics(
      key: const Key('profile-energy-estimate'),
      container: true,
      label: number == null
          ? strings.profileEnergyPickActivity
          : '${strings.profileEnergyTitle} $number ${strings.profileEnergyUnit}',
      excludeSemantics: true,
      child: AppGlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        // Grows smoothly from the prompt to the full estimate.
        child: AppAnimatedSize(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              const SizedBox.square(
                dimension: AppSizes.avatarLarge,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon.asset(
                      'ph-fire',
                      size: AppSizes.iconXl,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (number == null)
                Text(
                  strings.profileEnergyPickActivity,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.foreground,
                  ),
                )
              else ...[
                Text(
                  strings.profileEnergyTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.label,
                ),
                const SizedBox(height: AppSpacing.xxs),
                // The unit sits beside the number and wraps below it when
                // large text leaves no room.
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: AppSpacing.stepGap,
                  children: [
                    // Rolls to the new estimate as the activity changes.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AppRollingText(
                        number,
                        style: AppTypography.numericLarge.copyWith(
                          height: 1.25,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    Padding(
                      // Lines the unit up with the number's baseline.
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                      child: Text(
                        strings.profileEnergyUnit,
                        style: AppTypography.cardTitle.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  strings.profileEnergyCaption,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
