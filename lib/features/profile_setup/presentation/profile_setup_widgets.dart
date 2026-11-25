import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Progress marks for the four setup steps after the glass back control
/// (`size-11`, `gap-4`); the current mark wears a `ring-4 ring-secondary`.
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

  static const _targetInset = (AppSizes.action - AppSizes.glassControl) / 2;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Row(
      children: [
        Transform.translate(
          // The 56 dp target keeps the 44 dp glass circle on the page edge.
          offset: const Offset(-_targetInset, 0),
          child: AppNavigationButton.back(
            tooltip: strings.profileBack,
            onPressed: onBack,
          ),
        ),
        // `gap-4` from the visible circle, less the shifted touch target.
        const SizedBox(width: AppSpacing.md - _targetInset * 2),
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
                      current: index == step,
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

/// Step heading from every setup export: the 64 dp mascot tile
/// (`size-16 rounded-2xl bg-secondary p-1`) beside the `text-3xl` title.
class ProfileStepHeading extends StatelessWidget {
  const ProfileStepHeading({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Row(
    spacing: AppSpacing.md,
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
      Expanded(
        child: Semantics(
          header: true,
          child: Text(title, style: AppTypography.setupHeading),
        ),
      ),
    ],
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
        // Stacked cards keep the unit right after the number (`w-16` input,
        // `gap-1`); the inline age value fills its slot, right-aligned.
        if (widget.inline)
          Expanded(child: input)
        else
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.textScalerOf(context).scale(64),
              ),
              child: IntrinsicWidth(child: input),
            ),
          ),
        if (widget.unit case final unit?)
          ExcludeSemantics(
            child: Text(unit, style: AppTypography.setupCaption),
          ),
      ],
    );
    // Part of the field for tap-outside: tapping the card focuses it
    // instead of closing the keyboard first. Focus fades in the
    // `focus-within:ring-2 ring-ring` outline over the glass; the fill stays.
    final card = TextFieldTapRegion(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          AppGlassCard(
            onPressed: _focus.requestFocus,
            pressedScale: 1,
            child: widget.inline
                ? Row(
                    spacing: AppSpacing.md,
                    children: [
                      AppIconWell(icon: widget.icon),
                      Expanded(child: label),
                      SizedBox(width: AppSizes.setupBadgeMax / 2, child: value),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.sm,
                    children: [
                      AppIconWell(icon: widget.icon),
                      label,
                      value,
                    ],
                  ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _focus.hasFocus ? 1 : 0,
                duration: AppMotion.of(context, AppMotion.selection),
                curve: AppMotion.selectionCurve,
                child: const DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: AppSquircleBorder(
                      radius: AppRadii.glassCard,
                      side: BorderSide(
                        color: AppColors.primary,
                        width: AppChoice.strokeWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

/// A tinted icon circle: `size-9` with an 18 px icon on the tiles.
class ProfileIconCircle extends StatelessWidget {
  const ProfileIconCircle({
    super.key,
    required this.icon,
    required this.background,
    required this.color,
    this.dimension = AppSizes.planTileIcon,
    this.iconSize = AppSizes.iconSm,
  });

  final String icon;
  final Color background;
  final Color color;
  final double dimension;
  final double iconSize;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: dimension,
    child: DecoratedBox(
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Center(
        child: AppIcon.asset(icon, size: iconSize, color: color),
      ),
    ),
  );
}
