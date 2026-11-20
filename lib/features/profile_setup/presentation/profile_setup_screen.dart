import 'dart:ui' show ImageFilter;

import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/body_metrics.dart';
import '../domain/energy_estimate.dart';
import '../domain/goal_policy.dart';
import '../domain/profile.dart';
import '../domain/teen_bmi.dart';
import '../profile_setup_providers.dart';
import 'profile_activity_step.dart';
import 'profile_body_step.dart';
import 'profile_plan_sheet.dart';
import 'profile_setup_controller.dart';
import 'profile_setup_widgets.dart';
import 'profile_target_draft.dart';
import 'profile_target_step.dart';

enum _Step { goal, body, activity, target }

const _weightGoals = [GoalType.gain, GoalType.lose, GoalType.maintain];

/// Four-step Profile Setup: goal → body → activity → target → review.
/// Activity comes before the target so plans can show a daily kcal budget
/// and respect the energy floor. Maintain and ages 13–19 skip the numeric
/// target step. Nothing is written until the user confirms the
/// review.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();

  _Step _step = _Step.goal;
  GoalType? _goal;
  // Male is preselected; the user can switch with one tap.
  ProfileSex? _sex = ProfileSex.male;
  ActivityLevel? _activity;
  bool _stepForward = true;
  ProfileTargetDraft _target = const ProfileTargetDraft();
  Map<ProfileBodyField, String> _bodyErrors = const {};
  String? _targetError;
  bool _reviewing = false;
  bool _saveFailed = false;

  AppLocalizations get _strings => AppLocalizations.of(context);
  int? get _ageValue => int.tryParse(_age.text.trim());
  double? get _heightValue => parsePositiveNumber(_height.text);
  double? get _weightValue => parsePositiveNumber(_weight.text);
  bool get _isTeen =>
      (_ageValue ?? BodyLimits.adultAge) >= BodyLimits.minAge &&
      (_ageValue ?? BodyLimits.adultAge) < BodyLimits.adultAge;
  bool get _skipsTarget => _goal == GoalType.maintain || _isTeen;
  _Step get _lastStep => _skipsTarget ? _Step.activity : _Step.target;

  EnergyEstimate? get _energy => estimateEnergy(
    ageYears: _ageValue,
    heightCm: _heightValue,
    weightKg: _weightValue,
    sex: _sex,
    activity: _activity,
  );

  /// The custom deadline, kept reachable for the current target and body.
  DateTime? get _deadline =>
      _target.deadline(goal: _goal!, currentKg: _weightValue!, energy: _energy);

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  bool get _actionEnabled => switch (_step) {
    _Step.goal => _goal != null,
    _Step.target =>
      !_reviewing &&
          lossPlanAllowed(_goal!, _energy) &&
          selectableTargets(
            goal: _goal!,
            currentKg: _weightValue!,
            heightCm: _heightValue!,
          ).isNotEmpty,
    _Step.activity => _activity != null && !_reviewing,
    _Step.body => true,
  };

  @override
  Widget build(BuildContext context) {
    final strings = _strings;
    final editing = ref.watch(savedProfileProvider).value != null;
    return PopScope(
      canPop: _step == _Step.goal,
      onPopInvokedWithResult: (popped, _) {
        if (!popped && !_reviewing && _step != _Step.goal) _back();
      },
      child: Scaffold(
        key: const Key('profile-setup'),
        body: SafeArea(
          bottom: false,
          minimum: const EdgeInsets.only(top: AppSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
              // The back button and progress stay pinned; only the step
              // content scrolls.
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    child: ProfileStepBar(
                      step: _step.index,
                      titles: [
                        strings.profileGoal,
                        strings.profileBody,
                        strings.profileActivity,
                        strings.profileTarget,
                      ],
                      onBack: () {
                        if (_reviewing) return;
                        if (_step != _Step.goal) return _back();
                        // The first step leaves setup, back to where it was
                        // opened from (Welcome on a first run).
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/welcome');
                        }
                      },
                      onStep: (index) {
                        if (_reviewing || index >= _step.index) return;
                        final step = _Step.values[index];
                        _show(step);
                      },
                    ),
                  ),
                  Expanded(
                    child: _switchStep(
                      BackdropGroup(
                        key: ValueKey('profile-setup-${_step.name}'),
                        child: ListView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          // `pb-3` under the header plus the content's
                          // `pt-4`, then `px-5 pb-6`.
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.gutter,
                            AppSpacing.sm + AppSpacing.md,
                            AppSpacing.gutter,
                            AppSpacing.lg,
                          ),
                          children: [
                            switch (_step) {
                              _Step.goal => _goalPage(),
                              _Step.body => ProfileBodyStep(
                                age: _age,
                                height: _height,
                                weight: _weight,
                                sex: _sex,
                                errors: _bodyErrors,
                                onEdited: (field) => setState(() {
                                  _bodyErrors = {..._bodyErrors}..remove(field);
                                }),
                                onSex: (sex) => setState(() {
                                  _sex = sex;
                                  _bodyErrors = {..._bodyErrors}
                                    ..remove(ProfileBodyField.sex);
                                }),
                              ),
                              _Step.target => ProfileTargetStep(
                                goal: _goal!,
                                currentKg: _weightValue!,
                                heightCm: _heightValue!,
                                draft: _target,
                                energy: _energy,
                                error: _targetError,
                                // No healthy target for this goal: keep the
                                // answers and finish as Maintain.
                                onSwitchToMaintain: () {
                                  setState(() => _goal = GoalType.maintain);
                                  _show(_Step.activity);
                                },
                                onChanged: (draft) => setState(() {
                                  _target = draft;
                                  _targetError = null;
                                }),
                              ),
                              _Step.activity => ProfileActivityStep(
                                selected: _activity,
                                onSelected: (level) =>
                                    setState(() => _activity = level),
                                energy: _energy,
                                showsEnergy: !_isTeen,
                                notice: _isTeen
                                    ? _teenGuidanceCard(_goal!)
                                    : null,
                              ),
                            },
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _bottomBar(
          strings,
          showPreviousNote: editing && _step == _Step.target,
        ),
      ),
    );
  }

  Widget _bottomBar(
    AppLocalizations strings, {
    required bool showPreviousNote,
  }) {
    final enabled = _actionEnabled;
    return Center(
      heightFactor: 1,
      // `bg-card/40 backdrop-blur-2xl border-t border-white/60` with the
      // upward dock shadow, `px-5 pt-3 pb-5`.
      child: DecoratedBox(
        decoration: const BoxDecoration(boxShadow: AppShadows.dock),
        child: SizedBox(
          width: AppSizes.contentMax,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppGlass.blurStrong,
                sigmaY: AppGlass.blurStrong,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: MediaQuery.highContrastOf(context)
                      ? AppColors.background
                      : AppGlass.dock,
                  border: const Border(
                    top: BorderSide(color: AppColors.glassEdge),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    AppSpacing.sm,
                    AppSpacing.gutter,
                    AppSpacing.card,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_saveFailed) ...[
                        ProfileFieldError(
                          strings.profileSaveError,
                          key: const Key('onboarding-save-error'),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      AppButton(
                        key: const Key('profile-setup-action'),
                        fullWidth: true,
                        onPressed: enabled ? _advance : null,
                        child: AnimatedSwitcher(
                          duration: AppMotion.of(context, AppMotion.selection),
                          transitionBuilder: (label, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween(
                                    begin: 0.92,
                                    end: 1.0,
                                  ).animate(animation),
                                  child: label,
                                ),
                              ),
                          child: _step == _lastStep
                              ? AppButtonLabel(
                                  strings.profileConfirm,
                                  key: const ValueKey('confirm'),
                                  leadingIcon: 'ph-check-bold',
                                )
                              : AppButtonLabel(
                                  strings.profileContinue,
                                  key: const ValueKey('continue'),
                                ),
                        ),
                      ),
                      if (showPreviousNote) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          strings.profileTargetPreviousKept,
                          textAlign: TextAlign.center,
                          style: AppTypography.micro,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _goalPage() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: AppSpacing.card,
    children: [
      AppEntrance(
        index: 0,
        child: ProfileStepHeading(title: _strings.profileGoalHeading),
      ),
      Semantics(
        label: _strings.profileGoal,
        explicitChildNodes: true,
        child: Column(
          spacing: AppSpacing.denseGap,
          children: [
            for (final (index, goal) in _weightGoals.indexed)
              AppEntrance(
                index: index + 1,
                child: AppSelectionTile(
                  key: Key('profile-goal-${goal.name}'),
                  icon: _goalIcon(goal),
                  label: _goalLabel(goal),
                  selected: _goal == goal,
                  onPressed: () => setState(() => _goal = goal),
                ),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _teenGuidanceCard(GoalType goal) {
    final age = _ageValue;
    final height = _heightValue;
    final weight = _weightValue;
    final status =
        age == null || height == null || weight == null || _sex == null
        ? null
        : teenBmiStatus(
            ageYears: age,
            sex: _sex!,
            heightCm: height,
            weightKg: weight,
          );
    final statusLabel = switch (status) {
      TeenBmiStatus.underweight => _strings.profileTeenBmiStatusUnderweight,
      TeenBmiStatus.healthy => _strings.profileTeenBmiStatusHealthy,
      TeenBmiStatus.overweight => _strings.profileTeenBmiStatusOverweight,
      TeenBmiStatus.obesity => _strings.profileTeenBmiStatusObesity,
      null => _strings.profileTeenGuidanceTitle,
    };
    final body = switch ((status, goal)) {
      (TeenBmiStatus.underweight, GoalType.gain) =>
        _strings.profileTeenUnderweightGain,
      (TeenBmiStatus.underweight, _) => _strings.profileTeenUnderweightLose,
      (TeenBmiStatus.overweight || TeenBmiStatus.obesity, GoalType.lose) =>
        _strings.profileTeenOverweightLose,
      (TeenBmiStatus.overweight || TeenBmiStatus.obesity, GoalType.gain) =>
        _strings.profileTeenOverweightGain,
      _ => _strings.profileTeenHealthy,
    };
    return AppGlassCard(
      key: const Key('profile-teen-guidance'),
      padding: const EdgeInsets.all(AppSpacing.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.sm,
        children: [
          Text(
            _strings.profileTeenGuidanceTitle,
            style: AppTypography.sectionTitle,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              child: Text(
                statusLabel,
                style: AppTypography.label.copyWith(
                  color: AppColors.secondaryForeground,
                ),
              ),
            ),
          ),
          Text(
            body,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  String _goalLabel(GoalType goal) => switch (goal) {
    GoalType.gain => _strings.profileGain,
    GoalType.lose => _strings.profileLose,
    GoalType.maintain => _strings.profileMaintain,
    GoalType.logOnly => _strings.logMeal,
  };

  String _goalIcon(GoalType goal) => switch (goal) {
    GoalType.gain => 'ph-plant',
    GoalType.lose => 'ph-leaf',
    GoalType.maintain => 'ph-scales',
    GoalType.logOnly => 'ph-bowl-food',
  };

  Map<ProfileBodyField, String> _validateBody() {
    final strings = _strings;
    final age = _ageValue;
    final height = _heightValue;
    final weight = _weightValue;
    // Short, friendly hints: "enter it" when empty, the range when not.
    return {
      if (_age.text.trim().isEmpty)
        ProfileBodyField.age: strings.profileAgeEmpty
      else if (age == null || age <= 0 || age > BodyLimits.maxAge)
        ProfileBodyField.age: strings.profileInvalidAge
      else if (age < BodyLimits.minAge)
        ProfileBodyField.age: strings.profileAgeTooYoung,
      if (_height.text.trim().isEmpty)
        ProfileBodyField.height: strings.profileHeightEmpty
      else if (height == null ||
          height < BodyLimits.minHeightCm ||
          height > BodyLimits.maxHeightCm)
        ProfileBodyField.height: strings.profileHeightRange,
      if (_weight.text.trim().isEmpty)
        ProfileBodyField.weight: strings.profileWeightEmpty
      else if (weight == null ||
          weight < BodyLimits.minWeightKg ||
          weight > BodyLimits.maxWeightKg)
        ProfileBodyField.weight: strings.profileWeightRange,
      if (_sex == null) ProfileBodyField.sex: strings.profileMissingSex,
    };
  }

  String? _validateTarget() {
    final target = _target.targetKg;
    if (target == null) return _strings.profileTargetCustomEmpty;
    final estimate = estimateAdultGoal(
      goal: _goal!,
      currentWeight: _weightValue!,
      targetWeight: target,
      targetDate: _deadline,
      energy: _energy,
    );
    if (estimate == null) return _strings.profileTargetCustomEmpty;
    if (estimate.pace == GoalPace.tooFast) return _strings.profilePaceTooFast;
    return null;
  }

  void _back() => _show(switch (_step) {
    _Step.target => _Step.activity,
    _Step.activity => _Step.body,
    _ => _Step.goal,
  });

  void _show(_Step step) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      if (step == _Step.target) {
        _target = _target.reconcile(
          goal: _goal!,
          currentKg: _weightValue!,
          heightCm: _heightValue!,
        );
      }
      _stepForward = step.index >= _step.index;
      _step = step;
    });
  }

  /// Steps cross-fade with a short slide in the direction of travel: forward
  /// enters from the right, back from the left. The outgoing step leaves the
  /// other way. Reduce Motion swaps instantly.
  Widget _switchStep(Widget child) {
    final shift = _stepForward ? 0.08 : -0.08;
    return AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.stepSwitch),
      reverseDuration: AppMotion.of(context, AppMotion.feedbackRelease),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, ?current]),
      transitionBuilder: (step, animation) {
        final incoming = step.key == child.key;
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(
              begin: Offset(incoming ? shift : -shift, 0),
              end: Offset.zero,
            ).animate(animation),
            child: step,
          ),
        );
      },
      child: child,
    );
  }

  Future<void> _advance() async {
    switch (_step) {
      case _Step.goal:
        _show(_Step.body);
      case _Step.body:
        final errors = _validateBody();
        if (errors.isNotEmpty) {
          setState(() => _bodyErrors = errors);
          return;
        }
        _show(_Step.activity);
      case _Step.activity:
        if (_skipsTarget) {
          await _review();
        } else {
          _show(_Step.target);
        }
      case _Step.target:
        final error = _validateTarget();
        if (error != null) {
          setState(() => _targetError = error);
          return;
        }
        await _review();
    }
  }

  /// What the plan sheet shows for the current answers. kcal values use the
  /// display step, and the saved target is exactly the number shown.
  ProfilePlanSummary _planSummary() {
    final goal = _goal!;
    final current = _weightValue!;
    final savesTarget = !_skipsTarget;
    final targetKg = savesTarget ? _target.targetKg : null;
    final energy = _energy;
    final estimate = targetKg == null
        ? null
        : estimateAdultGoal(
            goal: goal,
            currentWeight: current,
            targetWeight: targetKg,
            targetDate: _deadline,
            energy: energy,
          );
    final body = energy == null ? null : roundKcal(energy.totalKcal);
    final planned = estimate?.dailyKcal;
    final kind = switch (goal) {
      _ when energy == null => ProfilePlanKind.noKcal,
      GoalType.maintain => ProfilePlanKind.maintain,
      _ when planned == null => ProfilePlanKind.noKcal,
      _ when roundKcal(planned) == body => ProfilePlanKind.maintain,
      GoalType.gain => ProfilePlanKind.gain,
      _ => ProfilePlanKind.lose,
    };
    return ProfilePlanSummary(
      kind: kind,
      goal: goal,
      currentKg: current,
      activity: _activity!,
      budgetKcal: switch (kind) {
        ProfilePlanKind.noKcal => null,
        _ when planned != null && goal != GoalType.maintain => roundKcal(
          planned,
        ),
        _ => body,
      },
      bodyKcal: body,
      targetKg: targetKg,
      rateKgPerWeek: estimate?.rateKgPerWeek,
      projectedDate: estimate?.projectedDate,
      bmi: bodyMassIndex(weightKg: current, heightCm: _heightValue),
    );
  }

  Future<void> _review() async {
    final savesTarget = !_skipsTarget;
    final targetKg = savesTarget ? _target.targetKg : null;
    final targetDate = savesTarget ? _deadline : null;
    final summary = _planSummary();
    setState(() {
      _reviewing = true;
      _saveFailed = false;
    });
    try {
      final proceed = await showProfilePlanSheet(context, summary);
      if (!mounted || proceed != true) return;
      final now = DateTime.now();
      final profile = Profile(
        ageYears: _ageValue!,
        heightCm: _heightValue!,
        sex: _sex!,
        activityLevel: _activity!,
        dailyEnergyKcal: summary.budgetKcal,
        goal: Goal(
          type: _goal!,
          currentWeight: _weightValue,
          targetWeight: targetKg,
          targetDate: targetDate,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final saved = await ref
          .read(profileSetupControllerProvider)
          .save(profile);
      if (!mounted) return;
      if (saved) {
        context.go('/today');
      } else {
        setState(() => _saveFailed = true);
      }
    } finally {
      if (mounted) setState(() => _reviewing = false);
    }
  }
}
