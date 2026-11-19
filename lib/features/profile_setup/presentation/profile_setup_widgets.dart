import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Progress marks for the four setup steps, with the glass back control from
/// the Body/Target exports on every step after the first.
class ProfileStepBar extends StatelessWidget {
  const ProfileStepBar({
    super.key,
    required this.step,
    required this.titles,
    required this.onStep,
    required this.onBack,
  });

  final int step;
  final List<String> titles;
  final ValueChanged<int> onStep;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Row(
      children: [
        if (step > 0) ...[
          Transform.translate(
            // The 56 dp target keeps the 44 dp glass circle on the page edge.
            offset: const Offset(
              -(AppSizes.action - AppSizes.glassControl) / 2,
              0,
            ),
            child: AppGlassIconButton(
              icon: 'ph-arrow-left',
              tooltip: strings.profileBack,
              color: AppColors.foreground,
              iconSize: AppSizes.iconSm,
              onPressed: onBack,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        Expanded(
          child: Semantics(
            label: strings.profileStepStatus(step + 1),
            explicitChildNodes: true,
            child: Row(
              spacing: AppSpacing.stepGap,
              children: [
                for (var index = 0; index < titles.length; index++)
                  Expanded(
                    child: _StepMark(
                      attained: index <= step,
                      current: index == step && step > 0,
                      label: strings.profileEditStep(titles[index]),
                      onTap: index < step ? () => onStep(index) : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepMark extends StatelessWidget {
  const _StepMark({
    required this.attained,
    required this.current,
    required this.label,
    required this.onTap,
  });

  final bool attained;
  final bool current;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // The primary fill grows across the muted track as a step is reached
    // and shrinks back when the user returns; the current step's halo fades.
    final mark = AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.progressFill),
      curve: Curves.easeInOutCubic,
      height: AppSpacing.stepGap,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: [
          BoxShadow(
            color: current ? AppColors.secondary : const Color(0x00FFFFFF),
            spreadRadius: AppSpacing.xxs,
          ),
        ],
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: attained ? 1 : 0),
        duration: AppMotion.of(context, AppMotion.progressFill),
        curve: Curves.easeInOutCubic,
        builder: (context, fill, _) => FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: fill,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(AppRadii.pill)),
            ),
          ),
        ),
      ),
    );
    if (onTap == null) return mark;
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: SizedBox(
          height: AppSizes.avatar,
          child: Center(child: mark),
        ),
      ),
    );
  }
}

/// Step heading: the bouncing hero mascot on the goal step, or the 64 dp
/// mascot tile beside the title on later steps.
class ProfileStepHeading extends StatelessWidget {
  const ProfileStepHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.hero = false,
  });

  final String title;
  final String subtitle;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final heading = Semantics(
      header: true,
      child: Text(
        title,
        style: AppTypography.setupHeading,
        textAlign: hero ? TextAlign.center : TextAlign.start,
      ),
    );
    final caption = Text(
      subtitle,
      style: AppTypography.setupCaption,
      textAlign: hero ? TextAlign.center : TextAlign.start,
    );
    if (hero) {
      return Column(
        children: [
          const SizedBox.square(
            dimension: AppSizes.setupMascot,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                OverflowBox(
                  minWidth: AppSizes.setupMascotHalo,
                  maxWidth: AppSizes.setupMascotHalo,
                  minHeight: AppSizes.setupMascotHalo,
                  maxHeight: AppSizes.setupMascotHalo,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                AppMascot(size: AppSizes.setupMascot, bounce: true),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          heading,
          const SizedBox(height: AppSpacing.xs),
          caption,
        ],
      );
    }
    return Row(
      children: [
        const DecoratedBox(
          decoration: ShapeDecoration(
            color: AppColors.secondary,
            shape: AppSquircleBorder(radius: AppRadii.glassInner),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxs),
            child: AppMascot(size: AppSizes.avatarLarge),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xxs,
            children: [heading, caption],
          ),
        ),
      ],
    );
  }
}

