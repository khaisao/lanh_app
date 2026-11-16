import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/app/app_router.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:lanh_ui/lanh_ui.dart';
import 'package:material_ui/material_ui.dart';

class LanhApp extends ConsumerWidget {
  const LanhApp({super.key, this.locale = const Locale('vi')});
  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    theme: LanhTheme.light(),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    routerConfig: ref.watch(appRouterProvider),
  );
}
