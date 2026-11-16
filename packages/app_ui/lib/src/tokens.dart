part of '../app_ui.dart';

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
  static const accentForeground = Color(0xFF4A2E1F);
  static const destructive = Color(0xFF8A4B2E);
  static const card = Color(0xFFFFFDF7);
  static const input = Color(0xFFFFFCF5);
  static const border = Color(0xFFE7DDCB);
  static const chartBlue = Color(0xFF7FA8B5);
  static const chartGold = Color(0xFFE0B54A);
  static const chartPeach = Color(0xFFEFB99A);
  static const chartStone = Color(0xFFB8A890);
  static const surface = card;
  static const outline = border;
  static const modalBarrier = Color(0x403B2F25);
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const pageHorizontal = 24.0;
  static const pageTop = 40.0;
  static const onboardingTop = 48.0;
  static const onboardingBottom = 40.0;
  static const card = 20.0;
  static const navInset = 16.0;
  static const navBottom = 16.0;
  static const navInner = 8.0;
  static const contentBottom = 96.0;
  static const fieldGap = 6.0;
  static const navLabelGap = 2.0;
  static const small = xs;
  static const medium = md;
  static const large = lg;
}

abstract final class AppRadii {
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const pill = 999.0;
  static const cardSquircle = lg;
}

abstract final class AppSizes {
  static const iconXs = 16.0;
  static const iconSm = 18.0;
  static const iconMd = 20.0;
  static const iconLg = 24.0;
  static const iconXl = 28.0;
  static const hero = 224.0;
  static const avatar = 40.0;
  static const avatarLarge = 56.0;
  static const choiceIcon = 48.0;
  static const compactAction = 48.0;
  static const action = 56.0;
  static const nav = 64.0;
  static const navFab = 64.0;
  static const chart = 128.0;
  static const contentMax = 448.0;
  static const readableWidth = 320.0;
  static const backAction = 44.0;
  static const weekInput = 44.0;
  static const summaryImage = 80.0;
}

abstract final class AppBorders {
  static const hairline = 1.0;
  static const selected = 2.0;
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

abstract final class AppOffsets {
  static const navFab = Offset(0, -16);
}

abstract final class AppShadows {
  static const nav = [
    BoxShadow(
      color: Color(0x593B2F25),
      blurRadius: 36,
      spreadRadius: -12,
      offset: Offset(0, 16),
    ),
  ];
}

abstract final class AppFonts {
  static const body = 'Be Vietnam Pro';
  static const heading = 'Nunito';
  static const serif = 'Playfair Display';
  static const mono = 'JetBrains Mono';
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
  static const pageHeading = title;
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
  static const cardSubtitle = caption;
  static const optionDescription = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.mutedForeground,
    fontSize: 14,
    letterSpacing: 0,
    height: 20 / 14,
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
  static const inputValue = TextStyle(
    fontFamily: AppFonts.mono,
    color: AppColors.foreground,
    fontSize: 16,
    letterSpacing: 0,
    height: 1.5,
  );
  static const navLabel = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.mutedForeground,
    fontSize: 12,
    letterSpacing: 0,
    height: 16 / 12,
  );
  static const navLabelSelected = TextStyle(
    fontFamily: AppFonts.body,
    color: AppColors.primary,
    fontSize: 12,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
  );
}
