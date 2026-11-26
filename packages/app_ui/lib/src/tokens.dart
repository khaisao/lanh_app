part of '../app_ui.dart';

/// Soft gradients (Sleek icon system): content icon tiles fade from their
/// meaning tint to cream; primary actions fade from a fresh green to the
/// brand green. Small secondary controls stay flat.
abstract final class AppGradients {
  /// A content icon tile tinted by [tint], top-left to bottom-right.
  static LinearGradient well(Color tint) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tint, AppColors.card],
  );

  /// Primary pills and the solid recommended card.
  static const action = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.meterFillEnd, AppColors.primary],
  );
}

/// Sleek back/close recipe, shared by every feature navigation control.
abstract final class AppNavigation {
  static const visualSize = 44.0;
  static const targetSize = AppSizes.action;
  static const iconSize = AppSizes.iconMd;
  static const fill = AppColors.card;
  static const border = AppColors.border;
  static const foreground = AppColors.primary;
  static const pressedScale = 0.9;
  static const duration = Duration(milliseconds: 200);
  static const shadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
}

abstract final class AppColors {
  static const background = Color(0xFFF8F3E8);
  static const foreground = Color(0xFF3B2F25);
  static const primary = Color(0xFF2F5D3A);
  static const primaryForeground = Color(0xFFFBF8F1);
  static const secondary = Color(0xFFE4ECDD);
  static const secondaryForeground = Color(0xFF2F5D3A);
  static const muted = Color(0xFFEFE8D9);
  static const mutedForeground = Color(0xFF6B5D4F);
  static const accent = Color(0xFFF2C4A8);
  static const welcomeHalo = Color(0x66F2C4A8);
  static const accentForeground = Color(0xFF4A2E1F);
  // End of the Home kcal meter gradient (`from-primary to-[#4f8a5b]`).
  static const meterFillEnd = Color(0xFF4F8A5B);
  static const destructive = Color(0xFF8A4B2E);
  static const card = Color(0xFFFFFDF7);
  static const input = Color(0xFFFFFCF5);
  static const border = Color(0xFFE7DDCB);
  static const chartBlue = Color(0xFF7FA8B5);
  // Water glass on the Home card (Sleek Home 01–15): fill gradient ends.
  static const waterLight = Color(0xFF9CC4DC);
  static const waterDeep = Color(0xFF6B9BB8);
  static const chartGold = Color(0xFFE0B54A);
  // Sleek Menu water reminder: drop glyph `#3F6F7F`.
  static const waterIcon = Color(0xFF3F6F7F);
  static const chartPeach = Color(0xFFEFB99A);
  static const navSelection = Color(0xB8D9E8D5);
  static const navActionHighlight = Color(0xFF578561);
  static const navActionRim = Color(0xBB9CC09A);
  static const modalBarrier = Color(0x403B2F25);
  // MealReview glass export: `border-white/60` and `border-white/50`.
  static const glassEdge = Color(0x99FFFFFF);
  static const glassRim = Color(0x80FFFFFF);

  // Meaning colors of the history and Nhìn lại screens (Sleek, 25/11):
  // energy is orange, water blue, starch and sweets sunny yellow, protein
  // meat red; over the plan uses the accent peach.
  static const energy = Color(0xFFE0782F);
  static const energyTint = Color(0xFFFDE7D7);
  static const waterTint = Color(0xFFE3EEF5);
  static const sunny = Color(0xFFC99412);
  static const sunnyTint = Color(0xFFFBEFCC);
  static const protein = Color(0xFFD9665B);
  static const proteinTint = Color(0xFFFBE1DE);
  // Vertical gradient of a chart bar over the plan.
  static const overTop = Color(0xFFF4C3A3);
  static const overBottom = Color(0xFFE9946C);
}

