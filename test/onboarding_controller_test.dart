import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lanh_app/features/onboarding/onboarding_providers.dart';
import 'package:lanh_app/features/onboarding/presentation/onboarding_controller.dart';

import 'support/test_onboarding_repository.dart';

void main() {
  late TestOnboardingRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = TestOnboardingRepository();
    container = ProviderContainer.test(
      overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
    );
  });
  test('failure keeps first launch incomplete and retry saves it', () async {
    await container.read(onboardingControllerProvider.future);
    repository.failWrite = true;
    await container.read(onboardingControllerProvider.notifier).complete();
    final failed = container.read(onboardingControllerProvider).requireValue;
    expect(failed.completed, false);
    expect(failed.saveFailed, true);
    expect(failed.isSaving, false);
    repository.failWrite = false;
    await container.read(onboardingControllerProvider.notifier).complete();
    expect(
      container.read(onboardingControllerProvider).requireValue.completed,
      true,
    );
    expect(repository.completed, true);
  });
  test('rapid taps perform only one storage write', () async {
    await container.read(onboardingControllerProvider.future);
    repository.writeGate = Completer<void>();
    final controller = container.read(onboardingControllerProvider.notifier);
    final first = controller.complete();
    final second = controller.complete();
    expect(repository.writes, 1);
    expect(
      container.read(onboardingControllerProvider).requireValue.isSaving,
      true,
    );
    repository.writeGate!.complete();
    await Future.wait([first, second]);
    expect(repository.writes, 1);
  });
  test('returning launch loads persisted completion', () async {
    repository.completed = true;
    expect(
      (await container.read(onboardingControllerProvider.future)).completed,
      true,
    );
  });
}
