import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/app/app_router.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:app_ui/app_ui.dart';
import 'package:material_ui/material_ui.dart';

class Application extends ConsumerWidget {
  const Application({super.key, this.locale = const Locale('vi')});
  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      routerConfig: router,
    );
  }
}
