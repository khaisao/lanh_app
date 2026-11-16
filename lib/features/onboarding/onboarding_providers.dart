import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/features/onboarding/data/preferences_onboarding_repository.dart';
import 'package:lanh_app/features/onboarding/domain/onboarding_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => PreferencesOnboardingRepository(SharedPreferencesAsync()),
);
