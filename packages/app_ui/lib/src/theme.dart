part of '../app_ui.dart';

abstract final class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.body,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      surface: AppColors.card,
      onSurface: AppColors.foreground,
      error: AppColors.destructive,
      onError: AppColors.primaryForeground,
      outline: AppColors.border,
    ),
    textTheme: const TextTheme(
      displayMedium: AppTypography.display,
      headlineSmall: AppTypography.title,
      titleLarge: AppTypography.title,
      titleMedium: AppTypography.subtitle,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.bodySmall,
      bodySmall: AppTypography.caption,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.label,
      labelSmall: AppTypography.micro,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.input,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
    // Target Custom export: `h-2` secondary track filled with primary and a
    // ringed card thumb; no ticks or value bubble.
    sliderTheme: SliderThemeData(
      trackHeight: AppSizes.sliderTrack,
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.secondary,
      disabledActiveTrackColor: AppColors.border,
      disabledInactiveTrackColor: AppColors.muted,
      overlayColor: AppColors.primary.withValues(alpha: 0.12),
      thumbShape: const AppSliderThumbShape(),
      trackShape: const RoundedRectSliderTrackShape(),
      tickMarkShape: SliderTickMarkShape.noTickMark,
      showValueIndicator: ShowValueIndicator.never,
    ),
    // `w-[52px] h-8` switch: primary when on, muted with a border when off,
    // and the same card-coloured 24 px knob in both states.
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(AppColors.card),
      // An (empty) icon keeps the knob at full size when the switch is off.
      thumbIcon: const WidgetStatePropertyAll(Icon(null)),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.muted,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.border,
      ),
    ),
  );
}

abstract final class AppMotion {
  static const estimationOrbit = Duration(seconds: 2);
  static const estimationSpinner = Duration(seconds: 1);
  // VoiceMealInput listening feedback.
  static const voiceBlink = Duration(milliseconds: 900);
  // Waveform ⇄ live-text morph and the waveform's entrance.
  static const voiceReveal = Duration(milliseconds: 820);
  static const voiceEnter = Duration(milliseconds: 520);
  static const voiceGrow = Duration(milliseconds: 220);
  static const feedbackCurve = Curves.easeOutCubic;
  // Selection: tone cross-fade, the pop when a card becomes chosen, the
  // check mark and rolling numbers.
  static const selection = Duration(milliseconds: 260);
  static const selectionCurve = Curves.easeOutCubic;
  static const selectionPop = Duration(milliseconds: 340);
  static const checkIn = Duration(milliseconds: 280);
  static const rollingText = Duration(milliseconds: 300);
  // Step change and the staggered rise of a step's cards.
  static const stepSwitch = Duration(milliseconds: 360);
  static const entrance = Duration(milliseconds: 420);
  static const entranceStagger = Duration(milliseconds: 55);
  static const entranceRise = 18.0;
  static const progressFill = Duration(milliseconds: 420);
  // Home kcal meter: grows to its value with the design's ease-out.
  static const todayMeter = Duration(milliseconds: 700);
  static const todayMeterCurve = Cubic(0.22, 1, 0.36, 1);
  // Water glass: pour (fill, bounce, droplets) and drain (shake).
  static const waterPour = Duration(milliseconds: 700);
  static const waterDrain = Duration(milliseconds: 450);
  // Menu water reminder card: one full drift of the background waves.
  static const waterWaves = Duration(seconds: 8);
  // A just-saved meal row fades from the highlight back to the card.
  static const todayHighlight = Duration(milliseconds: 1600);

  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

  // Log-meal halo on an empty day: three slow swells.
  static const pulse = Duration(milliseconds: 1400);
  static const pulseCount = 3;
  // Plan sheet (Plan Ready export): slide-up with a little overshoot, the
  // mascot hop and sparkles, the kcal count, the energy bar and the CTA shine.
  static const planSheet = Duration(milliseconds: 520);
  static const planSheetCurve = Cubic(0.2, 0.9, 0.3, 1.15);
  static const planMascotHop = Duration(milliseconds: 700);
  static const planSparkle = Duration(milliseconds: 1400);
  static const planCount = Duration(milliseconds: 1100);
  static const planBar = Duration(milliseconds: 1200);
  static const planShine = Duration(milliseconds: 2000);

  // Segmented control thumb slide and label colour.
  static const segmentSlide = Duration(milliseconds: 280);
  static const segmentCurve = Curves.easeOutCubic;
  // BMI card reveal: debounce while typing, then grow-in and ring sweep.
  static const bmiShowDelay = Duration(milliseconds: 350);
  static const bmiHideDelay = Duration(milliseconds: 700);
  static const bmiReveal = Duration(milliseconds: 480);
  static const bmiRing = Duration(milliseconds: 1100);
  static const bmiRevealCurve = Curves.easeOutQuart;
  static const feedbackPress = Duration(milliseconds: 75);
  static const feedbackRelease = Duration(milliseconds: 150);
  static const dockCurve = Curves.easeInOutSine;

  static Duration dockSelectionDuration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 300);

  static Duration dockIconDuration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 220);

  static Duration dockDuration(BuildContext context, {required bool showing}) {
    if (MediaQuery.disableAnimationsOf(context)) return Duration.zero;
    return Duration(milliseconds: showing ? 240 : 360);
  }

  static Duration feedbackDuration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : feedbackRelease;

  static Duration duration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 250);
}
