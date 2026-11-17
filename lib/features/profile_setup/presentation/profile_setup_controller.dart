import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/features/onboarding/onboarding.dart';

import '../domain/profile.dart';
import '../profile_setup_providers.dart';

final profileSetupControllerProvider = Provider<ProfileSetupController>(
  ProfileSetupController.new,
);

class ProfileSetupController {
  ProfileSetupController(this._ref);

  final Ref _ref;

  Future<bool> save(Profile profile) async {
    try {
      await _ref.read(profileRepositoryProvider).save(profile);
    } catch (_) {
      return false;
    }
    if (!_ref.mounted) return false;
    _ref.invalidate(savedProfileProvider);
    await _ref.read(onboardingControllerProvider.notifier).complete();
    return _ref.mounted &&
        _ref.read(onboardingControllerProvider).value?.completed == true;
  }
}
