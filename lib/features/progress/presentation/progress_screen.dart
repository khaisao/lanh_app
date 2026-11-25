import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../progress_providers.dart';
import 'review_kcal_chart.dart';
import 'review_parts.dart';

/// Nhìn lại (Sleek "Nhìn lại 7 ngày" / "Ít dữ liệu"): the seven days before
/// today. A thin week shows how many days are missing and the chart only.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final review = ref.watch(weeklyReviewProvider);
    final value = review.value;
    final range = DateFormat('d/M', strings.localeName);
    return Scaffold(
      key: const Key('progress-screen'),
      body: AppPageList(
        children: [
          Semantics(
            header: true,
            child: Text(strings.progress, style: AppTypography.screenTitle),
          ),
          if (value != null)
            Text(
              strings.reviewRange(
                range.format(value.days.first),
                range.format(value.days.last),
              ),
              style: AppTypography.bodySmall,
            ),
          const SizedBox(height: AppSpacing.lg),
          if (review.hasError)
            ReviewErrorCard(onRetry: () => retryWeeklyReview(ref))
          else if (value == null)
            const Center(child: CircularProgressIndicator())
          else if (value.thin) ...[
            ReviewThinCard(review: value),
            const SizedBox(height: AppSpacing.md),
            ReviewKcalChart(review: value),
          ] else ...[
            ReviewVerdictCard(review: value),
            const SizedBox(height: AppSpacing.md),
            ReviewStatGrid(review: value),
            const SizedBox(height: AppSpacing.md),
            ReviewKcalChart(review: value),
            const SizedBox(height: AppSpacing.xl),
            ReviewFindings(review: value),
          ],
        ],
      ),
    );
  }
}
