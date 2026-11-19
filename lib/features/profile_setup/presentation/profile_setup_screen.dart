import 'package:app_ui/app_ui.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/profile.dart';
import '../domain/goal_policy.dart';
import '../domain/teen_bmi.dart';
import 'profile_setup_controller.dart';
import 'profile_setup_widgets.dart';

enum _Step { goal, body, target, activity }

const _weightGoals = [GoalType.gain, GoalType.lose, GoalType.maintain];

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _form = GlobalKey<FormState>();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _target = TextEditingController();

  _Step _step = _Step.goal;
  GoalType? _goal;
  int? _sex;
  int? _activity;
  DateTime? _targetDate;
  bool _reviewing = false;
  bool _saveFailed = false;

  bool get _maintaining => _goal == GoalType.maintain;
  int? get _ageValue => int.tryParse(_age.text.trim());
  bool get _isTeen => (_ageValue ?? 0) >= 13 && (_ageValue ?? 0) <= 19;
  TeenBmiStatus? get _teenStatus {
    final age = _ageValue;
    final sex = _sex;
    final height = _positiveNumber(_height.text);
    final weight = _positiveNumber(_weight.text);
    if (age == null || sex == null || height == null || weight == null) {
      return null;
    }
    return teenBmiStatus(
      ageYears: age,
      sex: ProfileSex.values[sex],
      heightCm: height,
      weightKg: weight,
    );
  }

  AppLocalizations get _strings => AppLocalizations.of(context);

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = _strings;
    final actionEnabled = switch (_step) {
      _Step.goal => _goal != null,
      _Step.activity => _activity != null && !_reviewing,
      _ => true,
    };
    return PopScope(
      canPop: _step == _Step.goal,
      onPopInvokedWithResult: (popped, _) {
        if (!popped && !_reviewing && _step != _Step.goal) _back();
      },
      child: Scaffold(
        key: ValueKey('profile-setup-${_step.name}'),
        body: SafeArea(
          bottom: false,
          minimum: const EdgeInsets.only(top: AppSpacing.onboardingTop),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
              child: ListView(
                key: ValueKey(_step),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  0,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                children: [
                  ProfileStepBar(
                    step: _step.index,
                    titles: [
                      strings.profileGoal,
                      strings.profileBody,
                      _maintaining
                          ? strings.profileBody
                          : strings.profileTarget,
                      strings.profileActivity,
                    ],
                    onBack: () {
                      if (!_reviewing) _back();
                    },
                    onStep: (index) {
                      if (!_reviewing && index < _step.index) {
                        _show(
                          _maintaining && index == _Step.target.index
                              ? _Step.body
                              : _Step.values[index],
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: _step == _Step.goal
                        ? AppSpacing.pageTop
                        : AppSpacing.xl,
                  ),
                  ...switch (_step) {
                    _Step.goal => _goalPage(),
                    _Step.body => _bodyPage(),
                    _Step.target => _targetPage(),
                    _Step.activity => _activityPage(),
                  },
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Center(
          heightFactor: 1,
          child: SizedBox(
            width: AppSizes.contentMax,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md + AppBorders.hairline,
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
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
                      animatePress: true,
                      onPressed: actionEnabled ? _advance : null,
                      child: _step == _Step.activity
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: AppSpacing.xs,
                              children: [
                                ExcludeSemantics(
                                  child: AppIcon.asset(
                                    'ph-check-circle-fill',
                                    size: AppSizes.iconMd,
                                    color: actionEnabled
                                        ? AppColors.primaryForeground
                                        : AppColors.secondaryForeground,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    strings.profileConfirm,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              strings.profileContinue,
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _goalPage() => [
    ProfileStepHeading(
      hero: true,
      title: _strings.profileGoalHeading,
      subtitle: Text(
        _strings.profileGoalCaption,
        style: AppTypography.setupCaption,
        textAlign: TextAlign.center,
      ),
    ),
    const SizedBox(height: AppSpacing.xl),
    Semantics(
      label: _strings.profileGoal,
      explicitChildNodes: true,
      child: Column(
        spacing: AppSpacing.sm,
        children: [
          for (final goal in _weightGoals)
            AppSelectionTile(
              key: Key('profile-goal-${goal.name}'),
              icon: _goalIcon(goal),
              label: _goalLabel(goal),
              selected: _goal == goal,
              onPressed: () => setState(() => _goal = goal),
            ),
        ],
      ),
    ),
  ];

  List<Widget> _bodyPage() {
    final strings = _strings;
    final age = ProfileNumberField(
      key: const Key('profile-age'),
      label: strings.profileAge,
      unit: strings.profileYears,
      controller: _age,
      whole: true,
      validator: (value) {
        final years = int.tryParse(value?.trim() ?? '');
        return years == null || years <= 0
            ? strings.profileInvalidAge
            : years < 13
            ? strings.profileAgeTooYoung
            : years > 120
            ? strings.profileInvalidAge
            : null;
      },
      onChanged: (_) => setState(() {}),
    );
    final height = ProfileNumberField(
      key: const Key('profile-height'),
      label: strings.profileHeight,
      unit: 'cm',
      controller: _height,
      validator: _validateNumber,
      onChanged: (_) => setState(() {}),
    );
    return [
      ProfileStepHeading(
        title: strings.profileBody,
        subtitle: Text(
          strings.profileBodyCaption,
          style: AppTypography.setupCaption,
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _bodyInsightCard(),
          const SizedBox(height: AppSpacing.md),
          Form(
            key: _form,
            child: Column(
              spacing: AppSpacing.sm,
              children: [
                if (MediaQuery.textScalerOf(context).scale(12) <= 18)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.sm,
                    children: [
                      Expanded(child: age),
                      Expanded(child: height),
                    ],
                  )
                else ...[
                  age,
                  height,
                ],
                ProfileNumberField(
                  key: const Key('profile-current-weight'),
                  label: strings.profileCurrentWeight,
                  unit: 'kg',
                  controller: _weight,
                  validator: _validateNumber,
                  onChanged: (_) => setState(() {}),
                ),
                _sexField(),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  Widget _bodyInsightCard() {
    final strings = _strings;
    final age = _ageValue;
    final height = _positiveNumber(_height.text);
    final weight = _positiveNumber(_weight.text);
    final sex = _sex;
    final complete =
        age != null &&
        age >= 13 &&
        age <= 120 &&
        height != null &&
        weight != null &&
        sex != null;
    if (!complete) {
      return ProfileFieldCard(
        key: const Key('profile-body-insight'),
        label: strings.profileBodyInsightTitle,
        child: Text(
          strings.profileBodyInsightEmpty,
          style: AppTypography.bodySmall,
        ),
      );
    }

    final bmi = weight / ((height / 100) * (height / 100));
    final formatter = NumberFormat.decimalPattern(strings.localeName)
      ..maximumFractionDigits = 1;
    final isTeen = age <= 19;
    final status = isTeen
        ? switch (teenBmiStatus(
            ageYears: age,
            sex: ProfileSex.values[sex],
            heightCm: height,
            weightKg: weight,
          )) {
            TeenBmiStatus.underweight =>
              strings.profileTeenBmiStatusUnderweight,
            TeenBmiStatus.healthy => strings.profileTeenBmiStatusHealthy,
            TeenBmiStatus.overweight => strings.profileTeenBmiStatusOverweight,
            TeenBmiStatus.obesity => strings.profileTeenBmiStatusObesity,
            null => strings.profileBmiHint,
          }
        : bmi < 18.5
        ? strings.profileBmiAdultUnderweight
        : bmi < 25
        ? strings.profileBmiAdultHealthy
        : bmi < 30
        ? strings.profileBmiAdultOverweight
        : strings.profileBmiAdultObesity;
    return DecoratedBox(
      key: const Key('profile-body-insight'),
      decoration: const ShapeDecoration(
        color: AppColors.secondary,
        shape: AppSquircleBorder(radius: AppRadii.exportCardSquircle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs,
          children: [
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xxs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  strings.profileBodyInsightTitle,
                  style: AppTypography.label.copyWith(
                    color: AppColors.secondaryForeground,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.navLabelGap,
                    ),
                    child: Text(
                      strings.profileBmiLabel,
                      style: AppTypography.micro.copyWith(
                        color: AppColors.accentForeground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatter.format(bmi),
                  style: AppTypography.setupNumber.copyWith(
                    color: AppColors.secondaryForeground,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      status,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondaryForeground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              isTeen ? strings.profileBmiTeenHint : strings.profileBmiHint,
              style: AppTypography.caption.copyWith(
                color: AppColors.secondaryForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sexField() {
    final strings = _strings;
    final labels = [strings.profileFemale, strings.profileMale];
    return FormField<int>(
      initialValue: _sex,
      validator: (value) => value == null ? strings.profileMissingSex : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileFieldset(
            label: strings.profileSex,
            child: Semantics(
              label: strings.profileSex,
              explicitChildNodes: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  child: Row(
                    spacing: AppSpacing.xxs,
                    children: [
                      for (var index = 0; index < labels.length; index++)
                        Expanded(
                          child: Semantics(
                            checked: index == _sex,
                            inMutuallyExclusiveGroup: true,
                            child: TextButton(
                              key: Key(
                                'profile-sex-${index == 0 ? 'female' : 'male'}',
                              ),
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, AppSizes.backAction),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: index == _sex
                                    ? AppColors.foreground
                                    : AppColors.mutedForeground,
                                backgroundColor: index == _sex
                                    ? AppColors.card
                                    : null,
                                side: index == _sex
                                    ? const BorderSide(color: AppColors.border)
                                    : null,
                                textStyle: AppTypography.setupCaption.copyWith(
                                  fontWeight: index == _sex
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                              onPressed: () {
                                field.didChange(index);
                                setState(() => _sex = index);
                              },
                              child: Text(
                                labels[index],
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (field.errorText case final error?) ProfileFieldError(error),
        ],
      ),
    );
  }

  List<Widget> _targetPage() {
    final strings = _strings;
    final goal = _goal!;
    if (_isTeen) return _teenTargetPage(goal);
    return [
      ProfileStepHeading(
        title: strings.profileTarget,
        subtitle: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.denseGap,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.stepGap,
            children: [
              ExcludeSemantics(
                child: AppIcon.asset(
                  _goalIcon(goal),
                  size: AppSizes.iconInfo,
                  color: AppColors.primary,
                ),
              ),
              Flexible(
                child: Text(
                  '${_goalLabel(goal)} · ${_weight.text.trim()} kg',
                  style: AppTypography.label.copyWith(
                    color: AppColors.secondaryForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _targetSuggestionSection(),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                strings.profileTargetManualTitle,
                style: AppTypography.sectionTitle,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.navLabelGap,
                  ),
                  child: Text(
                    strings.profileTargetManualChip,
                    style: AppTypography.micro.copyWith(
                      color: AppColors.accentForeground,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Form(
            key: _form,
            child: Column(
              spacing: AppSpacing.sm,
              children: [
                ProfileNumberField(
                  label: strings.profileTargetWeight,
                  unit: 'kg',
                  controller: _target,
                  inputKey: const Key('profile-target-weight'),
                  large: true,
                  validator: _validateTarget,
                  onChanged: (_) => setState(() {}),
                ),
                _dateField(),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _estimateCard(),
          const SizedBox(height: AppSpacing.sm),
          Text(
            strings.profileEstimateCaption,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
      ),
    ];
  }

  Widget _targetSuggestionSection() {
    final strings = _strings;
    final current = _positiveNumber(_weight.text);
    final height = _positiveNumber(_height.text);
    if (current == null) return const SizedBox.shrink();
    final suggestions = <(String, double)>[];
    if (_goal == GoalType.lose) {
      final floor = height == null
          ? 0
          : 18.5 * ((height / 100) * (height / 100));
      final starter = (current * 0.95).clamp(floor, current - 0.1).toDouble();
      final longer = (current * 0.90).clamp(floor, current - 0.1).toDouble();
      suggestions.add(('five', starter));
      if (longer < starter - 0.05) {
        suggestions.add(('ten', longer));
      }
    } else if (_goal == GoalType.gain) {
      suggestions.add(('gain', current * 1.05));
    }
    return DecoratedBox(
      key: const Key('profile-target-suggestions'),
      decoration: const ShapeDecoration(
        color: AppColors.secondary,
        shape: AppSquircleBorder(radius: AppRadii.exportCardSquircle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs,
          children: [
            Text(
              strings.profileTargetSuggestionsTitle,
              style: AppTypography.sectionTitle.copyWith(
                color: AppColors.secondaryForeground,
              ),
            ),
            Text(
              strings.profileTargetSuggestionsSubtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.secondaryForeground,
              ),
            ),
            for (final (kind, value) in suggestions)
              _targetSuggestionTile(kind: kind, value: value),
            AppButton.surface(
              key: const Key('profile-target-suggestion-custom'),
              onPressed: () {
                _target.clear();
                setState(() => _targetDate = null);
              },
              child: Text(strings.profileTargetSuggestionCustom),
            ),
            Text(
              strings.profileTargetHelper,
              style: AppTypography.caption.copyWith(
                color: AppColors.secondaryForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _targetSuggestionTile({required String kind, required double value}) {
    final strings = _strings;
    final current = _positiveNumber(_weight.text);
    final estimate = current == null
        ? null
        : estimateAdultGoal(
            goal: _goal!,
            currentWeight: current,
            targetWeight: value,
          );
    final title = switch (kind) {
      'five' => strings.profileTargetSuggestionFive(_formatWeight(value)),
      'ten' => strings.profileTargetSuggestionTen(_formatWeight(value)),
      _ => strings.profileTargetSuggestionGain(_formatWeight(value)),
    };
    final detail = estimate == null
        ? '${_formatWeight(value)} kg'
        : '${_formatWeight(value)} kg · ${_formatDate(estimate.targetDate!)}';
    final pace = estimate == null
        ? null
        : '${strings.profileEstimateWeeks(estimate.weeks)} · ${strings.profileEstimateRateValue(estimate.rateKgPerWeek.toStringAsFixed(2))}';
    final icon = kind == 'ten' ? 'ph-target' : 'ph-plant';
    return Semantics(
      button: true,
      label: '$title, $detail${pace == null ? '' : ', $pace'}',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: Key('profile-target-suggestion-$kind'),
          onTap: () => _applyTargetSuggestion(value),
          customBorder: const AppSquircleBorder(
            radius: AppRadii.exportCardSquircle,
          ),
          child: Ink(
            decoration: const ShapeDecoration(
              color: AppColors.card,
              shape: AppSquircleBorder(
                radius: AppRadii.exportCardSquircle,
                side: BorderSide(color: AppColors.border),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: AppSpacing.sm,
                children: [
                  DecoratedBox(
                    decoration: const ShapeDecoration(
                      color: AppColors.secondary,
                      shape: AppSquircleBorder(
                        radius: AppRadii.exportCardSquircle,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: AppIcon.asset(
                        icon,
                        size: AppSizes.iconMd,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.navLabelGap,
                      children: [
                        Text(title, style: AppTypography.cardTitle),
                        Text(detail, style: AppTypography.setupNumber),
                        if (pace != null)
                          Text(pace, style: AppTypography.caption),
                      ],
                    ),
                  ),
                  const DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: CircleBorder(
                        side: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: SizedBox.square(dimension: AppSizes.iconMd),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _applyTargetSuggestion(double value) {
    _target.text = _formatWeight(value);
    final current = _positiveNumber(_weight.text);
    final target = _positiveNumber(_target.text);
    final estimate = current == null || target == null
        ? null
        : estimateAdultGoal(
            goal: _goal!,
            currentWeight: current,
            targetWeight: target,
          );
    setState(() => _targetDate = estimate?.targetDate);
  }

  String _formatWeight(double value) => value.toStringAsFixed(1);

  List<Widget> _teenTargetPage(GoalType goal) {
    final strings = _strings;
    return [
      ProfileStepHeading(
        title: strings.profileTarget,
        subtitle: Text(
          '${_goalLabel(goal)} · ${_weight.text.trim()} kg',
          style: AppTypography.setupCaption,
        ),
      ),
      const SizedBox(height: AppSpacing.xl),
      _teenGuidanceCard(goal),
      const SizedBox(height: AppSpacing.md),
      Text(
        strings.profileEstimateCaption,
        textAlign: TextAlign.center,
        style: AppTypography.caption,
      ),
    ];
  }

  Widget _teenGuidanceCard(GoalType goal) {
    final status = _teenStatus;
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
      (TeenBmiStatus.healthy, _) => _strings.profileTeenHealthy,
      (TeenBmiStatus.overweight || TeenBmiStatus.obesity, GoalType.lose) =>
        _strings.profileTeenOverweightLose,
      (TeenBmiStatus.overweight || TeenBmiStatus.obesity, _) =>
        _strings.profileTeenOverweightGain,
      _ => _strings.profileTeenHealthy,
    };
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: AppColors.secondary,
        shape: AppSquircleBorder(radius: AppRadii.exportCardSquircle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.sm,
          children: [
            Text(
              _strings.profileTeenGuidanceTitle,
              style: AppTypography.sectionTitle.copyWith(
                color: AppColors.secondaryForeground,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Text(statusLabel, style: AppTypography.label),
              ),
            ),
            Text(
              body,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.secondaryForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField() {
    final strings = _strings;
    return FormField<DateTime>(
      initialValue: _targetDate,
      validator: (value) =>
          value != null && !value.isAfter(DateUtils.dateOnly(DateTime.now()))
          ? strings.profileFutureDate
          : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileFieldCard(
            key: const Key('profile-target-date'),
            label: strings.profileTargetDate,
            onTap: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              final firstDate = _minimumTargetDate();
              final previous = _targetDate;
              final picked = await showDatePicker(
                context: context,
                firstDate: firstDate,
                initialDate: previous == null || previous.isBefore(firstDate)
                    ? firstDate
                    : previous,
                lastDate: DateUtils.addDaysToDate(firstDate, 36500),
              );
              if (!mounted || !field.mounted || picked == null) return;
              field.didChange(picked);
              setState(() => _targetDate = picked);
            },
            child: Row(
              spacing: AppSpacing.xs,
              children: [
                Expanded(
                  child: Text(
                    _targetDate == null
                        ? strings.profilePickDate
                        : _formatDate(_targetDate!),
                    style: AppTypography.cardTitle,
                    semanticsLabel:
                        '${strings.profileTargetDate}, ${_targetDate == null ? strings.profilePickDate : _formatDate(_targetDate!)}',
                  ),
                ),
                const ExcludeSemantics(
                  child: AppIcon.asset(
                    'ph-calendar-blank',
                    size: AppSizes.iconSm,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          if (field.errorText case final error?) ProfileFieldError(error),
        ],
      ),
    );
  }

  DateTime _minimumTargetDate() {
    final now = DateUtils.dateOnly(DateTime.now());
    final current = _positiveNumber(_weight.text);
    final target = _positiveNumber(_target.text);
    if (current == null || target == null || _goal == GoalType.maintain) {
      return DateUtils.addDaysToDate(now, 1);
    }
    final delta = (target - current).abs();
    final maxRate = _goal == GoalType.lose ? 1.0 : current * 0.005;
    final days = (delta / maxRate * 7).ceil().clamp(14, 36500);
    return DateUtils.addDaysToDate(now, days);
  }

  Widget _estimateCard() {
    final current = _positiveNumber(_weight.text);
    final target = _positiveNumber(_target.text);
    final estimate = current == null || target == null
        ? null
        : estimateAdultGoal(
            goal: _goal!,
            currentWeight: current,
            targetWeight: target,
            targetDate: _targetDate,
          );
    final status = switch (estimate?.status) {
      GoalEstimateStatus.recommended => _strings.profileEstimateRecommended,
      GoalEstimateStatus.slower => _strings.profileEstimateSlower,
      GoalEstimateStatus.tooFast => _strings.profileEstimateTooFast,
      GoalEstimateStatus.caution => _strings.profileEstimateCaution,
      null => _strings.profileEstimate,
    };
    final rate = estimate == null
        ? '—'
        : _strings.profileEstimateRateValue(
            estimate.rateKgPerWeek.toStringAsFixed(1),
          );
    return DecoratedBox(
      decoration: const ShapeDecoration(
        color: AppColors.secondary,
        shape: AppSquircleBorder(radius: AppRadii.exportCardSquircle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _strings.profileEstimateRate,
                    style: AppTypography.label.copyWith(
                      color: AppColors.secondaryForeground,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    rate,
                    textAlign: TextAlign.end,
                    style: AppTypography.setupNumber.copyWith(
                      color: AppColors.secondaryForeground,
                    ),
                  ),
                ),
              ],
            ),
            if (estimate != null) ...[
              Text(
                _strings.profileEstimateWeeks(estimate.weeks),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.secondaryForeground,
                ),
              ),
              if (estimate.targetDate != null)
                Text(
                  _strings.profileEstimateDate(
                    _formatDate(estimate.targetDate!),
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryForeground,
                  ),
                ),
            ],
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.navLabelGap,
                  ),
                  child: Text(
                    status,
                    style: AppTypography.micro.copyWith(
                      color: AppColors.accentForeground,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<(String, String)> get _activityOptions => [
    ('ph-armchair', _strings.profileSitting),
    ('ph-footprints', _strings.profileLight),
    ('ph-person-simple-walk', _strings.profileModerate),
    ('ph-barbell', _strings.profileHeavy),
    ('ph-calendar-dots', _strings.profileVariable),
  ];

  List<Widget> _activityPage() => [
    ProfileStepHeading(
      title: _strings.profileActivityHeading,
      subtitle: Text(
        _strings.profileActivityCaption,
        style: AppTypography.setupCaption,
      ),
    ),
    if (_isTeen) ...[
      const SizedBox(height: AppSpacing.md),
      _teenGuidanceCard(GoalType.maintain),
    ],
    const SizedBox(height: AppSpacing.xl),
    Semantics(
      label: _strings.profileActivity,
      explicitChildNodes: true,
      child: Column(
        spacing: AppSpacing.denseGap,
        children: [
          for (final (index, (icon, label)) in _activityOptions.indexed)
            AppSelectionTile(
              icon: icon,
              label: label,
              compact: true,
              selected: _activity == index,
              onPressed: () => setState(() => _activity = index),
            ),
        ],
      ),
    ),
  ];

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

  String _formatDate(DateTime date) =>
      MaterialLocalizations.of(context).formatCompactDate(date);

  double? _positiveNumber(String? value) {
    final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    return number != null && number.isFinite && number > 0 ? number : null;
  }

  String? _validateNumber(String? value) =>
      _positiveNumber(value) == null ? _strings.profileInvalidNumber : null;

  String? _validateTarget(String? value) {
    final target = _positiveNumber(value);
    final current = _positiveNumber(_weight.text)!;
    if (target == null) return _strings.profileInvalidNumber;
    if (_goal == GoalType.lose && target >= current) {
      return _strings.profileLowerTarget;
    }
    if (_goal == GoalType.gain && target <= current) {
      return _strings.profileHigherTarget;
    }
    if (_goal == GoalType.lose) {
      final height = _positiveNumber(_height.text);
      if (height != null && target / ((height / 100) * (height / 100)) < 18.5) {
        return _strings.profileTargetBelowHealthy;
      }
      final estimate = estimateAdultGoal(
        goal: _goal!,
        currentWeight: current,
        targetWeight: target,
        targetDate: _targetDate,
      );
      if (estimate?.status == GoalEstimateStatus.tooFast) {
        return _strings.profileEstimateTooFast;
      }
    }
    return null;
  }

  void _back() => _show(switch (_step) {
    _Step.activity => _maintaining ? _Step.body : _Step.target,
    _Step.target => _Step.body,
    _ => _Step.goal,
  });

  void _show(_Step step) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _step = step);
  }

  Future<void> _advance() async {
    final form = _form.currentState;
    if (form != null && !form.validate()) return;
    switch (_step) {
      case _Step.goal:
        _show(_Step.body);
      case _Step.body:
        _show(_maintaining ? _Step.activity : _Step.target);
      case _Step.target:
        _show(_Step.activity);
      case _Step.activity:
        await _review();
    }
  }

  Future<void> _review() async {
    final strings = _strings;
    setState(() {
      _reviewing = true;
      _saveFailed = false;
    });
    try {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.profileReview),
          scrollable: true,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.xs,
            children: [
              Text(_goalLabel(_goal!), style: AppTypography.cardTitle),
              Text(
                '${strings.profileAge} · ${_age.text.trim()} ${strings.profileYears}',
              ),
              Text('${strings.profileHeight} · ${_height.text.trim()} cm'),
              Text(
                '${strings.profileCurrentWeight} · ${_weight.text.trim()} kg',
              ),
              Text(
                '${strings.profileSex} · ${_sex == 0 ? strings.profileFemale : strings.profileMale}',
              ),
              if (!_maintaining && !_isTeen) ...[
                Text(
                  '${strings.profileTargetWeight} · ${_target.text.trim()} kg',
                ),
                if (_targetDate != null)
                  Text(
                    '${strings.profileTargetDate} · ${_formatDate(_targetDate!)}',
                  ),
              ],
              if (_isTeen) Text(strings.profileTeenGuidanceTitle),
              Text(_activityOptions[_activity!].$2),
              Text(strings.profileReviewNotice, style: AppTypography.caption),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.profileBack),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.backToToday),
            ),
          ],
        ),
      );
      if (!mounted || proceed != true) return;
      final now = DateTime.now();
      final profile = Profile(
        ageYears: int.parse(_age.text.trim()),
        heightCm: _positiveNumber(_height.text)!,
        sex: ProfileSex.values[_sex!],
        activityLevel: ActivityLevel.values[_activity!],
        goal: Goal(
          type: _goal!,
          currentWeight: _positiveNumber(_weight.text),
          targetWeight: _maintaining || _isTeen
              ? null
              : _positiveNumber(_target.text),
          targetDate: _maintaining || _isTeen ? null : _targetDate,
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
