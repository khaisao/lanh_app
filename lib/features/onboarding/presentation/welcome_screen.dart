import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/features/onboarding/presentation/onboarding_controller.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:material_ui/material_ui.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final status = ref.watch(onboardingControllerProvider).value;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.onboardingTop,
          AppSpacing.pageHorizontal,
          AppSpacing.onboardingBottom,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.destructive,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          AppButton(
                            onPressed: status == null || status.isSaving
                                ? null
                                : () => context.push('/goal'),
                            child: Text(strings.welcomeGoalUnavailable),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppButton.secondary(
                            onPressed: status == null || status.isSaving
                                ? null
                                : () => unawaited(_logFirstMeal(context, ref)),
                            child: Text(
                              status?.isSaving ?? false
                                  ? strings.saving
                                  : strings.welcomeLogFirstMeal,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            strings.welcomeDisclaimer,
                            textAlign: TextAlign.center,
                            style: AppTypography.caption,
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
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ExcludeSemantics(
        child: SizedBox(
          width: AppSizes.hero,
          height: AppSizes.hero,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Center(
                child: Image(
                  image: AssetImage('assets/design/images/xQ84zhEVfCY.png'),
                  width: AppSizes.hero,
                  height: AppSizes.hero,
                  fit: BoxFit.contain,
                ),
              ),
              const PositionedDirectional(
                top: -AppSpacing.xs,
                end: -AppSpacing.xs,
                child: AppIcon.asset(
                  'fluent-emoji-sparkles',
                  size: AppSpacing.xl,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      Semantics(
        header: true,
        child: Text(
          strings.appTitle,
          textAlign: TextAlign.center,
          style: AppTypography.display,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        strings.welcomeHeadline,
        textAlign: TextAlign.center,
        style: AppTypography.subtitle,
      ),
      const SizedBox(height: AppSpacing.md),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.readableWidth),
        child: Text(
          strings.welcomeBody,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall,
        ),
      ),
    ],
  );
}
