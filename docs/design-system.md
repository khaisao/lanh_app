# Lành design system

The HTML export in `C:/Users/Kirito/Desktop/export-html` is the visual source of truth. Shared Flutter primitives live in `packages/app_ui` and feature screens consume them through `package:app_ui/app_ui.dart`.

## Foundations

- Background `#F8F3E8`, foreground `#3B2F25`, primary `#2F5D3A`, primary foreground `#FBF8F1`.
- Secondary `#E4ECDD`, muted `#EFE8D9`, muted foreground `#6B5D4F`.
- Card `#FFFDF7`, input `#FFFCF5`, border `#E7DDCB`.
- Accent `#F2C4A8`, destructive `#8A4B2E`.
- Chart colors are gold `#E0B54A`, blue `#7FA8B5`, peach `#EFB99A`, and stone `#B8A890`.
- Use `AppSpacing` for gaps and padding, and `AppSizes` for control, artwork, and icon dimensions. The page width and inset follow `max-w-md` and `px-6` in the export.
- Use `AppRadii` for corners. Goal and meal option cards share the export’s `rounded-2xl` squircle, and pill actions use `StadiumBorder`.
- Primary actions have a 56 logical pixel minimum height and 20 logical pixels of horizontal padding. Long labels can wrap and increase the height.

## Typography

The web export uses Be Vietnam Pro for body text, Nunito for headings, Playfair Display for editorial serif text, and JetBrains Mono for numeric or technical text. The same font files are bundled in `assets/fonts` and declared once in the root `pubspec.yaml`. `AppFonts` maps the family names and `AppTypography` maps semantic text roles. Keep semantic text roles instead of setting ad hoc sizes in feature screens.

Use `AppFonts.body` for interface copy, `AppFonts.heading` for headings, `AppFonts.serif` for editorial content, and `AppFonts.mono` for numeric or technical content. Font files are sourced from the official Google Fonts repository and are distributed under the SIL Open Font License. The license is stored beside the font assets.

## Components

Use `AppButton` for primary and secondary actions, `AppOptionCard` for the icon, label, description, and caret pattern from `goal-onboarding.html` and `meal-logging-method-picker.html`, `AppEmptyState` for empty screens, and `AppTheme.light()` for the app theme. New shared primitives belong in `packages/app_ui/lib/src` and must be exported through the package barrel.

Feature screens consume semantic roles from `AppTypography` and aliases from `AppFonts`. Define additional export treatments in `AppTypography`. Keep component state, loading, error, disabled, and pressed styling in the shared component when the pattern repeats.

The package is presentation-only. Feature modules keep their own domain contracts, repositories, controllers, and route behavior. Shared UI must not import a feature package.

`AppBottomBar` follows the nav in `today-no-goal.html`. The capsule is 64 dp high and up to 448 dp wide, with a 16 dp outer margin above the device safe area and an 8 dp inner inset inside the border. The 64 dp meal action rises 16 dp above the capsule and keeps that width when the four tab columns shrink. Tab presses scale the icon and label together. The active icon crossfades, and the meal action briefly scales to 95%. Reduced motion skips these transitions.

## Assets

All exported icons and images are copied into `assets/design/icons` and `assets/design/images`. Use the original file names and explicit dimensions. Do not replace an exported icon with a platform icon when an exported asset exists.

## Accessibility and behavior

Preserve semantic headers, live error regions, large touch targets, and text scaling. Animation must honor `MediaQuery.disableAnimationsOf(context)`. Keep domain and persistence code out of `app_ui`; feature packages own their domain, data, and presentation behavior.

## Validation

Use Flutter preview for visual checks against the matching HTML export. Validate phone widths 320, 360, 390, and 430 logical pixels and check for overflow, text wrapping, asset sizing, and button reachability. Run `flutter analyze` and `flutter test` after changes to shared tokens or components.
