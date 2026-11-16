import 'package:go_router/go_router.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:lanh_ui/lanh_ui.dart';
import 'package:material_ui/material_ui.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('menu-screen'),
      appBar: AppBar(title: Text(strings.menu)),
      body: ListView(
        padding: const EdgeInsets.all(LanhSpacing.large),
        children: [
          Card(
            child: ListTile(
              title: Text(strings.about),
              leading: const Icon(Icons.info_outline_rounded),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/menu/about'),
            ),
          ),
          const SizedBox(height: LanhSpacing.large),
          Text(strings.privacyBase),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('about-screen'),
      appBar: AppBar(title: Text(strings.about)),
      body: ListView(
        padding: const EdgeInsets.all(LanhSpacing.large),
        children: [
          Text(strings.aboutBody, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: LanhSpacing.large),
          Text(strings.baseNotice),
        ],
      ),
    );
  }
}