/// The two states of every choice card (goal, activity, target plan, mode
/// switch), from the Profile Setup Goal / Activity / Target exports.
///
/// Default: liquid glass `bg-card/70 border-2 border-card/80`, a `bg-secondary`
/// icon well with a primary icon and an empty `border-2 border-border` ring.
/// Selected: solid `bg-secondary`, `border-2 border-primary`, the softer
/// [selectedShadow], a `bg-primary` well with a light icon and a `bg-primary`
/// circle holding a 12 px `ph:check-bold`.
abstract final class AppChoice {
  static const selectedFill = AppColors.secondary;
  static const selectedStroke = AppColors.primary;

  /// `border-2` on both states, so choosing never shifts the layout.
  static const strokeWidth = AppBorders.selected;
  static const wellIdle = AppColors.secondary;
  static const wellSelected = AppColors.primary;
  static const iconIdle = AppColors.primary;
  static const iconSelected = AppColors.primaryForeground;
  static const markIdle = AppColors.border;
  static const markSelected = AppColors.primary;

  /// `size-6` ring / check circle.
  static const markSize = AppSizes.iconLg;

  /// `ph:check-bold` 12 px inside the selected circle.
  static const markCheck = 12.0;

  /// `size-10 rounded-2xl` icon well with a 20 px icon.
  static const well = AppSizes.avatar;
  static const wellIcon = AppSizes.iconMd;

  /// `shadow-[0_12px_24px_-18px_rgba(59,47,37,0.14)]` on a chosen card.
  static const selectedShadow = [
    BoxShadow(
      color: Color(0x243B2F25),
      blurRadius: 24,
      spreadRadius: -18,
      offset: Offset(0, 12),
    ),
  ];
}

/// Liquid glass card recipe shared by every card in the app. Mirrors the Sleek
/// export `bg-card/70 backdrop-blur-xl border border-card/80 ring-1 ring-inset
/// ring-white/50 shadow-[0_20px_40px_-20px_rgba(59,47,37,0.3),inset_0_1px_0_0_
/// rgba(255,255,255,0.6)]`.
abstract final class AppGlass {
  /// `bg-card/70`.
  static const fill = Color(0xB3FFFDF7);

  /// `bg-card/40 backdrop-blur-2xl border-t border-white/60`: the docked
  /// action bar under the setup steps.
  static const dock = Color(0x66FFFDF7);

  /// `bg-background/60`, recessed chips inside a card.
  static const recessed = Color(0x99F8F3E8);

  /// `border-card/80`.
  static const edge = Color(0xCCFFFDF7);

  /// `ring-1 ring-inset ring-white/50`.
  static const ring = Color(0x80FFFFFF);

  /// `inset 0 1px 0 0 rgba(255,255,255,0.6)`: the specular top highlight.
  static const highlight = Color(0x99FFFFFF);

  /// Backdrop blur sigma for `backdrop-blur-xl` (24px CSS blur ≈ sigma 12).
  static const blur = 12.0;

  /// Backdrop blur sigma for `backdrop-blur-2xl` tracks and bars.
  static const blurStrong = 20.0;

  /// Opaque replacement used when the platform requests high contrast.
  static const contrastFill = AppColors.card;
}

/// Sleek "Menu · Nhắc nước" (v11) gradients, from the theme's chart colours
/// at the design's opacities (`chart-3` = [AppColors.chartBlue], `chart-2` =
/// [AppColors.chartGold], `chart-4` = [AppColors.chartPeach]).
abstract final class AppMenu {
  /// Water card: `from-chart-3/25 via-card/70 to-secondary/60`.
  static const waterCard = [
    Color(0x407FA8B5),
    AppGlass.fill,
    Color(0x99E4ECDD),
  ];

  /// Water card waves: `chart-3/25` (96 dp) and `chart-3/15` (64 dp).
  static const waveBack = Color(0x407FA8B5);
  static const waveFront = Color(0x267FA8B5);
  static const waveBackHeight = 96.0;
  static const waveFrontHeight = 64.0;

