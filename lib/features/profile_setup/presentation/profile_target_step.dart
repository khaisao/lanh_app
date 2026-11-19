import 'package:app_ui/app_ui.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/energy_estimate.dart';
import '../domain/goal_policy.dart';
import 'profile_setup_widgets.dart';
import 'profile_target_cards.dart';
import 'profile_target_draft.dart';

/// The "Mong muốn" step from Profile Setup Target: Lành's 5%/10% plans, or a
/// custom whole-kilogram target with an optional date and a live estimate.
class ProfileTargetStep extends StatelessWidget {
  const ProfileTargetStep({
    super.key,
    required this.goal,
    required this.goalLabel,
    required this.currentKg,
    required this.heightCm,
    required this.draft,
    required this.onChanged,
    this.onSwitchToMaintain,
    this.energy,
    this.error,
  });

  final GoalType goal;
  final String goalLabel;
  final double currentKg;
  final double heightCm;
  final ProfileTargetDraft draft;
  final ValueChanged<ProfileTargetDraft> onChanged;

  /// Offered when no healthy target exists for this goal.
  final VoidCallback? onSwitchToMaintain;

  /// Adult energy estimate; adds kcal to plans and caps the loss pace.
  final EnergyEstimate? energy;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final format = ProfileTargetFormat(strings);
    final options = selectableTargets(
      goal: goal,
      currentKg: currentKg,
      heightCm: heightCm,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.lg,
      children: [
        AppEntrance(
          index: 0,
          child: ProfileStepHeading(
            title: strings.profileTarget,
            subtitle: strings.profileTargetSubtitle(
              goalLabel,
              format.kg(currentKg),
            ),
          ),
        ),
        if (options.isEmpty || !lossPlanAllowed(goal, energy))
          AppGlassCard(
            key: const Key('profile-target-unavailable'),
            padding: const EdgeInsets.all(AppSpacing.card),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.sm,
              children: [
                const AppIcon.asset(
                  'ph-info',
                  size: AppSizes.iconMd,
                  color: AppColors.primary,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.sm,
                    children: [
                      Text(
                        options.isEmpty
                            ? goal == GoalType.lose
                                  ? strings.profileTargetUnavailableLose
                                  : strings.profileTargetUnavailableGain
                            : strings.profileTargetUnavailableEnergy(
                                format.kcal(energy!.floorKcal),
                              ),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.foreground,
                        ),
                      ),
                      if (onSwitchToMaintain case final onSwitch?)
                        AppButton.secondary(
                          key: const Key('profile-target-switch-maintain'),
                          onPressed: onSwitch,
                          child: Text(strings.profileSwitchToMaintain),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else ...[
          AppEntrance(
            index: 1,
            child: AppGlassSegmentedControl<ProfileTargetMode>(
              key: const Key('profile-target-mode'),
              label: strings.profileTargetModeLabel,
              segments: [
                (
                  ProfileTargetMode.suggested,
                  strings.profileTargetModeSuggested,
                ),
                (ProfileTargetMode.custom, strings.profileTargetModeCustom),
              ],
              selected: draft.mode,
              onChanged: (mode) => onChanged(_switchMode(mode)),
            ),
          ),
          if (draft.mode == ProfileTargetMode.suggested)
            ..._suggested(strings, format)
          else
            ..._custom(context, strings, format, options),
        ],
      ],
    );
  }

  ProfileTargetDraft _switchMode(ProfileTargetMode mode) =>
      mode == ProfileTargetMode.custom && draft.customKg == null
      ? draft.copyWith(mode: mode, customKg: () => draft.suggestedKg?.round())
      : draft.copyWith(mode: mode);

  List<Widget> _suggested(
    AppLocalizations strings,
    ProfileTargetFormat format,
  ) {
    final suggestions = suggestTargets(
      goal: goal,
      currentKg: currentKg,
      heightCm: heightCm,
      energy: energy,
    );
    final limited = suggestions.any((item) => item.estimate.energyLimited);
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Text(
              strings.profileTargetSuggestedFrom(format.kg(currentKg)),
              style: AppTypography.label,
            ),
          ),
          for (final (index, suggestion) in suggestions.indexed) ...[
            AppEntrance(
              index: index + 2,
              child: ProfileTargetPlanCard(
                key: Key('profile-target-plan-$index'),
                title: _planTitle(strings, format, index, suggestion),
                suggestion: suggestion,
                selected: draft.suggestedKg == suggestion.targetKg,
                format: format,
                onPressed: () => onChanged(
                  draft.copyWith(suggestedKg: () => suggestion.targetKg),
                ),
              ),
            ),
          ],
          if (limited && energy != null)
            Padding(
              key: const Key('profile-target-energy-limited'),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              child: Text(
                strings.profileTargetEnergyLimited(
                  format.kcal(energy!.floorKcal),
                ),
                style: AppTypography.caption,
              ),
            ),
        ],
      ),
    ];
  }

  String _planTitle(
    AppLocalizations strings,
    ProfileTargetFormat format,
    int index,
    TargetSuggestion suggestion,
  ) {
    final percent = suggestion.clamped
        ? format.percent(currentKg, suggestion.targetKg)
        : (suggestion.fraction * 100).round().toString();
    if (index > 1) return strings.profileTargetPlanLonger(percent);
    if (index == 1) return strings.profileTargetPlanModerate(percent);
    return goal == GoalType.lose
        ? strings.profileTargetPlanGentle(percent)
        : strings.profileTargetPlanGainGentle(percent);
  }

  List<Widget> _custom(
    BuildContext context,
    AppLocalizations strings,
    ProfileTargetFormat format,
    List<int> options,
  ) {
    final target = draft.customKg?.toDouble();
    final estimate = target == null
        ? null
        : estimateAdultGoal(
            goal: goal,
            currentWeight: currentKg,
            targetWeight: target,
            targetDate: draft.targetDate,
            energy: energy,
          );
    final onPrimary = AppColors.primaryForeground;
    return [
      AppEntrance(
        index: 2,
        child: ProfilePrimaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xxs,
            children: [
              Text(
                strings.profileTargetCustomTitle,
                style: AppTypography.label.copyWith(
                  color: onPrimary.withValues(alpha: 0.8),
                ),
              ),
              // The chosen weight rolls as chips are tapped.
              AppRollingText(
                target == null ? '—' : '${format.kg(target)} kg',
                key: const Key('profile-target-custom-value'),
                style: AppTypography.numericLarge.copyWith(
                  color: onPrimary,
                  height: 1.1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              AppRollingText(
                target == null
                    ? strings.profileTargetCustomEmpty
                    : goal == GoalType.lose
                    ? strings.profileTargetCustomDeltaLose(
                        format.delta(currentKg, target),
                        format.kg(currentKg),
                      )
                    : strings.profileTargetCustomDeltaGain(
                        format.delta(currentKg, target),
                        format.kg(currentKg),
                      ),
                style: AppTypography.label.copyWith(
                  color: onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
      AppEntrance(
        index: 3,
        child: ProfileTargetKgPicker(
          label: strings.profileTargetPickerLabel,
          helper: goal == GoalType.lose
              ? strings.profileTargetPickerRangeLose('${options.first}')
              : strings.profileTargetPickerRangeGain('${options.last}'),
          options: options,
          selected: draft.customKg,
          onSelected: (kg) => onChanged(draft.copyWith(customKg: () => kg)),
        ),
      ),
      AppEntrance(
        index: 4,
        child: _timingCard(context, strings, format, target),
      ),
      AppEntrance(
        index: 5,
        child: ProfilePlanEstimateCard(
          goal: goal,
          estimate: estimate,
          format: format,
        ),
      ),
      if (error case final message?) ProfileFieldError(message),
    ];
  }

  Widget _timingCard(
    BuildContext context,
    AppLocalizations strings,
    ProfileTargetFormat format,
    double? target,
  ) {
    final earliest = target == null
        ? null
        : earliestSafeDate(
            goal: goal,
            currentKg: currentKg,
            targetKg: target,
            energy: energy,
          );
    return AppGlassCard(
      padding: const EdgeInsets.all(AppSpacing.card),
      // The date row opens and closes smoothly with the timing choice.
      child: AppAnimatedSize(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            Semantics(
              header: true,
              child: Text(
                strings.profileTargetWhenTitle,
                style: AppTypography.cardTitle.copyWith(
                  fontFamily: AppFonts.heading,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AppGlassSegmentedControl<ProfileTargetTiming>(
              key: const Key('profile-target-timing'),
              label: strings.profileTargetWhenLabel,
              segments: [
                (ProfileTargetTiming.none, strings.profileTargetNoDate),
                (ProfileTargetTiming.date, strings.profilePickDate),
              ],
              selected: draft.timing,
              onChanged: (timing) => onChanged(draft.copyWith(timing: timing)),
            ),
            if (draft.timing == ProfileTargetTiming.none)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                child: Text(
                  strings.profileTargetNoDateNote,
                  style: AppTypography.caption.copyWith(height: 1.625),
                ),
              )
            else ...[
              Semantics(
                button: true,
                label:
                    '${strings.profileTargetDate}, ${draft.date == null ? strings.profilePickDate : format.date(draft.date!)}',
                excludeSemantics: true,
                child: Material(
                  key: const Key('profile-target-date'),
                  color: AppColors.input,
                  shape: AppSquircleBorder(
                    radius: AppRadii.glassInner,
                    side: BorderSide(color: AppGlass.edge),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: target == null
                        ? null
                        : () => _pickDate(context, earliest!),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: AppSizes.action,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          spacing: AppSpacing.sm,
                          children: [
                            Expanded(
                              child: Text(
                                strings.profileTargetDate,
                                style: AppTypography.fieldLabel.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              draft.date == null
                                  ? strings.profilePickDate
                                  : format.date(draft.date!),
                              style: AppTypography.fieldLabel.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const AppIcon.asset(
                              'ph-calendar-blank',
                              size: AppSizes.iconSm,
                              color: AppColors.foreground,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (earliest != null)
                Text(
                  strings.profileTargetEarliestDate(format.date(earliest)),
                  style: AppTypography.caption,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime earliest) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final previous = draft.date;
    final picked = await showDatePicker(
      context: context,
      firstDate: earliest,
      initialDate: previous == null || previous.isBefore(earliest)
          ? earliest
          : previous,
      lastDate: DateUtils.addDaysToDate(
        earliest,
        WeightPlanPolicy.maximumPlanWeeks * 7,
      ),
    );
    if (picked == null || !context.mounted) return;
    onChanged(draft.copyWith(date: () => picked));
  }
}
