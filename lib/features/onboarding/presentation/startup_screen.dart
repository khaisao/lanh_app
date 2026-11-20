import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/features/onboarding/presentation/onboarding_controller.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:material_ui/material_ui.dart';

class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final failed = ref.watch(onboardingControllerProvider).hasError;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: failed
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(strings.startupError),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        onPressed: () =>
                            ref.invalidate(onboardingControllerProvider),
                        label: strings.retry,
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