  /// Icon wells, `from` → `to` with a `white/60` edge.
  /// Water well is opaque (card → `waterLight` at 25 % over card) with a
  /// solid edge and [wellLift], so the drop stays legible over the waves;
  /// the design's translucent `chart-3` well blended into them.
  static const wellWater = [AppColors.card, Color(0xFFE6EFF0)];
  static const wellWaterEdge = AppColors.card;
  static const wellLift = [
    BoxShadow(
      color: Color(0x2E3B2F25),
      blurRadius: 12,
      spreadRadius: -2,
      offset: Offset(0, 4),
    ),
  ];
  static const wellGoal = [Color(0x59E0B54A), AppColors.card];
  static const wellPrivacy = [AppColors.secondary, Color(0x407FA8B5)];
  static const wellHelp = [Color(0x59EFB99A), AppColors.card];
  static const wellEdge = Color(0x99FFFFFF);

  /// `size-12` water well, `size-11` row wells, `rounded-2xl`.
  static const wellLarge = 48.0;
  static const well = 44.0;

  /// `gap-3.5` between well and text; rows are `min-h-[64px]`.
  static const rowGap = 14.0;
  static const rowMinHeight = 64.0;

  /// `divide-border/60` between App rows.
  static const divider = Color(0x99E7DDCB);
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const stepGap = 6.0;
  static const denseGap = 10.0;
  static const denseVertical = 14.0;
  static const pageHorizontal = 24.0;

  /// `px-5`: the gutter of the Profile Setup exports.
  static const gutter = 20.0;
  static const pageTop = 40.0;
  static const onboardingTop = 56.0;
  static const onboardingBottom = 40.0;
  static const card = 20.0;
  static const navInset = 20.0;
  static const navBottom = 16.0;
  static const navFabRise = sm;
  static const contentBottom = 88.0;
  static const fieldGap = 6.0;
  static const navLabelGap = 2.0;
}

abstract final class AppRadii {
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const pill = 999.0;
  // PhotoEstimating / PhotoEstimationError export radii, including CSS squircle scaling.
  static const estimationSteps = 70.0;
  static const estimationHero = 110.0;
  // MealReview glass radii (rem x 16 x the 2.5 squircle multiplier).
  static const glassHero = 90.0;
  static const glassPanel = 80.0;
  static const glassItem = 70.0;
  // Liquid glass cards: `rounded-3xl` (32) and `rounded-2xl` (24) x 2.5.
  static const glassCard = 80.0;
  static const glassInner = 60.0;
}

abstract final class AppSizes {
  // VoiceMealInput / VoiceMealConfirm export geometry.
  static const voiceGradient = 520.0;
  static const voiceMascot = 96.0;
  static const voiceConfirmHeroMascot = 64.0;
  static const voiceConfirmGradient = 384.0;
  // Recorder waveform: `h-32` with `w-[3px]` bars and 3px gaps.
  static const voiceWaveform = 128.0;
  static const voiceWaveBar = 3.0;
  static const voiceRecordDot = 10.0;
  static const voiceRecordButton = 80.0;
  // Live-text state (VoiceLiveB – ThinWave): `h-10` waveform band,
  // `text-[28px]` words with a 1.1em caret capped at `max-h-[22rem]`, and
  // the blur the words rise from.
  static const voiceWaveformBand = 40.0;
  static const voiceCaret = 30.0;
  static const voiceLiveTextMax = 352.0;
  static const voiceRevealBlur = 8.0;
  static const iconBadge = 11.0;

  /// 13 px meta icons beside `text-xs` (target plan weeks and date).
  static const iconMeta = 13.0;
  static const iconInfo = 14.0;
  static const iconXs = 16.0;
  static const iconSm = 18.0;
  static const iconMd = 20.0;
  static const iconLg = 24.0;
  static const iconXl = 28.0;

  /// Leading/trailing icon and loading spinner inside [AppButton].
  static const buttonIcon = iconSm;

  /// Icon inside [AppButton.card] (Sleek Today First Run `ph:plus-bold` 20).
  static const buttonIconCard = iconMd;
  static const hero = 224.0;
  static const welcomeOuterHalo = 288.0;
  static const welcomeInnerHalo = 208.0;
  static const avatar = 40.0;
  static const avatarLarge = 56.0;
  static const choiceIcon = 48.0;
  static const iconTile = 32.0;

  /// The day number circle in Home's seven-day strip.
  static const dayCircle = 36.0;

