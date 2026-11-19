# Age-aware weight guidance

## Status
Complete — research, implementation, Flutter tests, APK build and Android emulator validation finished.

## Outcome
Support onboarding from age 13 while using CDC BMI-for-age guidance for ages 13–19, adult pace guardrails from age 20, and the existing design system for a responsive, non-stigmatizing flow.

## Acceptance criteria
- [x] Age validation accepts 13+ and rejects younger ages with localized copy.
- [x] Teen male/female BMI-for-age statuses use source-backed LMS rows and omit numeric target/rate controls.
- [x] Teen gain/lose/maintain guidance appears in onboarding and preserves intent without unsafe numeric targets.
- [x] Adult loss/gain estimates show pace, duration, date and status; too-fast loss dates are prevented by the date picker.
- [x] Adult loss targets below BMI 18.5 are rejected.
- [x] Existing adult onboarding tests and new teen/domain tests pass.
- [x] Build and smoke test on Android emulator completed.

## Evidence
- `plans/reports/research-261119-0014-weight-goal-guardrails.md`
- CDC source linked in `lib/features/profile_setup/domain/teen_bmi.dart`
- `flutter test` — 161 tests pass.
- `flutter analyze` — pass.
- `flutter build apk --debug` — pass.
- `flutter test integration_test/profile_guidance_test.dart -d emulator-5554` — pass.
- `flutter test integration_test/app_smoke_test.dart -d emulator-5554 --dart-define=LANH_USE_FAKE_MEAL_ANALYSIS=true` — pass after reinstall.
- `flutter test integration_test/meal_save_fake_test.dart -d emulator-5554 --dart-define=LANH_USE_FAKE_MEAL_ANALYSIS=true` — pass.
