part of '../app_ui.dart';

const _navSelectionSize = Size(
  AppSizes.navSelection + AppSpacing.xs,
  AppSizes.navSelection,
);
const _navActionLensInset = 3.0;

class AppBottomBarDestination {
  const AppBottomBarDestination({
    required this.key,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final Key key;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
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

  static const _glassLook = GlassLook(
    frost: 2,
    fallbackFrost: 10,
    tint: Color(0x59FFFDF7),
    band: 16,
    bend: 24,
    dispersion: 0.035,
    specular: 0.85,
    sheen: 0.28,
    saturation: 1.1,
  );

  final List<AppBottomBarDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final Key actionKey;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => GlassScope(
    child: SafeArea(
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
                    child: GlassSurface(
                      key: const ValueKey('nav-surface'),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      look: _glassLook,
                      shadows: AppShadows.nav,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final slotWidth = constraints.maxWidth / 5;
                          // Keep equal center spacing and clear the raised button.
                          final targetWidth = (slotWidth * 2 - AppSizes.navFab)
                              .clamp(0.0, slotWidth);
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              _selection(context, slotWidth),
                              Row(
                                children: [
                                  _destination(0, targetWidth),
                                  _destination(1, targetWidth),
                                  const Spacer(),
                                  _destination(2, targetWidth),
                                  _destination(3, targetWidth),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Tooltip(
                    message: actionLabel,
                    triggerMode: TooltipTriggerMode.manual,
                    excludeFromSemantics: true,
                    child: _NavPressTarget(
                      targetKey: actionKey,
                      label: actionLabel,
                      onTap: onAction,
                      circle: true,
                      child: const Center(
                        child: Icon(
                          Icons.add_rounded,
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
    ),
  );

  Widget _selection(BuildContext context, double slotWidth) {
    final slot = selectedIndex < 2 ? selectedIndex : selectedIndex + 1;
    final highContrast = MediaQuery.highContrastOf(context);
    return AnimatedAlign(
      alignment: AlignmentDirectional((slot - 2) / 2, 0),
      duration: AppMotion.dockSelectionDuration(context),
      curve: AppMotion.dockCurve,
      child: SizedBox(
        width: slotWidth,
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: SizedBox.fromSize(
            size: _navSelectionSize,
            child: DecoratedBox(
              key: const ValueKey('nav-selection'),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: highContrast ? AppColors.primary : AppColors.card,
                  width: highContrast
                      ? AppBorders.selected
                      : AppBorders.hairline,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.card, AppColors.navSelection],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _destination(int index, double targetWidth) {
    final entry = destinations[index];
    final selected = index == selectedIndex;
    return Expanded(
      child: Center(
        child: SizedBox(
          width: targetWidth,
          child: _NavPressTarget(
            targetKey: entry.key,
            label: entry.label,
            selected: selected,
            onTap: () => onSelect(index),
            child: _NavIcon(entry: entry, selected: selected),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.entry, required this.selected});

  final AppBottomBarDestination entry;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.dockIconDuration(context);
    final icon = selected ? entry.selectedIcon : entry.icon;
    final graphic = Icon(
      icon,
      key: ValueKey(icon),
      size: AppSizes.iconLg,
      color: selected ? AppColors.primary : AppColors.mutedForeground,
    );
    return Center(
      child: SizedBox.square(
        dimension: AppSizes.iconLg,
        child: duration == Duration.zero
            ? graphic
            : AnimatedSwitcher(
                duration: duration,
                switchInCurve: AppMotion.dockCurve,
                switchOutCurve: AppMotion.dockCurve,
                child: graphic,
              ),
      ),
    );
  }
}

class _NavPressTarget extends StatefulWidget {
  const _NavPressTarget({
    required this.targetKey,
    required this.label,
    required this.onTap,
    required this.child,
    this.selected,
    this.circle = false,
  });

  final Key targetKey;
  final String label;
  final VoidCallback onTap;
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
  bool _hovered = false;

  void _onPressStatus(AnimationStatus status) {
    // Let even a quick tap show one full press before releasing.
    if (status == AnimationStatus.completed && !_pressed) {
      _press.reverse();
    }
  }

  void _updatePress(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
    if (MediaQuery.disableAnimationsOf(context)) return;
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final target = Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: widget.targetKey,
          customBorder: widget.circle
              ? const CircleBorder()
              : const StadiumBorder(),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: widget.onTap,
          onHighlightChanged: _updatePress,
          onHover: (hovering) => setState(() => _hovered = hovering),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: _hovered ? 0.65 : 0),
            duration: AppMotion.feedbackDuration(context),
            curve: AppMotion.feedbackCurve,
            builder: (context, hover, child) => AnimatedBuilder(
              animation: _press,
              builder: (context, child) {
                final press = reduceMotion
                    ? (_pressed ? 1.0 : 0.0)
                    : AppMotion.feedbackCurve.transform(_press.value);
                final lift = press.clamp(hover, 1.0);
                return Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    if (lift > 0) _lens(context, lift),
                    // The lens sits behind the icon to keep it crisp.
                    Transform.scale(
                      scale: reduceMotion ? 1 : 1 + 0.045 * lift,
                      transformHitTests: false,
                      child: child,
                    ),
                  ],
                );
              },
              child: child,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
    return widget.circle
        ? SizedBox.square(
            dimension: AppSizes.navFab,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.navActionRim),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.navActionHighlight, AppColors.primary],
                ),
                boxShadow: AppShadows.navFab,
              ),
              child: target,
            ),
          )
        : SizedBox.expand(child: target);
  }

  Widget _lens(BuildContext context, double lift) {
    final shape = BorderRadius.circular(AppRadii.pill);
    return Center(
      child: SizedBox.fromSize(
        size: widget.circle
            ? const Size.square(AppSizes.navFab - 2 * _navActionLensInset)
            : _navSelectionSize,
        child: ClipRRect(
          borderRadius: shape,
          child: MediaQuery.highContrastOf(context)
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: shape,
                    border: Border.all(
                      color: widget.circle
                          ? AppColors.primaryForeground
                          : AppColors.primary,
                      width: AppBorders.selected,
                    ),
                  ),
                )
              : GlassLens(
                  key: const ValueKey('nav-glass-lens'),
                  lift: lift,
                  opacity: lift,
                  shadows: const [],
                  liftedShadows: const [],
                ),
        ),
      ),
    );
  }
}