  /// Widest a centered confirmation dialog grows on large screens.
  static const dialogMax = 340.0;

  /// Weight sheet ruler: total height, tick lengths and the center line.
  static const weightRuler = 64.0;
  static const weightRulerMajor = 28.0;
  static const weightRulerHalf = 20.0;
  static const weightRulerMinor = 12.0;
  static const weightRulerIndicator = 3.0;
  // Target Custom slider: `h-2` track and a `size-7` thumb.
  static const sliderTrack = 8.0;
  static const sliderThumb = 28.0;
  // Sex choice light icon (30 px in a `size-14` circle) in Body Direction 2.
  static const sexChoiceIcon = 30.0;
  // Plan sheet mascot (`size-24`) and tile icon circles (`size-9`).
  static const planMascot = 96.0;
  static const planTileIcon = 36.0;
  static const compactAction = 48.0;
  static const action = 56.0;
  static const nav = 60.0;
  static const navFab = 56.0;
  static const navSelection = 42.0;
  // Home kcal card (Sleek Home 01–15): `h-3` meter, `size-10` goal icon
  // well, `size-7` status circle with a 16 px glyph.
  static const energyMeter = 12.0;
  static const energyIconWell = 40.0;
  static const energyStatusIcon = 28.0;
  // Drawn tumbler glass and its touch target on the Home water card.
  static const waterGlassWidth = 26.0;
  static const waterGlassHeight = 32.0;
  static const waterGlassTarget = 48.0;
  static const chart = 128.0;
  static const contentMax = 448.0;
  static const readableWidth = 320.0;
  static const backAction = 44.0;
  static const summaryImage = 80.0;
  static const setupBadgeMax = 112.0;
  static const photoPermissionBadge = 112.0;
  static const photoPermissionIcon = 44.0;
  static const photoShutter = 80.0;
  static const photoShutterStroke = 3.0;
  // CameraPreview export sizes. The surrounding action target remains 56 dp.
  static const photoCloseControl = 44.0;
  static const photoControl = 48.0;
  // PhotoPreview export geometry.
  static const photoPreviewImageHeight = 440.0;
  static const photoPreviewRetake = 56.0;
  static const photoPreviewBadge = 36.0;
  static const photoPreviewBadgeMax = 168.0;
  static const photoPreviewPageHorizontal = 20.0;
  // PhotoEstimating / PhotoEstimationError export geometry.
  static const estimationMascot = 112.0;
  static const estimationErrorMascot = 144.0;
  static const estimationPhotoInset = 18.0;
  static const estimationRingInset = 7.0;
  static const estimationGradient = 480.0;
  static const estimationStepIcon = 32.0;
  static const estimationNotice = 36.0;
  static const estimationErrorIcon = 22.0;
  static const estimationStatusMax = 96.0;
  static const estimationBlur = 64.0;
  static const estimationGlassBlur = 24.0;
  // MealReview export geometry.
  static const mealReviewHero = 224.0;
  static const mealReviewMacroBar = 10.0;
  static const mealReviewMascot = 40.0;
  static const glassControl = 44.0;
  static const glassBlur = 20.0;
}

abstract final class AppBorders {
  static const hairline = 1.0;
  static const selected = 2.0;

  /// `border-[3px]` ring of the slider thumb.
  static const thumbRing = 3.0;
}

abstract final class AppScales {
  static const pressed = 0.97;
  static const pressedCard = 0.98;
}

abstract final class AppFractions {
  static const sheetMaxHeight = 0.85;
}

abstract final class AppChartFactors {
  static const empty = 0.08;
}

