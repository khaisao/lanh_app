part of '../app_ui.dart';

enum _AppButtonKind { primary, card, secondary, surface }

/// The app's single action button. Pass [label] (with optional [leadingIcon],
/// [trailingIcon] or [loading]) for the standard text/icon layouts so a design
/// change here reaches every button; use [child] only for content a label and
/// icons cannot express. Set [fullWidth] for Sleek's `w-full` actions.
///
/// Default (primary) follows Sleek Profile Setup / Plan Ready:
/// `min-h-14 py-4 rounded-full bg-primary font-semibold shadow-lg
/// shadow-primary/25 gap-2 active:scale-[0.97]`, 18 px icons.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
    this.animatePress = true,
    this.showShadow = true,
  }) : assert(
         (child == null) != (label == null),
         'Pass exactly one of child or label.',
       ),
       _kind = _AppButtonKind.primary;

  /// Primary action inside a Today card (Sleek Today First Run / Today Empty):
  /// `rounded-2xl`, no shadow, 20 px icons, `active:scale-[0.98]`.
  const AppButton.card({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
    this.animatePress = true,
    this.showShadow = true,
  }) : assert(
         (child == null) != (label == null),
         'Pass exactly one of child or label.',
       ),
       _kind = _AppButtonKind.card;
  const AppButton.secondary({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
    this.animatePress = true,
    this.showShadow = true,
  }) : assert(
         (child == null) != (label == null),
         'Pass exactly one of child or label.',
       ),
       _kind = _AppButtonKind.secondary;

  /// The translucent card action in photo-meal-flow.html.
  const AppButton.surface({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
    this.animatePress = true,
    this.showShadow = true,
  }) : assert(
         (child == null) != (label == null),
         'Pass exactly one of child or label.',
       ),
       _kind = _AppButtonKind.surface;
  final VoidCallback? onPressed;

  /// Custom content. Prefer [label]; see [AppButtonLabel] for switching labels.
  final Widget? child;
  final String? label;

  /// Asset name from the design icon set, e.g. `ph-check-bold`.
  final String? leadingIcon;
  final String? trailingIcon;

  /// Replaces [leadingIcon] with a spinner. Does not disable the button.
  final bool loading;

  /// Stretches to the available width (Sleek `w-full`). Leave false inside
  /// unbounded parents such as [Wrap] or a [Row] without [Expanded].
  final bool fullWidth;
  final _AppButtonKind _kind;

  /// Scales down while pressed; skipped under Reduce Motion.
  final bool animatePress;

  /// Primary pill elevation. Voice Meal Confirm v9 uses a flat pill inside
  /// its already raised dock; other primary actions retain their shadow.
  final bool showShadow;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final duration = widget.animatePress
        ? AppMotion.feedbackDuration(context)
        : Duration.zero;
    final card = widget._kind == _AppButtonKind.card;
    final OutlinedBorder shape = card
        ? const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
          )
        : const StadiumBorder();
    Widget button = FilledButton(
      onPressed: widget.onPressed,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, AppSizes.action)),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (widget._kind == _AppButtonKind.surface) {
            return AppColors.card.withValues(alpha: 0.6);
          }
          return widget._kind == _AppButtonKind.secondary ||
                  states.contains(WidgetState.disabled)
              ? AppColors.secondary
              : AppColors.primary;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (widget._kind == _AppButtonKind.surface) {
            return AppColors.foreground;
          }
          return widget._kind == _AppButtonKind.secondary ||
                  states.contains(WidgetState.disabled)
              ? AppColors.secondaryForeground
              : AppColors.primaryForeground;
        }),
        side: widget._kind == _AppButtonKind.surface
            ? WidgetStatePropertyAll(
                BorderSide(color: AppColors.card.withValues(alpha: 0.8)),
              )
            : null,
        textStyle: const WidgetStatePropertyAll(AppTypography.cardTitle),
        shape: WidgetStatePropertyAll(shape),
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: AppSpacing.card,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      child:
          widget.child ??
          AppButtonLabel(
            widget.label!,
            leadingIcon: widget.leadingIcon,
            trailingIcon: widget.trailingIcon,
            loading: widget.loading,
            iconSize: card ? AppSizes.buttonIconCard : AppSizes.buttonIcon,
          ),
    );
    if (widget._kind == _AppButtonKind.primary &&
        widget.onPressed != null &&
        widget.showShadow) {
      button = DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          shadows: AppShadows.primaryAction,
        ),
        child: button,
      );
    }
    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }
    if (duration == Duration.zero || widget.onPressed == null) return button;
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed
            ? (card ? AppScales.pressedCard : AppScales.pressed)
            : 1,
        duration: duration,
        curve: Curves.fastOutSlowIn,
        child: button,
      ),
    );
  }
}

/// Text with an optional leading and trailing icon, tinted with the enclosing
/// button's foreground (including its disabled colour).
class AppButtonLabel extends StatelessWidget {
  const AppButtonLabel(
    this.label, {
    super.key,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.iconSize = AppSizes.buttonIcon,
  });

  final String label;
  final double iconSize;
  final String? leadingIcon;
  final String? trailingIcon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final color = DefaultTextStyle.of(context).style.color;
    Widget icon(String name) => ExcludeSemantics(
      child: AppIcon.asset(name, size: iconSize, color: color),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        if (loading)
          SizedBox.square(
            dimension: iconSize,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        else if (leadingIcon case final name?)
          icon(name),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        ),
        if (trailingIcon case final name?) icon(name),
      ],
    );
  }
}
