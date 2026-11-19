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

- The Today HTML exports use chart blue at 20% opacity for filled water indicators. Use `AppColors.waterTint` for that surface and `AppSizes.waterIndicator` and `AppSizes.energyMarkerHeight` for the dashboard indicators.

## Typography

The web export uses Be Vietnam Pro for body text, Nunito for headings, Playfair Display for editorial serif text, and JetBrains Mono for numeric or technical text. The same font files are bundled in `assets/fonts` and declared once in the root `pubspec.yaml`. `AppFonts` maps the family names and `AppTypography` maps semantic text roles. Keep semantic text roles instead of setting ad hoc sizes in feature screens.

Use `AppFonts.body` for interface copy, `AppFonts.heading` for headings, `AppFonts.serif` for editorial content, and `AppFonts.mono` for numeric or technical content. Font files are sourced from the official Google Fonts repository and are distributed under the SIL Open Font License. The license is stored beside the font assets.

## Components

`AppBackground` displays the cream base, gradient, and three blurred color accents from the `TodayGradientMầmXanh` HTML design as [one bundled JPEG](../packages/app_ui/assets/backgrounds/lanh-gradient.jpg). The app preloads the image before showing its first Flutter frame. Each page route owns an `AppBackground`, so its surface covers earlier pages throughout native transitions. The decoded image is reused through Flutter's image cache. Page scaffolds can stay transparent inside that route surface. Cards, dialogs, and bottom sheets use their own surface tokens.

Use `AppButton` for primary and secondary actions, `AppOptionCard` for the icon, label, description, and caret pattern from `goal-onboarding.html` and `meal-logging-method-picker.html`, `AppEmptyState` for empty screens, and `AppTheme.light()` for the app theme. New shared primitives belong in `packages/app_ui/lib/src` and must be exported through the package barrel.

Feature screens consume semantic roles from `AppTypography` and aliases from `AppFonts`. Define additional export treatments in `AppTypography`. Keep component state, loading, error, disabled, and pressed styling in the shared component when the pattern repeats.

The package is presentation-only. Feature modules keep their own domain contracts, repositories, controllers, and route behavior. Shared UI must not import a feature package.

`AppBottomBar` follows the nav in `today-no-goal.html`. The capsule is 64 dp high and up to 448 dp wide, with a 16 dp outer margin above the device safe area and an 8 dp inner inset inside the border. The 64 dp meal action rises 16 dp above the capsule and keeps that width when the four tab columns shrink. Tab presses scale the icon and label together. The active icon crossfades, and the meal action briefly scales to 95%. Reduced motion skips these transitions.

## Assets

`AppGlassCard` is the liquid glass card every card should use. It follows the Profile Setup exports (`bg-card/70 backdrop-blur-xl border-card/80 ring-white/50` with a 0 20 40 −20 shadow and a 1 px white top highlight) through the `AppGlass` tokens, `AppShadows.glassCard` and `AppRadii.glassCard`/`glassInner`. Tones: `glass`, `selected` (2 dp primary outline), `primary` (solid primary with `AppShadows.primaryCard`) and `tinted` (secondary with a primary outline). `onPressed` adds ink under the content and the 0.98 press scale, skipped under Reduce Motion. High contrast swaps the glass for an opaque card. `AppSelectionTile` (optional `description` line), `AppOptionCard` and `AppGlassSurface` are built on it. `AppGlassSegmentedControl` follows the export's own segmented style instead: a `bg-card/50 border-card/80 shadow-inner` track (`AppGlass.track`, `AppGlass.edge`, `AppGlass.insetShade`) and a `bg-card/90 shadow-md` thumb (`AppGlass.raised`, `AppShadows.glassRaised`) that slides over `AppMotion.segmentSlide`, with a 0.97 press scale and no ripple or hover tint. Following the Today export, only a hero card is raised with `AppShadows.glassCard`; secondary cards (Today water/journal via `TodayCard`, Progress and Menu cards) are flat glass (`shadows: const []`, `AppRadii.glassInner`). `AppKeyboardDismiss`, installed in the app builder, closes the keyboard on any tap outside a text field (not on drags); wrap a field's surrounding card in `TextFieldTapRegion` when tapping it should focus the field; `AppRadioMark` draws the shared radio mark.

