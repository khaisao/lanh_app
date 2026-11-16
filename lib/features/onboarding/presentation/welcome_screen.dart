import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/features/onboarding/presentation/onboarding_controller.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:lanh_ui/lanh_ui.dart';
import 'package:material_ui/material_ui.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final status = ref.watch(onboardingControllerProvider).value;
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.only(top: 48, bottom: 40),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LanhSpacing.large,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      minWidth: constraints.maxWidth,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox.shrink(),
                        _WelcomeHero(strings: strings),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (status?.saveFailed ?? false) ...[
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  strings.saveIntroductionError,
                                  key: const Key('onboarding-save-error'),
                                  textAlign: TextAlign.center,
                                  style: LanhTypography.caption.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            LanhKeyButton(
                              onPressed: null,
                              child: Text(strings.welcomeGoalUnavailable),
                            ),
                            const SizedBox(height: 12),
                            LanhKeyButton.secondary(
                              onPressed: status == null || status.isSaving
                                  ? null
                                  : () =>
                                        unawaited(_logFirstMeal(context, ref)),
                              child: Text(
                                status?.isSaving ?? false
                                    ? strings.saving
                                    : strings.welcomeLogFirstMeal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              strings.welcomeDisclaimer,
                              textAlign: TextAlign.center,
                              style: LanhTypography.caption,
                            ),
                          ],
                        ),
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

  Future<void> _logFirstMeal(BuildContext context, WidgetRef ref) async {
    final status = ref.read(onboardingControllerProvider).value;
    if (status == null || status.isSaving || status.completed) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    await ref.read(onboardingControllerProvider.notifier).complete();
    if (!context.mounted ||
        ref.read(onboardingControllerProvider).value?.completed != true) {
      return;
    }
    // Present the sheet once the router has replaced Welcome.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = navigator.overlay;
      if (overlay != null) unawaited(showMealMethodSheet(overlay.context));
    });
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const ExcludeSemantics(
        child: SizedBox(
          width: 224,
          height: 224,
          child: Stack(
            children: [
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: LanhColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Icon(
                      Icons.eco_rounded,
                      color: LanhColors.primary,
                      size: 72,
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 0,
                end: 0,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 32,
                  color: LanhColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: LanhSpacing.large),
      Semantics(
        header: true,
        child: Text(
          strings.appTitle,
          textAlign: TextAlign.center,
          style: LanhTypography.title,
        ),
      ),
      const SizedBox(height: LanhSpacing.small),
      Text(
        strings.welcomeHeadline,
        textAlign: TextAlign.center,
        style: LanhTypography.subtitle,
      ),
      const SizedBox(height: LanhSpacing.medium),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Text(
          strings.welcomeBody,
          textAlign: TextAlign.center,
          style: LanhTypography.body,
        ),
      ),
      const SizedBox(height: 12),
    ],
  );
}
