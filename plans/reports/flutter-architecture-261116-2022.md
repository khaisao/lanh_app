# Flutter architecture scout

## Current structure

- `lib/app` contains app bootstrap, router, shell, and `MaterialApp.router`.
- `lib/features/<feature>` uses feature-first folders. Onboarding already separates domain, data, and presentation.
- `packages/lanh_ui` is the workspace package for shared theme, tokens, and components. It currently contains colors, spacing, typography, theme, motion, buttons, and empty state.
- Localization is generated under `lib/l10n/generated`, with source ARB files in `lib/l10n`.

## Existing reuse and inconsistencies

- The package palette predates the export. Welcome still has hard-coded export colors.
- `LanhKeyButton.secondary` is outlined, while the export uses a filled pale-secondary pill. Shared button variants need explicit semantics.
- `AppShell` directly composes navigation icons, spacing, and a glass surface. These are shared visual patterns that should consume package tokens/components.
- `TodayScreen` and router recovery use raw Material `FilledButton`, while the package has shared buttons.
- `LanhTypography` lacks semantic display, heading, body, label, and caption roles.
- Spacing currently only covers 8/16/24 while the export uses a broader scale and component dimensions.

## Recommended package boundaries

Keep `packages/lanh_ui` dependency-light and presentation-only.

- `tokens.dart` for color, spacing, radii, sizes, typography, elevation, and motion.
- `theme.dart` for `ThemeData` and component theme defaults.
- `buttons.dart` for filled pill, secondary pill, outlined, text, and icon button variants.
- `surfaces.dart` for page backgrounds, cards, sheets, and glass navigation surfaces.
- `text.dart` for semantic text widgets when Theme alone is insufficient.
- `states.dart` for empty, error, and loading states.
- `navigation.dart` for shared bottom navigation once the shell is stable.

Export public APIs from `packages/lanh_ui/lib/lanh_ui.dart`. Keep feature state, repositories, and routing in `lib/features` and `lib/app`.

## Clean architecture guardrails

- Domain entities and repository contracts must not import Flutter widgets, Material, or localization.
- Data implementations depend on domain contracts and platform storage.
- Presentation controllers depend on domain contracts and expose immutable UI state.
- Screens compose shared UI components and localization but do not contain persistence logic.
- `app` owns routing and dependency wiring.
- `lanh_ui` owns visual tokens and components only, with no business behavior.

## Validation to preserve

- `flutter analyze`.
- `flutter test test/app_navigation_test.dart` for routing, onboarding, meal sheet, deep links, and text scaling.
- `flutter test test/onboarding_controller_test.dart` for repository/controller behavior.
- Run `flutter test` after shared component/theme changes.
- Preserve keys used by tests such as `onboarding-save-error`, `meal-method-sheet`, `today-screen`, `nav-*`, and `nav-log-meal`.

## Suggested implementation order

1. Inventory export HTML and copy exact tokens/assets into `lanh_ui`.
2. Add token and component tests.
3. Migrate Welcome and AppShell to package components.
4. Migrate empty states and feature action buttons.
5. Keep feature folders stable while adding domain/data/presentation layers where behavior exists.
6. Add durable project rules documenting token ownership, asset handling, and architecture constraints.

Status: DONE
Summary: Existing feature-first structure is compatible with clean architecture. `packages/lanh_ui` is the correct shared visual boundary, and the main work is consolidating the export tokens and repeated components there.
