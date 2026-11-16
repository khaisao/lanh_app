# Export HTML design inventory

## Scope

- 93 HTML screens in `C:/Users/Kirito/Desktop/export-html` were scanned.
- Shared CSS and token blocks are duplicated in every screen, so the values below are stable project-wide tokens.
- Resource inventory includes 53 SVG icons and 3 raster images.

## Global tokens

| Token | Value |
|---|---|
| background | #F8F3E8 |
| foreground | #3B2F25 |
| primary | #2F5D3A |
| primaryForeground | #FBF8F1 |
| secondary | #E4ECDD |
| secondaryForeground | #2F5D3A |
| muted | #EFE8D9 |
| mutedForeground | #6B5D4F |
| accent | #F2C4A8 |
| accentForeground | #4A2E1F |
| destructive | #8A4B2E |
| destructiveForeground | #FBF8F1 |
| card / popover | #FFFDF7 |
| cardForeground / popoverForeground | #3B2F25 |
| border | #E7DDCB |
| input | #FFFCF5 |
| ring | #2F5D3A |
| chart1 | #2F5D3A |
| chart2 | #E0B54A |
| chart3 | #7FA8B5 |
| chart4 | #EFB99A |
| chart5 | #B8A890 |
| base radius | 16px |
| shape | squircle when supported, multiplier 2.5 |

Fonts are Be Vietnam Pro for body, Nunito for headings, Playfair Display for serif accent, and JetBrains Mono for numeric/monospace content. Screens use weights 400–900. The HTML source loads Google Fonts, so Flutter should bundle equivalent font files for offline pixel stability.

## Layout and spacing

- Mobile content width is `max-w-md`, 448px, centered.
- Common horizontal page padding is 24px (`px-6`). Detail/form pages commonly use 16px (`px-4`).
- Top padding clusters at 32px (`pt-8`), 40px (`pt-10`), and 48px (`pt-12`). Welcome uses 48px top and 40px bottom.
- Bottom navigation uses fixed 64px height (`h-16`), 16px bottom offset, width `calc(100% - 2rem)`, max width 448px, 32px radius, card background, 1px border and warm brown shadow.
- Primary controls are usually height 56px (`h-14`), secondary/action controls 48px (`h-12`), compact controls 40–44px (`h-10`, `h-11`).
- Common gaps are 4, 8, 12, 16 and 24px. Vertical section rhythm is usually 24px (`mt-6`).
- Common padding is 12px list/button (`p-3`), 16px cards/rows (`p-4`), 20px prominent controls (`p-5`), and 24px hero containers (`p-6`).
- Full-width buttons use `rounded-full`. Cards, sheets and grouped lists use `rounded-2xl` (32px under squircle multiplier), with occasional `rounded-xl` and `rounded-3xl` for larger surfaces.

## Typography usage

- Page title: heading font, `text-3xl` (30px), bold. Welcome title is `text-4xl` (36px).
- Large hero/stat numbers: `text-5xl` (48px), bold, often primary or foreground.
- Section title: `text-2xl` (24px), bold. Subheading: `text-lg` (18px), semibold.
- Body: `text-sm` (14px) and `text-base` (16px), normal/medium.
- Supporting/meta copy: `text-xs` (12px), muted foreground. Fine print uses `text-[11px]`.
- Labels use uppercase, semibold, `tracking-wide`, muted foreground.
- Numeric display often uses semibold/bold, with chart colors and mono font where explicitly shown.

## Repeated components and states

### Buttons

- Primary filled action: primary background, primary foreground, 56px height, full radius, semibold, active scale 0.97.
- Secondary filled action: secondary background, secondary foreground, same height/radius.
- Muted compact action: muted background, foreground, 40–48px height, full radius.
- Destructive action: destructive background/foreground or destructive text on transparent/card surface.
- Icon-only controls: circular/full-radius, commonly 40–48px touch target.
- Disabled/coming-soon states retain layout and use muted or reduced opacity.

### Navigation

- Bottom nav has five slots: Today, Progress, centered floating plus, Achievements, Menu.
- Center plus is 64px circle with primary fill and shadow, lifted about 32px above nav.
- Active tab uses primary and filled Phosphor icon. Inactive tabs use muted foreground and outline icon.
- Back control is a 44px-ish full-radius button with 20px arrow icon and semibold text.

### Surfaces

