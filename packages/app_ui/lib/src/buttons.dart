part of '../app_ui.dart';

enum _AppButtonKind { primary, secondary, surface }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.roundedRectangle = false,
    this.animatePress = false,
  }) : _kind = _AppButtonKind.primary;
  const AppButton.secondary({
    super.key,
    required this.onPressed,
    required this.child,
  }) : _kind = _AppButtonKind.secondary,
       roundedRectangle = false,
       animatePress = false;

  /// The translucent card action in photo-meal-flow.html.
  const AppButton.surface({
    super.key,
    required this.onPressed,
    required this.child,
  }) : _kind = _AppButtonKind.surface,
       roundedRectangle = false,
       animatePress = false;
  final VoidCallback? onPressed;
  final Widget child;
  final _AppButtonKind _kind;
  final bool roundedRectangle;
  final bool animatePress;

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
    final button = FilledButton(
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
        shape: WidgetStatePropertyAll(
          widget.roundedRectangle
              ? const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
                )
              : const StadiumBorder(),
        ),
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: AppSpacing.card,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
      child: widget.child,
    );
    if (duration == Duration.zero || widget.onPressed == null) return button;
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? AppScales.pressed : 1,
        duration: duration,
        curve: Curves.fastOutSlowIn,
        child: button,
      ),
    );
  }
}
