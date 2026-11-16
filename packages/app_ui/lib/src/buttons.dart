part of '../app_ui.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.roundedRectangle = false,
  }) : _secondary = false;
  const AppButton.secondary({
    super.key,
    required this.onPressed,
    required this.child,
  }) : _secondary = true,
       roundedRectangle = false;
  final VoidCallback? onPressed;
  final Widget child;
  final bool _secondary;
  final bool roundedRectangle;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, AppSizes.action)),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => _secondary || states.contains(WidgetState.disabled)
            ? AppColors.secondary
            : AppColors.primary,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => _secondary || states.contains(WidgetState.disabled)
            ? AppColors.secondaryForeground
            : AppColors.primaryForeground,
      ),
      textStyle: const WidgetStatePropertyAll(AppTypography.cardTitle),
      shape: WidgetStatePropertyAll(
        roundedRectangle
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
    child: child,
  );
}
