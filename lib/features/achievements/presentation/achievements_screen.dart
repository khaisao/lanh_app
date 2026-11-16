import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:lanh_ui/lanh_ui.dart';
import 'package:material_ui/material_ui.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('achievements-screen'),
      appBar: AppBar(title: Text(strings.achievements)),
      body: ListView(
        padding: const EdgeInsets.all(LanhSpacing.large),
        children: [
          LanhEmptyState(
            icon: Icons.auto_awesome_outlined,
            title: strings.achievementsEmptyTitle,
            description: strings.achievementsEmptyBody,
          ),
        ],
      ),
    );
  }
}
