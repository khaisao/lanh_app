import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showMealMethodSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.card,
      barrierColor: AppColors.modalBarrier,
      constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      sheetAnimationStyle: AnimationStyle(
        duration: AppMotion.duration(context),
        reverseDuration: AppMotion.duration(context),
      ),
      builder: (context) => const MealMethodSheet(),
    );

class MealMethodSheet extends StatelessWidget {
  const MealMethodSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    const methods = [
      ('ph-camera', 'Chụp ảnh', 'Lành ước lượng món trong ảnh'),
      ('ph-magnifying-glass', 'Tìm món ăn', 'Ví dụ: phở bò, cơm tấm'),
      ('ph-chat-text', 'Mô tả bữa ăn', 'Ví dụ: nửa tô phở bò'),
      ('ph-bookmark-simple', 'Bữa đã lưu', 'Những bữa bạn hay ăn'),
    ];
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.sizeOf(context).height * AppFractions.sheetMaxHeight,
      ),
      child: SingleChildScrollView(
        key: const Key('meal-method-sheet'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.sm,
          AppSpacing.pageHorizontal,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: AppSizes.avatar,
                height: AppSpacing.fieldGap,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          strings.chooseMealMethod,
                          style: AppTypography.pageHeading,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text('Chọn cách bắt đầu', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                TextButton.icon(
                  key: const Key('close-meal-sheet'),
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.muted,
                    foregroundColor: AppColors.foreground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    minimumSize: const Size(0, AppSizes.backAction),
                  ),
                  icon: const AppIcon.asset('ph-x-bold', size: AppSizes.iconXs),
                  label: Text(strings.close, style: AppTypography.button),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final method in methods) ...[
              AppOptionCard(
                caretSize: AppSizes.iconMd,
                icon: method.$1,
                title: method.$2,
                description: method.$3,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            OutlinedButton.icon(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSizes.compactAction),
                foregroundColor: AppColors.foreground,
                side: const BorderSide(color: AppColors.border),
                shape: const StadiumBorder(),
              ),
              icon: const AppIcon.asset(
                'ph-pencil-simple-line',
                size: AppSizes.iconSm,
              ),
              label: const Text(
                'Nhập tay tên món và calo',
                style: AppTypography.button,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              strings.mealMethodsNotice,
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}
