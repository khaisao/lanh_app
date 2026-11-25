import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/features/water_reminder/water_reminder.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Sleek "Menu · Nhắc nước" (v11): Habits (water reminder, goal) and App
/// (privacy, help). Privacy and Help have no screen yet.
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final goal = ref.watch(profileGoalProvider).value;
    return Scaffold(
      key: const Key('menu-screen'),
      body: AppPageList(
        children: [
          Text(strings.menu, style: AppTypography.title),
          const SizedBox(height: AppSpacing.xl),
          Text(strings.menuHabits, style: AppTypography.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          const WaterReminderCard(),
          const SizedBox(height: AppSpacing.sm),
          _MenuGroup(
            rows: [
              _MenuRow(
                key: const Key('menu-goal'),
                title: strings.menuGoal,
                subtitle: goal == null
                    ? strings.menuGoalNone
                    : strings.menuGoalSubtitle(_goalName(goal.type)),
                icon: 'ph-target',
                well: AppMenu.wellGoal,
                onTap: () => context.push('/profile-setup'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(strings.menuApp, style: AppTypography.sectionTitle),
          const SizedBox(height: AppSpacing.sm),
          _MenuGroup(
            padded: true,
            rows: [
              _MenuRow(
                title: strings.menuPrivacy,
                icon: 'ph-shield-check',
                well: AppMenu.wellPrivacy,
              ),
              _MenuRow(
                title: strings.menuHelp,
                subtitle: strings.menuHelpSubtitle,
                icon: 'ph-chat-circle-dots',
                well: AppMenu.wellHelp,
                iconColor: AppColors.accentForeground,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _goalName(GoalType type) => switch (type) {
    GoalType.lose => 'Giảm cân',
    GoalType.gain => 'Tăng cân',
    GoalType.maintain => 'Giữ cân',
    GoalType.logOnly => 'Chỉ ghi bữa',
  };
}

/// One glass section of rows; [padded] adds the App group's `py-2` and
/// `divide-border/60` between rows.
class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.rows, this.padded = false});

  final List<_MenuRow> rows;
  final bool padded;

  @override
  Widget build(BuildContext context) => AppGlassCard(
    radius: AppRadii.glassInner,
    padding: EdgeInsets.symmetric(vertical: padded ? AppSpacing.xs : 0),
    // Own Material so row ink shows above the glass fill.
    child: Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0)
              const Divider(
                height: AppBorders.hairline,
                thickness: AppBorders.hairline,
                color: AppMenu.divider,
              ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: padded ? AppSpacing.gutter : AppSpacing.md,
              ),
              child: rows[index],
            ),
          ],
        ],
      ),
    ),
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    super.key,
    required this.title,
    required this.icon,
    required this.well,
    this.subtitle,
    this.iconColor = AppColors.primary,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String icon;
  final List<Color> well;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppMenu.rowMinHeight),
      child: Row(
        children: [
          AppGradientIconWell(icon: icon, gradient: well, color: iconColor),
          const SizedBox(width: AppMenu.rowGap),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.menuRowTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.navLabelGap),
                  Text(subtitle!, style: AppTypography.caption),
                ],
              ],
            ),
          ),
          const ExcludeSemantics(
            child: AppIcon.asset(
              'ph-caret-right',
              size: AppSizes.iconXs,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    ),
  );
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('about-screen'),
      body: AppPageList(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppNavigationButton.back(
              onPressed: () => context.pop(),
              tooltip: strings.profileBack,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(strings.about, style: AppTypography.screenTitle),
          const SizedBox(height: AppSpacing.md),
          Text(strings.aboutBody, style: AppTypography.body),
          const SizedBox(height: AppSpacing.lg),
          Text(strings.baseNotice, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
