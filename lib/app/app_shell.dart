import 'dart:async';
import 'dart:ui';

import 'package:go_router/go_router.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:lanh_ui/lanh_ui.dart';
import 'package:material_ui/material_ui.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final destinations = [
      ('today', strings.today, Icons.wb_sunny_outlined),
      ('progress', strings.progress, Icons.insights_outlined),
      ('achievements', strings.achievements, Icons.auto_awesome_outlined),
      ('menu', strings.menu, Icons.grid_view_rounded),
    ];
    Widget destination(int index) {
      final entry = destinations[index];
      final selected = navigationShell.currentIndex == index;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          label: entry.$2,
          excludeSemantics: true,
          child: InkWell(
            key: Key('nav-${entry.$1}'),
            borderRadius: BorderRadius.circular(24),
            onTap: () => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    entry.$3,
                    color: selected ? LanhColors.primary : LanhColors.muted,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.$2,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? LanhColors.primary : LanhColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: LanhColors.surface.withValues(alpha: .94),
                      border: Border.all(color: LanhColors.outline),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      children: [
                        destination(0),
                        destination(1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: IconButton.filled(
                            key: const Key('nav-log-meal'),
                            tooltip: strings.logMeal,
                            constraints: const BoxConstraints(
                              minWidth: 56,
                              minHeight: 56,
                            ),
                            onPressed: () =>
                                unawaited(showMealMethodSheet(context)),
                            icon: const Icon(Icons.add_rounded, size: 28),
                          ),
                        ),
                        destination(2),
                        destination(3),
                      ],
                    ),
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
