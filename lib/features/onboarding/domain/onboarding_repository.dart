/// Non-sensitive introduction state; health records do not belong here.
abstract interface class OnboardingRepository {
  Future<bool> hasCompletedIntroduction();
  Future<void> completeIntroduction();
}
