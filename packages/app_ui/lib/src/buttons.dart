part of '../app_ui.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.roundedRectangle = false,
    this.animatePress = false,
  }) : _secondary = false;
  const AppButton.secondary({
    super.key,
    required this.onPressed,
    required this.child,
  }) : _secondary = true,
       roundedRectangle = false,
       animatePress = false;
  final VoidCallback? onPressed;
  final Widget child;
  final bool _secondary;
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
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => widget._secondary || states.contains(WidgetState.disabled)
              ? AppColors.secondary
              : AppColors.primary,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => widget._secondary || states.contains(WidgetState.disabled)
              ? AppColors.secondaryForeground
              : AppColors.primaryForeground,
        ),
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
