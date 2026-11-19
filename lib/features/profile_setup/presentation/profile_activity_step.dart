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

  /// False for teens and pregnancy, where [notice] explains instead.
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
      spacing: AppSpacing.lg,
      children: [
        AppEntrance(
          index: 0,
          child: ProfileStepHeading(
            title: strings.profileActivityHeading,
            subtitle: strings.profileActivityCaption,
          ),
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
                    compact: true,
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

/// Glass card with the estimated daily energy, or a prompt to pick a level.
class ProfileEnergyCard extends StatelessWidget {
  const ProfileEnergyCard({super.key, required this.energy});

  final EnergyEstimate? energy;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final format = NumberFormat.decimalPattern(strings.localeName);
    final energy = this.energy;
    final range = energy?.totalRangeKcal;
    final value = energy == null
        ? null
        : range == null
        ? strings.profileEnergyValue(format.format(roundKcal(energy.totalKcal)))
        : strings.profileEnergyRange(
            format.format(roundKcal(range.$1)),
            format.format(roundKcal(range.$2)),
          );
    return Semantics(
      key: const Key('profile-energy-estimate'),
      container: true,
      label: value == null
          ? strings.profileEnergyPickActivity
          : '${strings.profileEnergyTitle} $value',
      excludeSemantics: true,
      child: AppGlassCard(
        padding: const EdgeInsets.all(AppSpacing.card),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.md,
          children: [
            const ProfileIconWell('ph-fire'),
            Expanded(
              // Grows smoothly from the prompt to the full estimate.
              child: AppAnimatedSize(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xxs,
                  children: [
                    if (value == null)
                      Text(
                        strings.profileEnergyPickActivity,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.foreground,
                        ),
                      )
                    else ...[
                      Text(
                        strings.profileEnergyTitle,
                        style: AppTypography.label,
                      ),
                      // Rolls to the new estimate as the activity changes.
                      AppRollingText(
                        value,
                        style: AppTypography.sectionTitle.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        strings.profileEnergyCaption,
                        style: AppTypography.caption,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
