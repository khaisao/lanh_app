import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:material_ui/material_ui.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final goal = ref.watch(goalControllerProvider).value;
    final goalName = goal == null ? 'Chưa đặt mục tiêu' : _goalName(goal.type);
    return Scaffold(
      key: const Key('menu-screen'),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings.menu,
                        style: AppTypography.screenTitle,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/menu/about'),
                      child: Text(strings.about, style: AppTypography.button),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _ProfileCard(goalName: goalName),
                const SizedBox(height: AppSpacing.lg),
                _MenuGroup(
                  title: 'Mục tiêu và bữa ăn',
                  items: [
                    _MenuItem(
                      'Chỉnh mục tiêu',
                      goalName,
                      'ph-target',
                      route: '/goal',
                    ),
                    const _MenuItem('Bữa đã lưu', '', 'ph-bookmark-simple'),
                    const _MenuItem('Nhắc nhở', '', 'ph-bell-simple-ringing'),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const _MenuGroup(
                  title: 'Riêng tư và thiết bị',
                  items: [
                    _MenuItem('Quyền riêng tư', '', 'ph-shield-check'),
                    _MenuItem(
                      'Ảnh và camera',
                      'Chỉ dùng để ước lượng bữa ăn',
                      'ph-camera',
                    ),
                    _MenuItem('Thông báo', '', 'ph-bell'),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const _MenuGroup(
                  title: 'Tài khoản và hỗ trợ',
                  items: [
                    _MenuItem('Tài khoản', '', 'ph-user-circle'),
                    _MenuItem(
                      'Trợ giúp và phản hồi',
                      '',
                      'ph-chat-circle-dots',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                const Center(
                  child: Text(
                    'Lành · Mỗi bữa lành, một mầm vui.',
                    style: AppTypography.caption,
                  ),
                ),
              ],
            ),
          ),
        ),
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.goalName});

  final String goalName;

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
        const CircleAvatar(
          radius: AppSizes.avatarLarge / 2,
          backgroundColor: AppColors.secondary,
          child: AppIcon.asset('ph-user-circle', color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).appTitle,
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text('Mục tiêu: $goalName', style: AppTypography.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.title, required this.items});

  final String title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Text(title.toUpperCase(), style: AppTypography.label),
      ),
      const SizedBox(height: AppSpacing.xs),
      DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              _MenuRow(item: items[index]),
              if (index < items.length - 1)
                const Divider(
                  height: AppBorders.hairline,
                  color: AppColors.border,
                ),
            ],
          ],
        ),
      ),
    ],
  );
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: item.route == null ? null : () => context.push(item.route!),
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          AppIcon.asset(
            item.icon,
            size: AppSizes.iconMd,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: item.subtitle.isEmpty
                ? Text(item.title, style: AppTypography.cardTitle)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTypography.cardTitle),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(item.subtitle, style: AppTypography.cardSubtitle),
                    ],
                  ),
          ),
          const AppIcon.asset(
            'ph-caret-right',
            size: AppSizes.iconSm,
            color: AppColors.mutedForeground,
          ),
        ],
      ),
    ),
  );
}

class _MenuItem {
  const _MenuItem(this.title, this.subtitle, this.icon, {this.route});

  final String title;
  final String subtitle;
  final String icon;
  final String? route;
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('about-screen'),
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
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => context.pop(),
                    icon: const AppIcon.asset(
                      'ph-arrow-left-bold',
                      size: AppSizes.iconMd,
                    ),
                    label: const Text('Quay lại'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsetsDirectional.only(
                        start: AppSpacing.xs,
                      ),
                    ),
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
          ),
        ),
      ),
    );
  }
}