/// A 40 dp secondary icon well (`size-10 rounded-2xl bg-secondary`).
class ProfileIconWell extends StatelessWidget {
  const ProfileIconWell(this.icon, {super.key});

  final String icon;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: AppSizes.avatar,
      child: DecoratedBox(
        decoration: const ShapeDecoration(
          color: AppColors.secondary,
          shape: AppSquircleBorder(radius: AppRadii.exportCompactSquircle),
        ),
        child: Center(
          child: AppIcon.asset(
            icon,
            size: AppSizes.iconMd,
            color: AppColors.secondaryForeground,
          ),
        ),
      ),
    ),
  );
}

/// Glass measurement card from Body Direction 2: tap anywhere to type the
/// value. [inline] lays the label and value in one row (age); otherwise the
/// icon, label and value stack (height, weight).
final _decimal = RegExp(r'^\d{0,3}([.,]\d?)?$');

class ProfileMeasureCard extends StatefulWidget {
  const ProfileMeasureCard({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.unit,
    this.whole = false,
    this.inputAction = TextInputAction.done,
    this.inline = false,
    this.error,
  });

  final String icon;
  final String label;
  final String? unit;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool whole;

  /// "Next" moves the keyboard to the following field; the last one is done.
  final TextInputAction inputAction;
  final bool inline;
  final String? error;

  @override
  State<ProfileMeasureCard> createState() => _ProfileMeasureCardState();
}

class _ProfileMeasureCardState extends State<ProfileMeasureCard> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = widget.unit == null
        ? widget.label
        : '${widget.label}, ${widget.unit}';
    final input = Semantics(
      label: semanticsLabel,
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        onChanged: widget.onChanged,
        textAlign: widget.inline ? TextAlign.end : TextAlign.start,
        keyboardType: TextInputType.numberWithOptions(decimal: !widget.whole),
        // Whole: up to 3 digits. Decimal: up to 3 digits, one separator
        // (comma or dot) and one decimal, so "6,1,5" or ",," never appear.
        inputFormatters: [
          widget.whole
              ? FilteringTextInputFormatter.digitsOnly
              : TextInputFormatter.withFunction(
                  (old, next) => _decimal.hasMatch(next.text) ? next : old,
                ),
          LengthLimitingTextInputFormatter(widget.whole ? 3 : 5),
        ],
        textInputAction: widget.inputAction,
        style: AppTypography.setupNumber,
        decoration: const InputDecoration(
          isCollapsed: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
    final label = ExcludeSemantics(
      child: Text(
        widget.label,
        style: AppTypography.label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final value = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      spacing: AppSpacing.xxs,
      children: [
        Expanded(child: input),
        if (widget.unit case final unit?)
          ExcludeSemantics(
            child: Text(unit, style: AppTypography.setupCaption),
          ),
      ],
    );
    // Part of the field for tap-outside: tapping the card focuses it
    // instead of closing the keyboard first.
    final card = TextFieldTapRegion(
      child: AppGlassCard(
        tone: _focus.hasFocus ? AppGlassTone.selected : AppGlassTone.glass,
        onPressed: _focus.requestFocus,
        pressedScale: 1,
        // Focus only fades the outline in: no tinted fill, no pop.
        fill: AppGlass.fill,
        popOnSelect: false,
        child: widget.inline
            ? Row(
                spacing: AppSpacing.md,
                children: [
                  ProfileIconWell(widget.icon),
                  Expanded(child: label),
                  SizedBox(width: AppSizes.setupBadgeMax / 2, child: value),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.sm,
                children: [ProfileIconWell(widget.icon), label, value],
              ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card,
        if (widget.error case final error?) ProfileFieldError(error),
      ],
    );
  }
}

class ProfileFieldError extends StatelessWidget {
  const ProfileFieldError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(
      start: AppSpacing.xxs,
      top: AppSpacing.xxs,
    ),
    child: Semantics(
      liveRegion: true,
      child: Text(message, style: AppTypography.error),
    ),
  );
}
