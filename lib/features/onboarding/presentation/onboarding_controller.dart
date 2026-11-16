import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/features/onboarding/onboarding_providers.dart';

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, OnboardingStatus>(
      OnboardingController.new,
      retry: (retryCount, error) => null,
    );

final class OnboardingStatus {
  const OnboardingStatus({
    required this.completed,
    this.isSaving = false,
    this.saveFailed = false,
  });
  final bool completed;
  final bool isSaving;
  final bool saveFailed;
}

class OnboardingController extends AsyncNotifier<OnboardingStatus> {
  Future<void>? _pendingCompletion;
  @override
  Future<OnboardingStatus> build() async => OnboardingStatus(
    completed: await ref
        .read(onboardingRepositoryProvider)
        .hasCompletedIntroduction(),
  );
  Future<void> complete() {
    if (state.value?.completed ?? false) return Future.value();
    return _pendingCompletion ??= _complete().whenComplete(
      () => _pendingCompletion = null,
    );
  }

  Future<void> _complete() async {
    if (!state.hasValue) return;
    state = const AsyncData(OnboardingStatus(completed: false, isSaving: true));
    try {
      await ref.read(onboardingRepositoryProvider).completeIntroduction();
      if (ref.mounted) {
        state = const AsyncData(OnboardingStatus(completed: true));
      }
    } catch (_) {
      if (ref.mounted) {
        state = const AsyncData(
          OnboardingStatus(completed: false, saveFailed: true),
        );
      }
    }
  }
}
