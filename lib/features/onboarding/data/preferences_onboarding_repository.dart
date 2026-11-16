import 'package:lanh_app/features/onboarding/domain/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class PreferencesOnboardingRepository implements OnboardingRepository {
  PreferencesOnboardingRepository(this._preferences);
  final SharedPreferencesAsync _preferences;
  static const _key = 'lanh.introduction.completed.v1';
  @override
  Future<bool> hasCompletedIntroduction() async =>
      await _preferences.getBool(_key) ?? false;
  @override
  Future<void> completeIntroduction() => _preferences.setBool(_key, true);
}
