import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lanh_app/features/goal/goal.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final goal = ref.watch(profileGoalProvider).value;
    return Scaffold(
      key: const Key('progress-screen'),
      body: AppPageList(
        children: [
          Text(strings.progress, style: AppTypography.screenTitle),
          const SizedBox(height: AppSpacing.md),
          const _PeriodToggle(),
          const SizedBox(height: AppSpacing.lg),
          const _GrowthCard(),
          const SizedBox(height: AppSpacing.md),
          const _ConsistencyCard(),
          const SizedBox(height: AppSpacing.md),
          const _WaterProgressCard(),
          const SizedBox(height: AppSpacing.md),
          _GoalProgressCard(goal: goal),
          const SizedBox(height: AppSpacing.md),
          const _BalanceCard(),
          const SizedBox(height: AppSpacing.md),
          const _WeightEmptyCard(),
        ],
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.xxs),
    decoration: BoxDecoration(
      color: AppColors.muted,
      borderRadius: BorderRadius.circular(AppRadii.pill),
    ),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: AppSpacing.xl,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: const Text('Tuần này', style: AppTypography.button),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text('Tháng này', style: AppTypography.bodySmall),
          ),
        ),
      ],
    ),
  );
}

class _GrowthCard extends StatelessWidget {
  const _GrowthCard();

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    color: AppColors.secondary,
    child: Row(
      children: [
        Container(
          width: AppSizes.avatarLarge,
          height: AppSizes.avatarLarge,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: const Center(
            child: AppIcon.asset(
              'ph-plant',
              size: AppSizes.iconXl,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nhịp ghi bữa đang lớn dần',
                style: AppTypography.sectionTitle,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Bắt đầu ghi bữa để xem nhịp của bạn.',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard();

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(title: 'Đều đặn ghi bữa', trailing: 'T2 – CN'),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: AppSizes.chart,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              7,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                  ),
                  child: FractionallySizedBox(
                    heightFactor: AppChartFactors.empty,
                    alignment: Alignment.bottomCenter,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.muted,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadii.sm),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('T2', style: AppTypography.micro),
            Text('T3', style: AppTypography.micro),
            Text('T4', style: AppTypography.micro),
            Text('T5', style: AppTypography.micro),
            Text('T6', style: AppTypography.micro),
            Text('T7', style: AppTypography.micro),
            Text('CN', style: AppTypography.micro),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Khi có dữ liệu, những ngày bạn ghi bữa sẽ hiện ở đây.',
          style: AppTypography.caption,
        ),
      ],
    ),
  );
}

class _WaterProgressCard extends StatelessWidget {
  const _WaterProgressCard();

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(title: 'Nước uống', trailing: 'Ghi nước'),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            8,
            (_) => const AppIcon.asset(
              'ph-drop',
              size: AppSizes.iconLg,
              color: AppColors.mutedForeground,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Uống đều đặn quan trọng hơn uống nhiều một lần.',
          style: AppTypography.caption,
        ),
      ],
    ),
  );
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({required this.goal});

  final Goal? goal;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Mục tiêu hiện tại',
                style: AppTypography.sectionTitle,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/profile-setup'),
              child: Text(goal == null ? 'Đặt mục tiêu' : 'Chỉnh'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(switch (goal?.type) {
                GoalType.lose => 'Giảm cân',
                GoalType.gain => 'Tăng cân',
                GoalType.maintain => 'Giữ cân',
                GoalType.logOnly => 'Chỉ ghi bữa',
                null => 'Chưa đặt mục tiêu',
              }, style: AppTypography.cardTitle),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.muted,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Text(
                goal == null ? 'Chưa theo dõi' : 'Đang theo dõi',
                style: AppTypography.micro,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(switch (goal?.schedule) {
          GoalSchedule.none => 'Không có hạn chót',
          GoalSchedule.byWeeks => '${goal!.targetWeeks} tuần',
          GoalSchedule.byDate => MaterialLocalizations.of(
            context,
          ).formatCompactDate(goal!.targetDate!),
          null => 'Đặt mục tiêu để xem tiến trình phù hợp.',
        }, style: AppTypography.bodySmall),
      ],
    ),
  );
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Cân bằng các nhóm món', style: AppTypography.sectionTitle),
        const SizedBox(height: AppSpacing.md),
        for (final label in ['Rau củ', 'Đạm', 'Tinh bột', 'Trái cây']) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.foreground,
                ),
              ),
              const Text('Chưa có dữ liệu', style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            height: AppSpacing.xs,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        const Text(
          'Ghi vài bữa để xem sự cân bằng theo thời gian.',
          style: AppTypography.caption,
        ),
      ],
    ),
  );
}

class _WeightEmptyCard extends StatelessWidget {
  const _WeightEmptyCard();

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    child: Column(
      children: [
        Container(
          width: AppSpacing.xl,
          height: AppSpacing.xl,
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: const Center(
            child: AppIcon.asset(
              'ph-scales',
              size: AppSizes.iconLg,
              color: AppColors.mutedForeground,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Chưa có dữ liệu cân nặng',
          style: AppTypography.sectionTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Bạn có thể thêm khi muốn. Lành vẫn hiển thị tiến trình ghi bữa và nước uống.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton.secondary(
          onPressed: null,
          child: const Text('Thêm cân nặng'),
        ),
      ],
    ),
  );
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.color = AppColors.card});

  final Widget child;
  final Color color;

  // Flat liquid glass as on Today; the tinted variant keeps its colour.
  @override
  Widget build(BuildContext context) => AppGlassCard(
    padding: const EdgeInsets.all(AppSpacing.card),
    radius: AppRadii.glassInner,
    shadows: const [],
    fill: color == AppColors.card ? null : color,
    child: child,
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(child: Text(title, style: AppTypography.sectionTitle)),
      Text(trailing, style: AppTypography.caption),
    ],
  );
}
