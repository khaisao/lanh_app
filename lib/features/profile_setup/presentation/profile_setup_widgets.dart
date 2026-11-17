import 'package:app_ui/app_ui.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

const _cardShape = AppSquircleBorder(
  radius: AppRadii.exportCardSquircle,
  side: BorderSide(color: AppColors.border),
);

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
          IconButton(
            tooltip: strings.profileBack,
            onPressed: onBack,
            style: IconButton.styleFrom(
              foregroundColor: AppColors.foreground,
              fixedSize: const Size.square(AppSizes.compactAction),
              minimumSize: const Size.square(AppSizes.compactAction),
              padding: EdgeInsets.zero,
            ),
            icon: const Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox.square(
                dimension: AppSizes.avatar,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.card,
                    border: Border.fromBorderSide(
                      BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Center(
                    child: AppIcon.asset(
                      'ph-arrow-left',
                      size: AppSizes.iconSm,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        Expanded(
          child: Semantics(
            label: strings.profileStepStatus(step + 1),
            explicitChildNodes: true,
            child: Transform.translate(
              offset: Offset(0, step > 0 ? -AppSpacing.xxs : 0),
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
    final mark = Container(
      height: AppSpacing.stepGap,
      decoration: BoxDecoration(
        color: attained ? AppColors.primary : AppColors.muted,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: current
            ? const [
                BoxShadow(
                  color: AppColors.secondary,
                  spreadRadius: AppSpacing.xxs,
                ),
              ]
            : null,
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

class ProfileStepHeading extends StatelessWidget {
  const ProfileStepHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.hero = false,
  });

  final String title;
  final Widget subtitle;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final heading = Semantics(
      header: true,
      child: Text(title, style: AppTypography.setupHeading),
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
          subtitle,
        ],
      );
    }
    return Row(
      children: [
        const DecoratedBox(
          decoration: ShapeDecoration(
            color: AppColors.secondary,
            shape: AppSquircleBorder(radius: AppRadii.exportCardSquircle),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxs),
            child: AppMascot(size: AppSizes.nav - 2 * AppSpacing.xxs),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xxs,
            children: [heading, subtitle],
          ),
        ),
      ],
    );
  }
}

class ProfileFieldCard extends StatefulWidget {
  const ProfileFieldCard({
    super.key,
    required this.label,
    required this.child,
    this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<ProfileFieldCard> createState() => _ProfileFieldCardState();
}

class _ProfileFieldCardState extends State<ProfileFieldCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final shape = _focused
        ? _cardShape.copyWith(
            side: const BorderSide(
              color: AppColors.primary,
              width: AppBorders.selected,
            ),
          )
        : _cardShape;
    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.md + AppBorders.hairline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.xxs,
        children: [
          ExcludeSemantics(
            child: Text(widget.label, style: AppTypography.setupFieldLabel),
          ),
          widget.child,
        ],
      ),
    );
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: DecoratedBox(
        decoration: ShapeDecoration(color: AppColors.card, shape: shape),
        child: widget.onTap == null
            ? content
            : Material(
                type: MaterialType.transparency,
                child: InkWell(
                  customBorder: shape,
                  onTap: widget.onTap,
                  child: content,
                ),
              ),
      ),
    );
  }
}

class ProfileNumberField extends StatelessWidget {
  const ProfileNumberField({
    super.key,
    required this.label,
    required this.unit,
    required this.controller,
    required this.validator,
    this.whole = false,
    this.large = false,
  });

  final String label;
  final String unit;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final bool whole;
  final bool large;

  @override
  Widget build(BuildContext context) => FormField<String>(
    initialValue: controller.text,
    validator: validator,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    builder: (field) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileFieldCard(
          label: label,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: AppSpacing.xxs,
            children: [
              Expanded(
                child: Semantics(
                  label: '$label ($unit)',
                  child: TextField(
                    controller: controller,
                    onChanged: field.didChange,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: !whole,
                    ),
                    textInputAction: TextInputAction.done,
                    style: large
                        ? AppTypography.setupTargetNumber
                        : AppTypography.setupNumber,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              ExcludeSemantics(
                child: Text(
                  unit,
                  style: large
                      ? AppTypography.setupCaption
                      : AppTypography.navLabel,
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

class ProfileFieldError extends StatelessWidget {
  const ProfileFieldError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xxs),
    child: Semantics(
      liveRegion: true,
      child: Text(message, style: AppTypography.error),
    ),
  );
}

class ProfileFieldset extends StatelessWidget {
  const ProfileFieldset({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: DecoratedBox(
          decoration: const ShapeDecoration(
            color: AppColors.card,
            shape: _cardShape,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md + AppBorders.hairline,
              AppSpacing.md + AppSpacing.denseGap + AppBorders.hairline,
              AppSpacing.md + AppBorders.hairline,
              AppSpacing.md + AppBorders.hairline,
            ),
            child: child,
          ),
        ),
      ),
      PositionedDirectional(
        start: AppSpacing.md + AppBorders.hairline,
        top: 0,
        child: ExcludeSemantics(
          child: ColoredBox(
            color: AppColors.background,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              child: Text(
                label,
                style: AppTypography.setupFieldLabel.copyWith(height: 16 / 12),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