- Cards and grouped rows use card background, 1px border, 16px padding, 32px squircle radius.
- List rows are full width, 48–64px minimum height, 12–16px padding, icon at 20px, trailing caret at 16px, separators in border color.
- Bottom sheets/dialogs use card or background surface, rounded top corners, internal 24px padding, and a drag handle.
- Inputs use input background, border, 12–16px radius, 48–56px height, clear focus ring in primary.

### Feedback and status

- Success uses chart/secondary green family with `ph:check-circle-fill` or `ph:seal-check-fill`.
- Warning/error uses destructive brown with `ph:warning-circle-fill`.
- Empty states center a 48–64px icon, heading, muted body copy, optional primary action.
- Loading uses `ph:circle-notch` or progress bars, and saving screens preserve the surrounding layout.
- Confirmation screens frequently use the Mầm PNG and `fluent-emoji:sparkles`.

## Icon inventory

All icons are local SVGs in `export-html/icons` and should be copied to Flutter assets with a stable semantic registry. Frequently used icons include navigation `ph:sun`, `ph:chart-line-up`, `ph:trophy`, `ph:list`, `ph:list-fill`, `ph:plus-bold`, `ph:arrow-left-bold`, `ph:caret-right`; meal `ph:bowl-food`, `game-icons:bowl-of-rice`, `ph:bowl-steam`, `ph:fish`, `ph:plant`, `ph:leaf`, `ph:camera`, `ph:magnifying-glass`, `ph:pencil-simple`, `ph:bookmark-simple`; goals `ph:target`, `ph:scales`, `ph:chart-line-up-fill`, `ph:arrows-in-line-horizontal`, `ph:calendar-blank`, `ph:calendar-check-fill`; feedback `ph:check-circle-fill`, `ph:seal-check-fill`, `ph:warning-circle-fill`, `ph:minus-circle`, `ph:circle-notch`, `ph:x-bold`; settings `ph:bell`, `ph:bell-simple-ringing`, `ph:shield-check`, `ph:lock-simple`, `ph:user-circle`, `ph:chat-circle-dots`, `ph:sliders-horizontal`, `ph:moon`, `ph:sun-horizon`, `ph:trash`; decorative `fluent-emoji:sparkles`.

## Raster resources

- `xQ84zhEVfCY.png` is the Mầm character/seed mascot and appears in welcome, empty, estimating and success states.
- `dzdAuAChai1.jpeg` is the meal photo used in meal detail, journal, review and template states.
- Screens also reference a Google profile avatar URL. The project should provide a local/default avatar fallback and avoid making core layout dependent on remote image availability.

## Recommended Flutter module boundaries

- `packages/lanh_ui/lib/src/tokens/`: colors, spacing, radii, dimensions, typography and elevation.
- `packages/lanh_ui/lib/src/theme/`: `ThemeData`, text theme, button themes, input themes, navigation bar/sheet themes.
- `packages/lanh_ui/lib/src/components/`: primary/secondary/destructive buttons, icon button, page scaffold, card, grouped list row, bottom navigation, empty state, feedback banner, form field, stat card, meal photo, mascot/illustration.
- `packages/lanh_ui/lib/src/icons/`: generated semantic icon registry mapping names to local SVG assets. Keep raw asset names out of feature screens.
- `packages/lanh_ui/assets/`: copied SVG icon set and raster resources.
- Feature packages should own state and domain behavior. UI components accept data/callbacks and remain presentation-only.

## Rules for future implementation

1. Use tokens from `lanh_ui` for every color, spacing, radius and text style. Avoid raw literals in feature screens.
2. Use semantic components and the icon registry. Do not call remote Iconify URLs at runtime.
3. Keep content width at 448px maximum and preserve the 24px page gutter unless a screen's HTML specifies another gutter.
4. Preserve the 56/48/40px control height tiers and full-radius action shapes.
5. Use card/background/border tokens for surfaces. Do not introduce new colors without updating the token table and documenting the source screen.
6. Keep bottom navigation geometry and centered floating action consistent across all main tabs.
7. Keep empty, loading, success and error states as explicit variants of shared components.
8. Bundle fonts and raster resources locally for deterministic rendering and offline use.
9. Accessibility requirements from the HTML must survive translation: semantic labels for icon-only actions, visible focus state, minimum 44px touch targets, and live regions for asynchronous errors.
10. Feature code should not import raw SVG paths or know asset filenames. It should consume semantic UI APIs.
