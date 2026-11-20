import 'package:app_ui/app_ui.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/energy_estimate.dart';
import '../domain/goal_policy.dart';
import 'profile_setup_widgets.dart';
import 'profile_target_cards.dart';
import 'profile_target_custom_cards.dart';
import 'profile_target_draft.dart';

/// The "Mong muốn" step from Profile Setup Target: Lành's 5%/10% plans, or a
/// custom half-kilogram target with an optional date and a live estimate.
class ProfileTargetStep extends StatelessWidget {
  const ProfileTargetStep({
    super.key,
    required this.goal,
    required this.currentKg,
    required this.heightCm,
    required this.draft,
    required this.onChanged,
    this.onSwitchToMaintain,
    this.energy,
    this.error,
  });

  final GoalType goal;
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
      spacing: AppSpacing.card,
      children: [
        AppEntrance(
          index: 0,
          child: ProfileStepHeading(title: strings.profileTarget),
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
                  'ph-sparkle',
                ),
                (
                  ProfileTargetMode.custom,
                  strings.profileTargetModeCustom,
                  'ph-pencil-simple',
                ),
              ],
              selected: draft.mode,
              onChanged: (mode) => onChanged(draft.copyWith(mode: mode)),
            ),
          ),
          if (draft.mode == ProfileTargetMode.suggested)
            ..._suggested(strings, format)
          else
            ..._custom(context, format, options),
        ],
      ],
    );
  }

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
        spacing: AppSpacing.denseGap,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Row(
              spacing: AppSpacing.stepGap,
              children: [
                const AppIcon.asset(
                  'ph-scales',
                  size: AppSizes.iconInfo,
                  color: AppColors.mutedForeground,
                ),
                Expanded(
                  child: Text(
                    strings.profileTargetSuggestedFrom(format.kg(currentKg)),
                    style: AppTypography.label,
                  ),
                ),
              ],
            ),
          ),
          for (final (index, suggestion) in suggestions.indexed) ...[
            AppEntrance(
              index: index + 2,
              child: ProfileTargetPlanCard(
                key: Key('profile-target-plan-$index'),
                icon: _planIcons[index.clamp(0, _planIcons.length - 1)],
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

  /// Gentle, moderate and longer plans: footprints, a path, the finish flag.
  static const _planIcons = ['ph-footprints', 'ph-path', 'ph-flag-checkered'];

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

  /// Profile Setup Target Custom: the weight card, then the date switch with
  /// the live plan estimate. [ProfileTargetDraft.reconcile] has already set a
  /// valid custom target.
  List<Widget> _custom(
    BuildContext context,
    ProfileTargetFormat format,
    List<double> options,
  ) {
    final target = draft.customKg!;
    final deadline = draft.deadline(
      goal: goal,
      currentKg: currentKg,
      energy: energy,
    );
    final estimate = estimateAdultGoal(
      goal: goal,
      currentWeight: currentKg,
      targetWeight: target,
      targetDate: deadline,
      energy: energy,
    );
    return [
      AppEntrance(
        index: 2,
        child: ProfileTargetWeightCard(
          kg: target,
          options: options,
          format: format,
          onChanged: (kg) => onChanged(draft.copyWith(customKg: () => kg)),
        ),
      ),
      AppEntrance(
        index: 3,
        child: ProfileTargetTimingCard(
          goal: goal,
          date: deadline,
          dateMoved: deadline != null && deadline != draft.date,
          estimate: estimate,
          format: format,
          onDateEnabled: (enabled) => enabled
              ? _pickDate(context, target, deadline)
              : onChanged(draft.copyWith(timing: ProfileTargetTiming.none)),
          onPickDate: () => _pickDate(context, target, deadline),
        ),
      ),
      if (error case final message?) ProfileFieldError(message),
    ];
  }

  /// Opens the date picker limited to dates the plan can safely reach, and
  /// turns the deadline on once a date is chosen. Cancelling changes nothing.
  Future<void> _pickDate(
    BuildContext context,
    double target,
    DateTime? deadline,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final earliest = earliestSafeDate(
      goal: goal,
      currentKg: currentKg,
      targetKg: target,
      energy: energy,
    );
    // Reopens at the shown or previously picked day, never before the first
    // selectable one (which can move on at midnight).
    final previous = deadline ?? draft.date;
    final initial = previous == null || previous.isBefore(earliest)
        ? earliest
        : previous;
    final last = DateUtils.addDaysToDate(
      earliest,
      WeightPlanPolicy.maximumPlanWeeks * 7,
    );
    final picked = await showDatePicker(
      context: context,
      firstDate: earliest,
      initialDate: initial,
      // A date picked for a farther target may sit past the usual end.
      lastDate: initial.isAfter(last) ? initial : last,
    );
    if (picked == null || !context.mounted) return;
    onChanged(
      draft.copyWith(timing: ProfileTargetTiming.date, date: () => picked),
    );
  }
}
