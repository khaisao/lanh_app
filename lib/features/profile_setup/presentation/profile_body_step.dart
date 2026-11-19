import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/body_metrics.dart';
import '../domain/profile.dart';
import 'profile_bmi_card.dart';
import 'profile_setup_widgets.dart';

/// Field identifiers used for validation messages on the body step.
enum ProfileBodyField { age, height, weight, sex }

/// The "Về bạn" step from Body Direction 2 – Measure Cards: glass cards for
/// age, height, weight and sex, then the BMI ring card once all are filled.
class ProfileBodyStep extends StatelessWidget {
  const ProfileBodyStep({
    super.key,
    required this.age,
    required this.height,
    required this.weight,
    required this.sex,
    required this.errors,
    required this.onEdited,
    required this.onSex,
    required this.pregnant,
    required this.onPregnant,
  });

  final TextEditingController age;
  final TextEditingController height;
  final TextEditingController weight;
  final ProfileSex? sex;
  final Map<ProfileBodyField, String> errors;
  final ValueChanged<ProfileBodyField> onEdited;
  final ValueChanged<ProfileSex> onSex;

  /// Pregnancy or breastfeeding: asked only of adult women, never saved, and
  /// turns off Lành's automatic kcal and weight targets.
  final bool pregnant;
  final ValueChanged<bool> onPregnant;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final stacked = MediaQuery.textScalerOf(context).scale(12) > 18;
    final heightCard = ProfileMeasureCard(
      key: const Key('profile-height'),
      icon: 'ph-ruler',
      label: strings.profileHeight,
      unit: 'cm',
      controller: height,
      inputAction: TextInputAction.next,
      error: errors[ProfileBodyField.height],
      onChanged: (_) => onEdited(ProfileBodyField.height),
    );
    final weightCard = ProfileMeasureCard(
      key: const Key('profile-current-weight'),
      icon: 'ph-scales',
      label: strings.profileCurrentWeight,
      unit: 'kg',
      controller: weight,
      error: errors[ProfileBodyField.weight],
      onChanged: (_) => onEdited(ProfileBodyField.weight),
    );
    final ageValue = int.tryParse(age.text.trim());
    final teen =
        ageValue != null &&
        ageValue >= BodyLimits.minAge &&
        ageValue < BodyLimits.adultAge;
    var order = 0;
    // Cards rise in one after another; keys keep a card's entrance from
    // replaying when the pregnancy card appears or disappears above it.
    Widget enter(String id, Widget child) =>
        AppEntrance(key: ValueKey(id), index: order++, child: child);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.card,
      children: [
        enter(
          'heading',
          ProfileStepHeading(
            title: strings.profileBody,
            subtitle: strings.profileBodyTapCaption,
          ),
        ),
        enter(
          'age',
          ProfileMeasureCard(
            key: const Key('profile-age'),
            icon: 'ph-calendar-blank',
            label: strings.profileAge,
            controller: age,
            whole: true,
            inputAction: TextInputAction.next,
            inline: true,
            error: errors[ProfileBodyField.age],
            onChanged: (_) => onEdited(ProfileBodyField.age),
          ),
        ),
        if (stacked) ...[
          enter('height', heightCard),
          enter('weight', weightCard),
        ] else
          enter(
            'measures',
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.sm,
              children: [
                Expanded(child: heightCard),
                Expanded(child: weightCard),
              ],
            ),
          ),
        enter(
          'sex',
          _SexChoice(
            sex: sex,
            stacked: stacked,
            onSex: onSex,
            error: errors[ProfileBodyField.sex],
          ),
        ),
        if (sex == ProfileSex.female && !teen)
          enter(
            'pregnancy',
            AppGlassCard(
              key: const Key('profile-pregnancy'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              // Own Material so the tile's ink shows above the glass fill.
              child: Material(
                type: MaterialType.transparency,
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: pregnant,
                  onChanged: onPregnant,
                  title: Text(
                    strings.profilePregnancyLabel,
                    style: AppTypography.cardTitle,
                  ),
                  subtitle: Text(
                    strings.profilePregnancyHint,
                    style: AppTypography.caption,
                  ),
                ),
              ),
            ),
          ),
        // Appears once every value is in, below the inputs, so nothing the
        // user is editing moves.
        ProfileBmiReveal(
          key: const ValueKey('bmi'),
          ageYears: ageValue,
          heightCm: parsePositiveNumber(height.text),
          weightKg: parsePositiveNumber(weight.text),
          sex: sex,
        ),
        enter(
          'caption',
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            child: Text(
              teen ? strings.profileBmiTeenHint : strings.profileReadingAdult,
              style: AppTypography.caption,
            ),
          ),
        ),
      ],
    );
  }
}

