import 'package:app_ui/app_ui.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    const achievements = [
      (
        'Bữa đầu tiên',
        'Ghi lại một bữa ăn, bất kỳ bữa nào.',
        'ph-seal-check-fill',
        false,
      ),
      (
        'Ba ngày liền',
        'Ghi bữa trong 3 ngày liên tiếp.',
        'ph-calendar-check-fill',
        false,
      ),
      (
        'Tự chỉnh khẩu phần',
        'Chỉnh một món hoặc một bữa cho đúng phần bạn ăn.',
        'ph-sliders-horizontal-fill',
        false,
      ),
      (
        'Uống nước đều đặn',
        'Đạt ít nhất 4 ly trong 5 ngày.',
        'ph-drop-fill',
        false,
      ),
      (
        'Quay lại sau một ngày nghỉ',
        'Tiếp tục sau khi nghỉ một ngày. Nghỉ cũng là một phần của hành trình.',
        'ph-sun-horizon-fill',
        false,
      ),
      (
        'Một tuần bữa cân bằng',
        'Ghi đủ bốn nhóm món trong 7 ngày.',
        'ph-lock-simple',
        false,
      ),
    ];
    return Scaffold(
      key: const Key('achievements-screen'),
      body: AppPageList(
        children: [
          Text(strings.achievements, style: AppTypography.screenTitle),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Những thói quen nhỏ bạn đã xây dựng. Không điểm trừ, không bảng xếp hạng.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _AchievementSummary(),
          const SizedBox(height: AppSpacing.lg),
          for (final achievement in achievements) ...[
            _AchievementTile(
              title: achievement.$1,
              description: achievement.$2,
              icon: achievement.$3,
              opened: achievement.$4,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _AchievementSummary extends StatelessWidget {
  const _AchievementSummary();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.card),
    decoration: BoxDecoration(
      color: AppColors.secondary,
      borderRadius: BorderRadius.circular(AppRadii.md),
    ),
    child: Row(
      children: [
        const Image(
          image: AssetImage('assets/design/images/xQ84zhEVfCY.png'),
          width: AppSizes.summaryImage,
          height: AppSizes.summaryImage,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Đã mở', style: AppTypography.bodySmall),
              Text('0 / 6', style: AppTypography.numericLarge),
              Text('Mầm đang lớn cùng bạn.', style: AppTypography.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.opened,
  });

  final String title;
  final String description;
  final String icon;
  final bool opened;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: opened ? AppColors.card : null,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppRadii.md),
    ),
    child: Row(
      children: [
        Container(
          width: AppSizes.choiceIcon,
          height: AppSizes.choiceIcon,
          decoration: BoxDecoration(
            color: opened ? AppColors.secondary : AppColors.muted,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Center(
            child: AppIcon.asset(
              icon,
              size: AppSizes.iconLg,
              color: opened ? AppColors.primary : AppColors.mutedForeground,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.cardTitle.copyWith(
                  color: opened
                      ? AppColors.foreground
                      : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(description, style: AppTypography.caption),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: opened ? AppColors.primary : AppColors.muted,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            opened ? 'Đã mở' : 'Chưa mở',
            style: AppTypography.micro.copyWith(
              color: opened
                  ? AppColors.primaryForeground
                  : AppColors.mutedForeground,
            ),
          ),
        ),
      ],
    ),
  );
}
