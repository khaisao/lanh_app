import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:material_ui/material_ui.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final destinations = [
      ('today', strings.today, 'ph-sun'),
      ('progress', strings.progress, 'ph-chart-line-up'),
      ('achievements', strings.achievements, 'ph-trophy'),
      ('menu', strings.menu, 'ph-list'),
    ];

    Widget destination(int index) {
      final entry = destinations[index];
      final selected = navigationShell.currentIndex == index;
      final icon = selected
          ? switch (entry.$1) {
              'today' => 'ph-sun-fill',
              'progress' => 'ph-chart-line-up-fill',
              'achievements' => 'ph-trophy-fill',
              _ => 'ph-list-fill',
            }
          : entry.$3;
      void select() =>
          navigationShell.goBranch(index, initialLocation: selected);
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          label: entry.$2,
          onTap: select,
          excludeSemantics: true,
          child: InkWell(
            key: Key('nav-${entry.$1}'),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            onTap: select,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppIcon.asset(
                    icon,
                    size: AppSizes.iconLg,
                    color: selected
                        ? AppColors.primary
                        : AppColors.mutedForeground,
                  ),
                  const SizedBox(height: AppSpacing.navLabelGap),
                  SizedBox(
                    height: AppSpacing.md,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        entry.$2,
                        textAlign: TextAlign.center,
                        style: selected
                            ? AppTypography.navLabelSelected
                            : AppTypography.navLabel,
                      ),
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
        minimum: const EdgeInsets.fromLTRB(
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
              height: AppSizes.nav,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  boxShadow: AppShadows.nav,
                ),
                child: Row(
                  children: [
                    destination(0),
                    destination(1),
                    Expanded(
                      child: Center(
                        child: Transform.translate(
                          offset: AppOffsets.navFab,
                          child: IconButton(
                            key: const Key('nav-log-meal'),
                            tooltip: strings.logMeal,
                            onPressed: () =>
                                unawaited(showMealMethodSheet(context)),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.primaryForeground,
                              minimumSize: const Size(
                                AppSizes.navFab,
                                AppSizes.navFab,
                              ),
                              fixedSize: const Size(
                                AppSizes.navFab,
                                AppSizes.navFab,
                              ),
                            ),
                            icon: const AppIcon.asset(
                              'ph-plus-bold',
                              size: AppSizes.iconXl,
                              color: AppColors.primaryForeground,
                            ),
                          ),
                        ),
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
    );
  }
}
