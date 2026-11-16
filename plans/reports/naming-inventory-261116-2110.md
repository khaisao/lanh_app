# Naming inventory

## Scope
The repository uses `lanh` in three layers.

### Product and package identity
These are expected to change only during a full application rename and are coupled to tooling or package resolution.

- Root Dart package `lanh_app` in `pubspec.yaml`, all `package:lanh_app/...` imports, and generated localization imports.
- Shared workspace package `lanh_ui` in `packages/lanh_ui/pubspec.yaml` and `package:lanh_ui/...` imports.
- Android namespace/application ID `dev.lanh.lanh_app`, Kotlin package path, iOS bundle identifiers, web manifest metadata, and repository name.
- User-facing product strings such as `Lành` in localization and the iOS display name.

Changing these is a product/package rename and requires coordinated platform and generated-file changes.

### Refactorable shared UI names
These encode the current product name in reusable UI APIs and should be generic.

- `LanhApp` and `lib/app/lanh_app.dart` → `App` and `lib/app/app.dart`.
- `LanhColors` → `AppColors`.
- `LanhSpacing` → `AppSpacing`.
- `LanhRadii` → `AppRadii`.
- `LanhTypography` → `AppTypography`.
- `LanhTheme` → `AppTheme`.
- `LanhMotion` → `AppMotion`.
- `LanhKeyButton` → `AppButton`.
- `LanhEmptyState` → `EmptyState`.
- `packages/lanh_ui/lib/src/lanh_tokens.dart` → `tokens.dart`.
- `packages/lanh_ui/lib/src/lanh_theme.dart` → `theme.dart`.
- `packages/lanh_ui/lib/src/lanh_buttons.dart` → `buttons.dart`.
- `packages/lanh_ui/lib/src/lanh_empty_state.dart` → `empty_state.dart`.
- `packages/lanh_ui/lib/lanh_ui.dart` → `ui.dart` or `design_system.dart`.

### Internal storage key
`lanh.introduction.completed.v1` is a persisted data contract. Rename only with a migration or dual-read strategy. It should not be changed as a cosmetic refactor.

## Recommendation
Refactor the shared UI API and app root names now. Keep `lanh_app` and `lanh_ui` package names until a deliberate package rename is requested, because changing them touches generated localization, platform identifiers, manifests, lockfiles, and every import. If the goal is complete future rebranding, schedule a separate coordinated package/platform migration.