abstract final class AppShadows {
  // VoiceMealInput stop button: `0 16px 32px -12px rgba(47,93,58,.85)`.
  static const voiceRecord = [
    BoxShadow(
      color: Color(0xD92F5D3A),
      blurRadius: 32,
      spreadRadius: -12,
      offset: Offset(0, 16),
    ),
  ];
  static const photoPreviewImage = BoxShadow(
    color: Color(0x803B2F25),
    blurRadius: 60,
    spreadRadius: -26,
    offset: Offset(0, 32),
  );
  // PhotoEstimating and PhotoEstimationError export shadows.
  static const estimationSteps = [
    BoxShadow(
      color: Color(0x4D3B2F25),
      blurRadius: 36,
      spreadRadius: -18,
      offset: Offset(0, 16),
    ),
  ];
  static const estimationHero = [
    BoxShadow(
      color: Color(0x4D3B2F25),
      blurRadius: 48,
      spreadRadius: -20,
      offset: Offset(0, 24),
    ),
  ];
  // Sleek primary action: `shadow-lg shadow-primary/25`.
  static const primaryAction = [
    BoxShadow(
      color: Color(0x402F5D3A),
      blurRadius: 15,
      spreadRadius: -3,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x402F5D3A),
      blurRadius: 6,
      spreadRadius: -4,
      offset: Offset(0, 4),
    ),
  ];
  // MealReview glass shadows.
  static const glassPanel = [
    BoxShadow(
      color: Color(0x593B2F25),
      blurRadius: 48,
      spreadRadius: -24,
      offset: Offset(0, 24),
    ),
  ];
  static const glassItem = [
    BoxShadow(
      color: Color(0x593B2F25),
      blurRadius: 36,
      spreadRadius: -22,
      offset: Offset(0, 18),
    ),
  ];
  static const glassControl = [
    BoxShadow(
      color: Color(0x663B2F25),
      blurRadius: 28,
      spreadRadius: -12,
      offset: Offset(0, 10),
    ),
  ];
  static const glassDock = [
    BoxShadow(
      color: Color(0x733B2F25),
      blurRadius: 60,
      spreadRadius: -20,
      offset: Offset(0, 30),
    ),
  ];
  static const mealReviewHero = [
    BoxShadow(
      color: Color(0x8C3B2F25),
      blurRadius: 60,
      spreadRadius: -28,
      offset: Offset(0, 32),
    ),
  ];
  // Liquid glass card drop shadow: `0 20px 40px -20px rgba(59,47,37,.3)`.
  static const glassCard = [
    BoxShadow(
      color: Color(0x4D3B2F25),
      blurRadius: 40,
      spreadRadius: -20,
      offset: Offset(0, 20),
    ),
  ];
  // Selected primary card: `shadow-xl shadow-primary/30`.
  static const primaryCard = [
    BoxShadow(
      color: Color(0x4D2F5D3A),
      blurRadius: 25,
      spreadRadius: -5,
      offset: Offset(0, 20),
    ),
    BoxShadow(
      color: Color(0x4D2F5D3A),
      blurRadius: 10,
      spreadRadius: -6,
      offset: Offset(0, 8),
    ),
  ];
  // Setup action dock: `shadow-[0_-12px_32px_-16px_rgba(59,47,37,0.25)]`.
  static const dock = [
    BoxShadow(
      color: Color(0x403B2F25),
      blurRadius: 32,
      spreadRadius: -16,
      offset: Offset(0, -12),
    ),
  ];
  static const primaryGlow = [
    BoxShadow(
      color: Color(0xCC2F5D3A),
      blurRadius: 30,
      spreadRadius: -12,
      offset: Offset(0, 14),
    ),
  ];
  static const nav = [
    BoxShadow(
      color: Color(0x403B2F25),
      blurRadius: 28,
      spreadRadius: -10,
      offset: Offset(0, 12),
    ),
  ];
  static const navFab = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 15,
      spreadRadius: -3,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 6,
      spreadRadius: -4,
      offset: Offset(0, 4),
    ),
  ];
}

abstract final class AppFonts {
  static const body = 'Be Vietnam Pro';
  static const heading = 'Nunito';
}

