part of '../app_ui.dart';

/// Sleek's circular back/close control. Features supply only the translated
/// label and action; appearance and glyphs are owned by the design system.
class AppNavigationButton extends StatefulWidget {
  const AppNavigationButton.back({
    super.key,
    required this.tooltip,
    required this.onPressed,
  }) : _icon = 'ph-caret-left';

  const AppNavigationButton.close({
    super.key,
    required this.tooltip,
    required this.onPressed,
  }) : _icon = 'ph-x';

  final String tooltip;
  final VoidCallback? onPressed;
  final String _icon;

  @override
  State<AppNavigationButton> createState() => _AppNavigationButtonState();
}

class _AppNavigationButtonState extends State<AppNavigationButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Tooltip(
      message: widget.tooltip,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        enabled: widget.onPressed != null,
        label: widget.tooltip,
        child: InkResponse(
          onTap: widget.onPressed,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          radius: AppNavigation.targetSize / 2,
          child: SizedBox.square(
            dimension: AppNavigation.targetSize,
            child: Center(
              child: AnimatedScale(
                scale: _pressed && !reduceMotion
                    ? AppNavigation.pressedScale
                    : 1,
                duration: reduceMotion ? Duration.zero : AppNavigation.duration,
                child: Container(
                  width: AppNavigation.visualSize,
                  height: AppNavigation.visualSize,
                  decoration: BoxDecoration(
                    color: AppNavigation.fill,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppNavigation.border),
                    boxShadow: AppNavigation.shadow,
                  ),
                  alignment: Alignment.center,
                  child: AppIcon.asset(
                    widget._icon,
                    size: AppNavigation.iconSize,
                    color: AppNavigation.foreground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
