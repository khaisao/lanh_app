import 'dart:async';

import 'package:lanh_app/features/meal_logging/meal_logging.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:lanh_ui/lanh_ui.dart';
import 'package:material_ui/material_ui.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('today-screen'),
      appBar: AppBar(title: Text(strings.todayHeading)),
      body: ListView(
        padding: const EdgeInsets.all(LanhSpacing.large),
        children: [
          LanhEmptyState(
            icon: Icons.restaurant_rounded,
            title: strings.todayEmptyTitle,
            description: strings.todayEmptyBody,
            action: FilledButton.icon(
              onPressed: () => unawaited(showMealMethodSheet(context)),
              icon: const Icon(Icons.add_rounded),
              label: Text(strings.logMeal),
            ),
          ),
          const SizedBox(height: LanhSpacing.large),
          Text(
            strings.baseNotice,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
