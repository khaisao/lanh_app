part of '../app_ui.dart';

abstract final class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.body,
    scaffoldBackgroundColor: AppColors.background,
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
  );
}

abstract final class AppMotion {
  static const feedbackCurve = Curves.easeOutCubic;
  static const feedbackPress = Duration(milliseconds: 75);
  static const feedbackRelease = Duration(milliseconds: 150);

  static Duration feedbackDuration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : feedbackRelease;

  static Duration duration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 250);
}
