part of '../app_ui.dart';

class AppBottomBarDestination {
  const AppBottomBarDestination({
    required this.key,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final Key key;
  final String label;
  final String icon;
  final String selectedIcon;
}

/// Four destinations flank a raised meal action, as in the exported nav.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelect,
    required this.actionKey,
    required this.actionLabel,
    required this.onAction,
  }) : assert(destinations.length == 4);

  final List<AppBottomBarDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Key actionKey;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.navInset,
        0,
        AppSpacing.navInset,
        AppSpacing.navBottom,
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
          child: SizedBox(
            width: double.infinity,
            height: AppSizes.nav + AppSpacing.navFabRise,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  top: AppSpacing.navFabRise,
                  child: DecoratedBox(
                    key: const ValueKey('nav-surface'),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      boxShadow: AppShadows.nav,
                    ),
                    // Match the export's px-2 inset inside its 1px border.
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.navInner + AppBorders.hairline,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final actionWidth =
                              (constraints.maxWidth / (destinations.length + 1))
                                  .clamp(AppSizes.navFab, double.infinity);
                          return Row(
                            children: [
                              _destination(0),
                              _destination(1),
                              SizedBox(width: actionWidth),
                              _destination(2),
                              _destination(3),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Tooltip(
                  message: actionLabel,
                  excludeFromSemantics: true,
                  child: _NavPressTarget(
                    targetKey: actionKey,
                    label: actionLabel,
                    onTap: onAction,
                    scale: AppScales.pressedNavFab,
                    circle: true,
                    child: const Center(
                      child: AppIcon.asset(
                        'ph-plus-bold',
                        size: AppSizes.iconXl,
                        color: AppColors.primaryForeground,
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
  );

  Widget _destination(int index) {
    final entry = destinations[index];
    final selected = index == selectedIndex;
    return Expanded(
      child: _NavPressTarget(
        targetKey: entry.key,
        label: entry.label,
        selected: selected,
        onTap: () => onSelect(index),
        scale: AppScales.pressed,
        child: _NavLabel(entry: entry, selected: selected),
      ),
    );
  }
}

class _NavLabel extends StatelessWidget {
  const _NavLabel({required this.entry, required this.selected});

  final AppBottomBarDestination entry;
  final bool selected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final duration = AppMotion.feedbackDuration(context);
      final icon = selected ? entry.selectedIcon : entry.icon;
      final graphic = AppIcon.asset(
        icon,
        key: ValueKey(icon),
        size: AppSizes.iconLg,
        color: selected ? AppColors.primary : AppColors.mutedForeground,
      );
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: AppSizes.iconLg,
            child: duration == Duration.zero
                ? graphic
                : AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: AppMotion.feedbackCurve,
                    child: graphic,
                  ),
          ),
          const SizedBox(height: AppSpacing.navLabelGap),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: AnimatedDefaultTextStyle(
                  duration: duration,
                  curve: AppMotion.feedbackCurve,
                  style: selected
                      ? AppTypography.navLabelSelected
                      : AppTypography.navLabel,
                  child: Text(entry.label, textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _NavPressTarget extends StatefulWidget {
  const _NavPressTarget({
    required this.targetKey,
    required this.label,
    required this.onTap,
    required this.scale,
    required this.child,
    this.selected,
    this.circle = false,
  });

  final Key targetKey;
  final String label;
  final VoidCallback onTap;
  final double scale;
  final Widget child;
  final bool? selected;
  final bool circle;

  @override
  State<_NavPressTarget> createState() => _NavPressTargetState();
}

class _NavPressTargetState extends State<_NavPressTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: AppMotion.feedbackPress,
    reverseDuration: AppMotion.feedbackRelease,
  )..addStatusListener(_onPressStatus);
  bool _pressed = false;

  void _onPressStatus(AnimationStatus status) {
    // Let even a quick tap show one full press before releasing.
    if (status == AnimationStatus.completed && !_pressed) {
      _press.reverse();
    }
  }

  void _updatePress(bool pressed) {
    if (_pressed == pressed) return;
    _pressed = pressed;
    if (pressed) {
      _press.forward();
    } else if (_press.isCompleted) {
      _press.reverse();
    }
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.feedbackDuration(context);
    final control = Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: widget.targetKey,
        customBorder: widget.circle
            ? const CircleBorder()
            : const StadiumBorder(),
        splashFactory: duration == Duration.zero
            ? NoSplash.splashFactory
            : null,
        onTap: widget.onTap,
        onHighlightChanged: duration == Duration.zero ? null : _updatePress,
        child: widget.child,
      ),
    );
    final target = Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) => Transform.scale(
          scale: duration == Duration.zero
              ? 1
              : 1 -
                    (1 - widget.scale) *
                        AppMotion.feedbackCurve.transform(_press.value),
          transformHitTests: false,
          child: child,
        ),
        child: widget.circle
            ? DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.navFab,
                ),
                child: control,
              )
            : control,
      ),
    );
    return widget.circle
        ? SizedBox.square(dimension: AppSizes.navFab, child: target)
        : SizedBox.expand(child: target);
  }
}