abstract final class AppTypography {
  static const display = TextStyle(
    fontFamily: AppFonts.heading,
    color: AppColors.foreground,
    fontSize: 36,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static final welcomeHeadline = display.copyWith(
    height: 1.25,
    leadingDistribution: TextLeadingDistribution.even,
  );
  static final welcomeWordmark = display.copyWith(
    fontSize: 16,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );
  static const title = TextStyle(
    fontFamily: AppFonts.heading,
    color: AppColors.foreground,
    fontSize: 24,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
  );
  static const screenTitle = TextStyle(
    fontFamily: AppFonts.heading,
    color: AppColors.foreground,
    fontSize: 30,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  static const sectionTitle = TextStyle(
    fontFamily: AppFonts.heading,
    color: AppColors.foreground,
    fontSize: 18,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    height: 28 / 18,
  );
  static const subtitle = TextStyle(
    fontFamily: AppFonts.heading,
    color: AppColors.primary,
    fontSize: 18,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
  );
  static const body = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.foreground,
    fontSize: 16,
    letterSpacing: 0,
    height: 1.5,
  );
  static const bodySmall = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.mutedForeground,
    fontSize: 14,
    letterSpacing: 0,
    height: 1.625,
  );
  static final welcomeBody = bodySmall.copyWith(
    leadingDistribution: TextLeadingDistribution.even,
  );
  static const label = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.mutedForeground,
    fontSize: 12,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  static const micro = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.mutedForeground,
    fontSize: 11,
    letterSpacing: 0,
    height: 1.4,
  );
  static const button = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  static const numericHero = TextStyle(
    fontFamily: AppFonts.heading,
    color: AppColors.foreground,
    fontSize: 48,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );
  static const numericDisplay = TextStyle(
    fontFamily: AppFonts.heading,
    color: AppColors.foreground,
    fontSize: 60,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    height: 1,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const numericLarge = TextStyle(
    fontFamily: AppFonts.heading,
    color: AppColors.foreground,
    fontSize: 36,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );
  static const caption = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.mutedForeground,
    fontSize: 12,
    letterSpacing: 0,
    height: 1.5,
  );
  static const cardTitle = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.foreground,
    fontSize: 16,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  /// Estimate row value: `font-heading text-xl font-bold tabular-nums`.
  static const metricValue = TextStyle(
    fontFamily: AppFonts.heading,
    color: AppColors.foreground,
    fontSize: 20,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    height: 1.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Choice card label: `text-sm font-semibold text-foreground`.
  static const choiceTitle = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.foreground,
    fontSize: 14,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
  );
  static final setupHeading = screenTitle.copyWith(height: 1.25);
  static final setupCaption = bodySmall.copyWith(height: 20 / 14);
  static final setupNumber = title.copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  static const optionDescription = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.mutedForeground,
    fontSize: 14,
    letterSpacing: 0,
    height: 20 / 14,
  );
  static final photoPermissionBody = bodySmall.copyWith(fontSize: 15);

  /// Menu row title: `text-[15px] font-semibold`.
  static final menuRowTitle = cardTitle.copyWith(fontSize: 15);
  static final estimationBody = photoPermissionBody.copyWith(height: 1.625);
  static final estimationStep = estimationBody.copyWith(
    color: AppColors.foreground,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  // VoiceMealInput timer: `font-heading text-7xl font-bold tabular-nums
  // tracking-tight leading-none`.
  static const voiceTimer = TextStyle(
    fontFamily: AppFonts.heading,
    color: AppColors.foreground,
    fontSize: 72,
    letterSpacing: -1.8,
    fontWeight: FontWeight.w700,
    height: 1,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  // Live-text status time: `text-base font-semibold tabular-nums`.
  static const voiceInlineTimer = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.foreground,
    fontSize: 16,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    height: 1.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  // Live-text state words: `font-heading text-[28px] font-bold leading-snug`.
  static const voiceLiveText = TextStyle(
    fontFamily: AppFonts.heading,
    color: AppColors.foreground,
    fontSize: 28,
    letterSpacing: 0,
    fontWeight: FontWeight.w700,
    height: 1.375,
  );
  static const error = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.destructive,
    fontSize: 14,
    letterSpacing: 0,
    height: 20 / 14,
  );
  static const fieldLabel = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.foreground,
    fontSize: 14,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
  );
  static const navLabel = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.mutedForeground,
    fontSize: 12,
    letterSpacing: 0,
    height: 16 / 12,
  );
}
