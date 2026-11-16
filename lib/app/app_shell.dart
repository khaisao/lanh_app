import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final selectedIndex = navigationShell.currentIndex;
    final systemBottom = MediaQuery.viewPaddingOf(context).bottom;
    return Scaffold(
      extendBody: true,
      body: Builder(
        builder: (context) => MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          // The screens already reserve scroll padding for the floating bar.
          child: Padding(
            padding: EdgeInsets.only(bottom: systemBottom),
            child: navigationShell,
          ),
        ),
      ),
      bottomNavigationBar: AppBottomBar(
        destinations: [
          AppBottomBarDestination(
            key: const Key('nav-today'),
            label: strings.today,
            icon: 'ph-sun',
            selectedIcon: 'ph-sun-fill',
          ),
          AppBottomBarDestination(
            key: const Key('nav-progress'),
            label: strings.progress,
            icon: 'ph-chart-line-up',
            selectedIcon: 'ph-chart-line-up-fill',
          ),
          AppBottomBarDestination(
            key: const Key('nav-achievements'),
            label: strings.achievements,
            icon: 'ph-trophy',
            selectedIcon: 'ph-trophy-fill',
          ),
          AppBottomBarDestination(
            key: const Key('nav-menu'),
            label: strings.menu,
            icon: 'ph-list',
            selectedIcon: 'ph-list-fill',
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
      ),
    );
  }
}
