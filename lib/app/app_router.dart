import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lanh_app/app/app_shell.dart';
import 'package:lanh_app/features/achievements/achievements.dart';
import 'package:lanh_app/features/menu/menu.dart';
import 'package:lanh_app/features/onboarding/onboarding.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/features/progress/progress.dart';
import 'package:lanh_app/features/today/today.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  String? pendingLocation;
  ref.listen(
    onboardingControllerProvider,
    (previous, next) => refresh.refresh(),
  );
  final router = GoRouter(
    initialLocation: '/startup',
    refreshListenable: refresh,
    redirect: (context, state) {
      final onboarding = ref.read(onboardingControllerProvider);
      final location = state.matchedLocation;
      final isEntry = location == '/startup' || location == '/welcome';
      final isSetup = location == '/profile-setup' || location == '/goal';
      if (!onboarding.hasValue) {
        if (!isEntry && !isSetup) pendingLocation = state.uri.toString();
        return location == '/startup' || isSetup ? null : '/startup';
      }
      if (!onboarding.requireValue.completed) {
        if (!isEntry && !isSetup) pendingLocation = state.uri.toString();
        return location == '/welcome' || isSetup ? null : '/welcome';
      }
      if (isEntry) {
        final destination = pendingLocation ?? '/today';
        pendingLocation = null;
        return destination;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/startup',
        builder: (context, state) =>
            const AppBackground(child: StartupScreen()),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) =>
            const AppBackground(child: WelcomeScreen()),
      ),
      GoRoute(path: '/goal', redirect: (_, _) => '/profile-setup'),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) =>
            const AppBackground(child: ProfileSetupScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            AppShell(navigationShell: shell, location: state.uri.path),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) =>
                    const AppBackground(child: TodayScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) =>
                    const AppBackground(child: ProgressScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/achievements',
                builder: (context, state) =>
                    const AppBackground(child: AchievementsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/menu',
                builder: (context, state) =>
                    const AppBackground(child: MenuScreen()),
                routes: [
                  GoRoute(
                    path: 'about',
                    builder: (context, state) =>
                        const AppBackground(child: AboutScreen()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      final strings = AppLocalizations.of(context);
      return AppBackground(
        child: Scaffold(
          appBar: AppBar(
            forceMaterialTransparency: true,
            title: Text(strings.notFound),
          ),
          body: Center(
            child: FilledButton(
              onPressed: () => context.go('/today'),
              child: Text(strings.backToToday),
            ),
          ),
        ),
      );
    },
  );
  ref.onDispose(router.dispose);
  ref.onDispose(refresh.dispose);
  return router;
});

class _RouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}
