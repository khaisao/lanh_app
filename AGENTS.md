# Shared UI and Flutter rules

- Treat `C:/Users/Kirito/Desktop/export-html` as the visual source of truth.
- Import `package:app_ui/app_ui.dart` for all shared UI work.
- Reuse `AppColors`, `AppSpacing`, `AppRadii`, `AppFonts`, `AppTypography`, `AppTheme`, `AppMotion`, `AppButton`, and `AppEmptyState` before adding local values.
- Put new reusable primitives in `packages/app_ui/lib/src`, export them through `packages/app_ui/lib/app_ui.dart`, and document their source token or repeated use.
- Do not define raw hex colors, font family strings, arbitrary spacing, radii, or button heights inside feature screens when a design token exists.
- Use `AppTypography` semantic roles and `AppFonts` family aliases. Use Be Vietnam Pro for body text, Nunito for headings, Playfair Display for editorial text, and JetBrains Mono for numeric or technical text.
- Use assets from `assets/design/icons` and `assets/design/images` with their original names and explicit dimensions.
- Keep bundled fonts in `assets/fonts` and declare them only in the root `pubspec.yaml`. Keep the font license beside the font files.
- Keep UI primitives in `packages/app_ui`, feature behavior in `lib/features/<feature>`, and domain/data/presentation responsibilities separate.
- Keep feature screens free of persistence, routing setup, and domain rules. Put repositories in `data`, contracts in `domain`, and widgets/controllers in `presentation`.
- Preserve semantic labels, text scaling, 56dp minimum action height, and reduced-motion support.
- Use the source icon when an exported asset exists. Do not substitute a Material icon for a design asset without documenting the reason.
- Add a shared primitive when it appears in more than one feature or encodes a source design token. Avoid feature-specific abstractions in the shared package.
- Check `welcome.html` or the matching export screen in preview when changing layout, typography, assets, or responsive behavior.
- Test at 320x700, 360x800, 390x844, and 430x932 for phone UI unless the screen has a documented device-specific constraint.
- Run `dart format`, `flutter analyze`, focused Flutter tests, and the full `flutter test` suite after shared UI changes.