/// Parses a typed decimal that may use a comma separator. Missing, zero,
/// negative and non-finite values return null; missing data is not zero.
double? parsePositiveNumber(String? value) {
  final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
  return number != null && number.isFinite && number > 0 ? number : null;
}

class _SexChoice extends StatelessWidget {
  const _SexChoice({
    required this.sex,
    required this.stacked,
    required this.onSex,
    required this.error,
  });

  final ProfileSex? sex;
  final bool stacked;
  final ValueChanged<ProfileSex> onSex;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final tiles = [
      for (final (value, icon, label, accent) in [
        (
          ProfileSex.female,
          'ph-gender-female-light',
          strings.profileFemale,
          AppColors.chartPeach,
        ),
        (
          ProfileSex.male,
          'ph-gender-male-light',
          strings.profileMale,
          AppColors.chartBlue,
        ),
      ])
        _SexTile(
          key: Key('profile-sex-${value.name}'),
          icon: icon,
          label: label,
          accent: accent,
          selected: value == sex,
          onPressed: () {
            if (value != sex) HapticFeedback.selectionClick();
            onSex(value);
          },
        ),
    ];
    // Body Direction 2 – Measure Cards: one glass card titled "Giới tính"
    // holding both choices, each tinted with its own chart colour.
    return Semantics(
      label: strings.profileSex,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppGlassCard(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.xs,
                    AppSpacing.sm,
                    AppSpacing.xs,
                  ),
                  child: ExcludeSemantics(
                    child: Text(
                      strings.profileSex,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (stacked)
                  Column(spacing: AppSpacing.xs, children: tiles)
                else
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacing.xs,
                      children: [
                        for (final tile in tiles) Expanded(child: tile),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (error case final message?) ProfileFieldError(message),
        ],
      ),
    );
  }
}

/// One sex choice: a tinted icon circle and the label. When chosen the tile
/// fills with `accent/35` and an `accent/70` outline and the circle turns
/// solid with a soft glow; screen readers hear the checked state.
/// Changes cross-fade; the tile presses to 0.97 with no ripple.
class _SexTile extends StatefulWidget {
  const _SexTile({
    super.key,
    required this.icon,
    required this.label,
    required this.accent,
    required this.selected,
    required this.onPressed,
  });

  final String icon;
  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_SexTile> createState() => _SexTileState();
}

class _SexTileState extends State<_SexTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.selection);
    final selected = widget.selected;
    final accent = widget.accent;
    final highContrast = MediaQuery.highContrastOf(context);
    final shape = AppSquircleBorder(
      radius: AppRadii.glassInner,
      side: BorderSide(
        color: selected
            ? accent.withValues(alpha: highContrast ? 1 : 0.7)
            : const Color(0x00FFFFFF),
        width: selected && highContrast ? AppBorders.selected : 1,
      ),
    );
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed && duration != Duration.zero ? AppScales.pressed : 1,
          duration: _pressed
              ? AppMotion.feedbackPress
              : AppMotion.feedbackRelease,
          curve: AppMotion.feedbackCurve,
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.selectionCurve,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: ShapeDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.35)
                  : const Color(0x00FFFFFF),
              shape: shape,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: AppSpacing.sm,
              children: [
                AnimatedScale(
                  scale: selected && duration != Duration.zero ? 1.06 : 1,
                  duration: AppMotion.of(context, AppMotion.selectionPop),
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: duration,
                    curve: AppMotion.selectionCurve,
                    width: AppSizes.sexChoiceCircle,
                    height: AppSizes.sexChoiceCircle,
                    decoration: ShapeDecoration(
                      color: accent.withValues(alpha: selected ? 1 : 0.3),
                      shape: const CircleBorder(
                        side: BorderSide(color: AppGlass.edge),
                      ),
                      shadows: [
                        BoxShadow(
                          color: accent.withValues(alpha: selected ? 0.4 : 0),
                          blurRadius: 6,
                          spreadRadius: -1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AppIcon.asset(
                        widget.icon,
                        size: AppSizes.sexChoiceIcon,
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                ),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: AppTypography.cardTitle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