`AppGlassSurface` and `AppGlassIconButton` follow the frosted MealReview export: card at 60% over a 20 sigma backdrop blur, a white 60% edge (`AppColors.glassEdge`) and the `AppShadows.glass*` shadows. Glass radii are `AppRadii.glassHero`, `glassPanel` and `glassItem`. Wrap a scrolling page with several glass surfaces in `BackdropGroup` so they share one backdrop pass. Icon buttons draw a 44 dp glass circle inside a 56 dp touch target.

The MealReview icons `ph-stack-bold`, `ph-sparkle-fill`, `ph-egg-fill`, `ph-grains-fill`, `ph-drop-half-fill`, `ph-coffee-bold` and `ph-plus-circle` come from the Iconify Phosphor set named in that export.

`AppButton.surface` follows the translucent card action in `photo-meal-flow.html`. It supplies the card fill, border, foreground text and standard action height for the camera introduction.

`AppMediaOverlay` applies the foreground scrim from `camera-preview.html` and `photo-preview.html` above a live feed or photo. `AppMediaGlass` supplies the blur and border for controls on those surfaces. The camera badge and shutter sizes use tokens from `photo-meal-flow.html` and `camera-preview.html`. Media control buttons keep at least a 56 dp touch target. The caret and gallery icons use the Phosphor icons named in the HTML.

All exported icons and images are copied into `assets/design/icons` and `assets/design/images`. Use the original file names and explicit dimensions. Do not replace an exported icon with a platform icon when an exported asset exists.

The camera switch uses `ph-camera-rotate.svg`, the regular Phosphor `ph:camera-rotate` named by the supplied CameraPreview HTML, obtained from the [Phosphor source](https://github.com/phosphor-icons/core/blob/main/assets/regular/camera-rotate.svg). It uses the existing media glass control and icon size tokens.

## Accessibility and behavior

Preserve semantic headers, live error regions, large touch targets, and text scaling. Animation must honor `MediaQuery.disableAnimationsOf(context)`. Keep domain and persistence code out of `app_ui`; feature packages own their domain, data, and presentation behavior.

## Validation

Use Flutter preview for visual checks against the matching HTML export. Validate phone widths 320, 360, 390, and 430 logical pixels and check for overflow, text wrapping, asset sizing, and button reachability. Run `flutter analyze` and `flutter test` after changes to shared tokens or components.

## Motion

Motion tokens live in `AppMotion`; every animation reads `AppMotion.of(context, …)` so Reduce Motion makes it instant.

- `AppGlassCard` cross-fades fill, outline and shadow between tones (`AppMotion.selection`, 260 ms ease-out-cubic) and pops 1 → 1.03 → 1 (`selectionPop`, ease-out-back) when it becomes chosen; `popOnSelect: false` for focus-only states such as `ProfileMeasureCard`. `AppSquircleBorder` lerps radius and side so outlines animate.
- `AppRadioMark` scales the check in with a slight overshoot; `AppSelectionTile` fills its icon well and fires `HapticFeedback.selectionClick` on a new choice (also the segmented control, sex cards, plan cards and kg chips).
- `AppEntrance(index)` rises 18 dp and fades in after `index × 55 ms` (one controller, `Interval` delay, no timers). Steps stagger their cards with it.
- `AppRollingText` rolls a changing value (old slides up, new rises in) for kcal, the custom target and plan estimates.
- `AppAnimatedSize` smooths height changes and steps aside under Reduce Motion (a zero-duration `AnimatedSize` asserts during layout).
- Profile Setup switches steps with a direction-aware slide and fade (`stepSwitch`, 360 ms), grows the progress fill (`progressFill`), and cross-fades the bottom button label.

## Choice items

`AppChoice` holds the single-choice tokens from the Profile Setup Goal export, so goal, activity and option lists match: idle items are plain glass with an `AppChoice.wellIdle` (secondary) icon well and an empty `AppChoice.markIdle` ring (2 dp); chosen items use `AppGlassTone.selected`, which fills with `AppChoice.selectedFill` (`bg-primary/5`) and strokes 2 dp `AppChoice.selectedStroke`, with a solid `AppChoice.wellSelected` well and a filled `AppChoice.markSelected` check. Wells are `AppChoice.well` (48) or `AppChoice.wellCompact` (40). `AppSelectionTile`, `AppRadioMark`, `AppOptionCard` and `ProfileMeasureCard` focus read these tokens; do not set selection colours in feature code.

