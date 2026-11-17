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
  static const welcomeHalo = Color(0x66F2C4A8);
  static const accentForeground = Color(0xFF4A2E1F);
  static const destructive = Color(0xFF8A4B2E);
  static const card = Color(0xFFFFFDF7);
  static const input = Color(0xFFFFFCF5);
  static const border = Color(0xFFE7DDCB);
  static const chartBlue = Color(0xFF7FA8B5);
  static const waterTint = Color(0x337FA8B5);
  static const chartGold = Color(0xFFE0B54A);
  static const chartPeach = Color(0xFFEFB99A);
  static const chartStone = Color(0xFFB8A890);
  static const surface = card;
  static const outline = border;
  static const navSelection = Color(0xB8D9E8D5);
  static const navActionHighlight = Color(0xFF578561);
  static const navActionRim = Color(0xBB9CC09A);
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
  static const stepGap = 6.0;
  static const denseGap = 10.0;
  static const denseVertical = 14.0;
  static const pageHorizontal = 24.0;
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
  // The export multiplies rounded-xl (20) and rounded-2xl (24) by 2.5.
  static const exportCompactSquircle = 50.0;
  static const exportCardSquircle = 60.0;
}

abstract final class AppSizes {
  static const iconInfo = 14.0;
  static const iconXs = 16.0;
  static const iconSm = 18.0;
  static const iconMd = 20.0;
  static const iconLg = 24.0;
  static const iconXl = 28.0;
  static const hero = 224.0;
  static const welcomeOuterHalo = 288.0;
  static const welcomeInnerHalo = 208.0;
  static const avatar = 40.0;
  static const avatarLarge = 56.0;
  static const choiceIcon = 48.0;
  static const compactAction = 48.0;
  static const action = 56.0;
  static const nav = 60.0;
  static const navFab = 56.0;
  static const navSelection = 42.0;
  static const energyMarkerHeight = 24.0;
  static const waterIndicator = 32.0;
  static const chart = 128.0;
  static const contentMax = 448.0;
  static const readableWidth = 320.0;
  static const backAction = 44.0;
  static const weekInput = 44.0;
  static const summaryImage = 80.0;
  static const setupMascot = 128.0;
  static const setupMascotHalo = 144.0;
  static const setupBadgeMax = 112.0;
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

abstract final class AppShadows {
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
  static const welcomeAction = TextStyle(
    leadingDistribution: TextLeadingDistribution.even,
  );
  static const cardSubtitle = caption;
  static final setupHeading = screenTitle.copyWith(height: 1.25);
  static final setupCaption = bodySmall.copyWith(height: 20 / 14);
  static final setupFieldLabel = caption.copyWith(
    fontWeight: FontWeight.w500,
    height: 2,
  );
  static final setupNumber = title.copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );
  static final setupTargetNumber = screenTitle.copyWith(
    fontFeatures: const [FontFeature.tabularFigures()],
  );
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
}
