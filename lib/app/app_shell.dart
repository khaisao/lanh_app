import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/features/water/water.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.location,
  });

  final StatefulNavigationShell navigationShell;
  final String location;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _scrollThreshold = 16.0;
  static const _hiddenOffset = 1.25;

  bool _barVisible = true;
  double _dragDistance = 0;
  late final AppLifecycleListener _photoRecoveryLifecycle;
  DateTime _resumeDay = _day(DateTime.now());

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  void initState() {
    super.initState();
    _photoRecoveryLifecycle = AppLifecycleListener(onResume: _onResume);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _restorePendingPhoto();
    });
  }

  void _onResume() {
    final day = _day(DateTime.now());
    if (day != _resumeDay) {
      _resumeDay = day;
      ref.invalidate(todayWaterProvider);
      ref.invalidate(todayMealLogsProvider);
    }
    _restorePendingPhoto();
  }

  void _restorePendingPhoto() {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (!mounted ||
        (lifecycle != null && lifecycle != AppLifecycleState.resumed)) {
      return;
    }
    unawaited(restoreMealPhotoFlow(context));
  }

  @override
  void dispose() {
    _photoRecoveryLifecycle.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _barVisible = true;
      _dragDistance = 0;
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical ||
        MediaQuery.accessibleNavigationOf(context)) {
      return false;
    }
    if (notification is ScrollStartNotification) _dragDistance = 0;
    final details = switch (notification) {
      ScrollUpdateNotification(:final dragDetails) => dragDetails,
      OverscrollNotification(:final dragDetails) => dragDetails,
      _ => null,
    };
    final delta = -(details?.primaryDelta ?? 0);
    if (delta == 0) return false;
    if (delta.sign != _dragDistance.sign) _dragDistance = 0;
    _dragDistance += delta;

    final metrics = notification.metrics;
    final returningToTop =
        delta < 0 &&
        metrics.maxScrollExtent > metrics.minScrollExtent &&
        metrics.pixels <= metrics.minScrollExtent;
    if (_barVisible && _dragDistance >= _scrollThreshold) {
      setState(() => _barVisible = false);
    } else if (!_barVisible &&
        (returningToTop || _dragDistance <= -_scrollThreshold)) {
      setState(() => _barVisible = true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final navigationShell = widget.navigationShell;
    final selectedIndex = navigationShell.currentIndex;
    final showBar = _barVisible || MediaQuery.accessibleNavigationOf(context);
    final bottomBar = AppBottomBar(
      destinations: [
        AppBottomBarDestination(
          key: const Key('nav-today'),
          label: strings.today,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
        ),
        AppBottomBarDestination(
          key: const Key('nav-progress'),
          label: strings.progress,
          icon: Icons.leaderboard_outlined,
          selectedIcon: Icons.leaderboard_rounded,
        ),
        AppBottomBarDestination(
          key: const Key('nav-achievements'),
          label: strings.achievements,
          icon: Icons.workspace_premium_outlined,
          selectedIcon: Icons.workspace_premium_rounded,
        ),
        AppBottomBarDestination(
          key: const Key('nav-menu'),
          label: strings.menu,
          icon: Icons.grid_view_outlined,
          selectedIcon: Icons.grid_view_rounded,
        ),
      ],
      selectedIndex: selectedIndex,
      onSelect: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == selectedIndex,
      ),
      actionKey: const Key('nav-log-meal'),
      actionLabel: strings.logMeal,
      onAction: () => unawaited(showMealMethodSheet(context)),
      // Points at the action while today's journal is still empty.
      highlightAction:
          selectedIndex == 0 &&
          (ref.watch(todayMealLogsProvider).value?.isEmpty ?? false),
    );
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: navigationShell,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: showBar ? 0 : _hiddenOffset),
              duration: AppMotion.dockDuration(context, showing: showBar),
              curve: AppMotion.dockCurve,
              // Stop painting the backdrop once the dock leaves the view.
              builder: (context, offset, child) => Offstage(
                offstage: !showBar && offset == _hiddenOffset,
                child: FractionalTranslation(
                  translation: Offset(0, offset),
                  child: child,
                ),
              ),
              child: ExcludeFocus(
                excluding: !showBar,
                child: ExcludeSemantics(
                  excluding: !showBar,
                  child: IgnorePointer(ignoring: !showBar, child: bottomBar),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
