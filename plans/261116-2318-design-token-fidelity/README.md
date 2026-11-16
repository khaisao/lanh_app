# UI token fidelity

Status: reviewed on Android

## Outcome

Align all implemented Flutter screens with the HTML export source of truth while using shared `app_ui` tokens for every color, typography role, spacing, radius, icon size, and repeated control dimension.

## Scope

- Normalize shared tokens and theme primitives.
- Update app shell, onboarding, goal, today, progress, achievements, menu, about, and meal-method sheet.
- Preserve routing, persistence, localization, and existing public test behavior.

## Acceptance criteria

- Feature screens contain no raw design colors, ad hoc text styles, or repeated arbitrary dimensions where a shared token applies.
- Layouts match the corresponding exports at 320, 360, 390, and 430 logical pixels without overflow.
- `dart format`, `flutter analyze`, focused tests, full tests, and Android emulator preview pass.

## Validation

- Rendered the HTML references at 411 CSS pixels and compared them with Flutter running on Android 13 (`emulator-5554`, approximately 411 logical pixels wide).
- Checked Welcome, goal selection and forms, Today, Progress, Achievements, Menu, About, and the meal method sheet on the emulator. The onboarding selection uses the same line counts as the export at this width.
- Passed focused navigation and layout tests at 320×700, 360×800, 390×844, and 430×932, then all 20 Flutter tests and the Android integration smoke test. Static analysis reported no issues.

## Remaining differences

- The current app shows empty states and the saved goal from local storage. Name, avatar, meal history, water totals, and achievement progress in the export represent example content. Logging and settings routes beyond the current implementation remain unavailable.
- Each supported goal variant shares the tokenized layout. Browser comparison covered representative variants, and other variants have no individual screenshot comparison.
- The renderer displays the welcome sparkles but reports unsupported filters in the original SVG. The Flutter and browser renderers also draw some corners and system UI differently.
