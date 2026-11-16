import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:lanh_ui/lanh_ui.dart';
import 'package:material_ui/material_ui.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('progress-screen'),
      appBar: AppBar(title: Text(strings.progress)),
      body: ListView(
        padding: const EdgeInsets.all(LanhSpacing.large),
        children: [
          LanhEmptyState(
            icon: Icons.insights_outlined,
            title: strings.progressEmptyTitle,
            description: strings.progressEmptyBody,
          ),
        ],
      ),
    );
  }
}
