import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:material_ui/material_ui.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final goal = ref.watch(goalControllerProvider).value;
    final goalName = goal == null ? 'Chưa đặt' : _goalName(goal.type);
    return Scaffold(
      key: const Key('today-screen'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.pageTop,
                AppSpacing.pageHorizontal,
                AppSpacing.contentBottom,
              ),
              children: [
                _TodayHeader(strings: strings),
                const SizedBox(height: AppSpacing.lg),
                const _SummaryCard(),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  roundedRectangle: true,
                  onPressed: () => unawaited(showMealMethodSheet(context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppIcon.asset(
                        'ph-plus-bold',
                        size: AppSizes.iconMd,
                        color: AppColors.primaryForeground,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          strings.logMeal,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _GoalCard(
                        goalName: goalName,
                        onTap: () => context.push('/profile-setup'),
                        hasGoal: goal != null,
                        schedule: goal?.schedule,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(child: _WaterCard()),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _mealsSection(context, hasGoal: goal != null),
                const SizedBox(height: AppSpacing.lg),
                _ReminderCard(),
                const SizedBox(height: AppSpacing.md),
                Text(strings.baseNotice, style: AppTypography.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mealsSection(BuildContext context, {required bool hasGoal}) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text('Bữa ăn hôm nay', style: AppTypography.sectionTitle),
      const SizedBox(height: AppSpacing.sm),
      if (!hasGoal)
        Container(
          padding: const EdgeInsets.all(AppSpacing.card),
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            children: [
              const SizedBox.square(
                dimension: AppSizes.choiceIcon,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadii.md),
                    ),
                  ),
                  child: Center(
                    child: AppIcon.asset(
                      'ph-bowl-food',
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text('Chưa có bữa nào', style: AppTypography.cardTitle),
              const SizedBox(height: AppSpacing.xxs),
              const Text(
                'Chụp, tìm, mô tả hoặc nhập tay một bữa để bắt đầu nhật ký.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton.secondary(
                onPressed: () => unawaited(showMealMethodSheet(context)),
                child: const Text('Ghi bữa đầu tiên'),
              ),
            ],
          ),
        ),
      if (hasGoal)
        for (final meal in const [
          ('Bữa sáng', 'ph-sun-horizon'),
          ('Bữa trưa', 'ph-sun'),
          ('Bữa tối', 'ph-moon'),
        ])
          InkWell(
            onTap: () => unawaited(showMealMethodSheet(context)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: AppSizes.avatarLarge,
                    height: AppSizes.avatarLarge,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Center(
                      child: AppIcon.asset(
                        meal.$2,
                        size: AppSizes.iconLg,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.$1,
                          style: AppTypography.cardTitle.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        const Text(
                          'Chưa ghi',
                          style: AppTypography.cardSubtitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    ],
  );

  String _goalName(GoalType type) => switch (type) {
    GoalType.lose => 'Giảm cân',
    GoalType.gain => 'Tăng cân',
    GoalType.maintain => 'Giữ cân',
    GoalType.logOnly => 'Chỉ ghi bữa',
  };
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.today, style: AppTypography.bodySmall),
            const SizedBox(height: AppSpacing.xxs),
            Text(strings.todayHeading, style: AppTypography.pageHeading),
          ],
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      const CircleAvatar(
        radius: AppSizes.avatar / 2,
        backgroundColor: AppColors.secondary,
        child: AppIcon.asset('ph-user-circle', color: AppColors.primary),
      ),
    ],
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.card),
    decoration: BoxDecoration(
      color: AppColors.card,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppRadii.xl),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Đã ghi hôm nay', style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        const Text('Chưa ghi', style: AppTypography.numericLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppLocalizations.of(context).todayEmptyBody,
          style: AppTypography.bodySmall,
        ),
      ],
    ),
  );
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goalName,
    required this.onTap,
    required this.hasGoal,
    required this.schedule,
  });

  final String goalName;
  final VoidCallback onTap;
  final bool hasGoal;
  final GoalSchedule? schedule;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppRadii.md),
    child: _TileCard(
      background: AppColors.secondary,
      icon: 'ph-target',
      iconColor: AppColors.secondaryForeground,
      title: 'Mục tiêu',
      value: goalName,
      valueColor: AppColors.secondaryForeground,
      footer: switch (schedule) {
        GoalSchedule.none => 'Không có hạn chót',
        GoalSchedule.byDate || GoalSchedule.byWeeks => 'Có thời hạn',
        null => 'Có thể đặt sau',
      },
    ),
  );
}

class _WaterCard extends StatelessWidget {
  const _WaterCard();

  @override
  Widget build(BuildContext context) => _TileCard(
    icon: 'ph-drop',
    title: 'Nước uống',
    value: '0 / 8 ly',
    footer: '',
    child: Row(
      children: List.generate(
        8,
        (_) => Expanded(
          child: Container(
            height: AppSpacing.xs,
            margin: const EdgeInsetsDirectional.only(end: AppSpacing.xxs),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
        ),
      ),
    ),
  );
}

class _TileCard extends StatelessWidget {
  const _TileCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.footer,
    this.background = AppColors.card,
    this.iconColor = AppColors.foreground,
    this.valueColor = AppColors.foreground,
    this.child,
  });

  final String icon;
  final String title;
  final String value;
  final String footer;
  final Color background;
  final Color iconColor;
  final Color valueColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: background,
      border: background == AppColors.card
          ? Border.all(color: AppColors.border)
          : null,
      borderRadius: BorderRadius.circular(AppRadii.md),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppIcon.asset(icon, size: AppSizes.iconSm, color: iconColor),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                title,
                style: AppTypography.label.copyWith(color: iconColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.sectionTitle.copyWith(color: valueColor),
        ),
        if (child != null) ...[const SizedBox(height: AppSpacing.sm), child!],
        if (footer.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(footer, style: AppTypography.micro.copyWith(color: valueColor)),
        ],
      ],
    ),
  );
}

class _ReminderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.card,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppRadii.md),
    ),
    child: Row(
      children: [
        const Image(
          image: AssetImage('assets/design/images/xQ84zhEVfCY.png'),
          width: AppSizes.avatarLarge,
          height: AppSizes.avatarLarge,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mầm nhắc nhẹ', style: AppTypography.cardTitle),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Một bữa nhỏ cũng đủ để bắt đầu.',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
