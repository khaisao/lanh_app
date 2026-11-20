import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lanh_app/features/onboarding/presentation/onboarding_controller.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final status = ref.watch(onboardingControllerProvider).value;
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
          child: SafeArea(
            minimum: const EdgeInsets.fromLTRB(
              0,
              AppSpacing.onboardingTop,
              0,
              AppSpacing.onboardingBottom,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const ExcludeSemantics(
                              child: SizedBox.square(
                                dimension: AppSpacing.xl,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: AppIcon.asset(
                                      'ph-leaf-bold',
                                      size: AppSizes.iconXs,
                                      color: AppColors.primaryForeground,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(
                              child: Text(
                                strings.appTitle,
                                style: AppTypography.welcomeWordmark,
                              ),
                            ),
                          ],
                        ),
                        _WelcomeHero(strings: strings),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppButton(
                              fullWidth: true,
                              onPressed: status == null || status.isSaving
                                  ? null
                                  : () => context.push('/profile-setup'),
                              label: strings.welcomeGoalAction,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const ExcludeSemantics(
                                  child: AppIcon.asset(
                                    'ph-info',
                                    size: AppSizes.iconInfo,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Flexible(
                                  child: Text(
                                    strings.welcomeDisclaimer,
                                    style: AppTypography.navLabel,
                                  ),
                                ),
                              ],
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
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const ExcludeSemantics(child: _WelcomeArtwork()),
      const SizedBox(height: AppSpacing.xl),
      Semantics(
        header: true,
        child: Text(
          strings.welcomeHeadline,
          textAlign: TextAlign.center,
          style: AppTypography.welcomeHeadline,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.readableWidth),
        child: Text(
          strings.welcomeBody,
          textAlign: TextAlign.center,
          style: AppTypography.welcomeBody,
        ),
      ),
    ],
  );
}

class _WelcomeArtwork extends StatefulWidget {
  const _WelcomeArtwork();

  @override
  State<_WelcomeArtwork> createState() => _WelcomeArtworkState();
}

class _WelcomeArtworkState extends State<_WelcomeArtwork>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.reset();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    // Use the raster export to retain the source icon's SVG filters.
    const sparkles = Image(
      image: AssetImage('assets/design/images/fluent-emoji-sparkles.png'),
      width: AppSpacing.xl,
      height: AppSpacing.xl,
      filterQuality: FilterQuality.medium,
    );
    return SizedBox.square(
      dimension: AppSizes.hero,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const OverflowBox(
            minWidth: AppSizes.welcomeOuterHalo,
            maxWidth: AppSizes.welcomeOuterHalo,
            minHeight: AppSizes.welcomeOuterHalo,
            maxHeight: AppSizes.welcomeOuterHalo,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.welcomeHalo,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox.square(
            dimension: AppSizes.welcomeInnerHalo,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const AppMascot(size: AppSizes.hero, bounce: true),
          PositionedDirectional(
            top: AppSpacing.md,
            end: AppSpacing.xs,
            child: reduceMotion
                ? sparkles
                : FadeTransition(
                    opacity: _pulse
                        .drive(CurveTween(curve: const Cubic(0.4, 0, 0.6, 1)))
                        .drive(Tween(begin: 1.0, end: 0.5)),
                    child: sparkles,
                  ),
          ),
        ],
      ),
    );
  }
}
