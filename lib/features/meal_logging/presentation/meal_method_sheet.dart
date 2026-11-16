import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:lanh_ui/lanh_ui.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showMealMethodSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      sheetAnimationStyle: AnimationStyle(
        duration: LanhMotion.duration(context),
        reverseDuration: LanhMotion.duration(context),
      ),
      builder: (context) => const MealMethodSheet(),
    );

class MealMethodSheet extends StatelessWidget {
  const MealMethodSheet({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final methods = [
      (Icons.camera_alt_outlined, strings.camera),
      (Icons.photo_library_outlined, strings.gallery),
      (Icons.search_rounded, strings.search),
      (Icons.edit_note_rounded, strings.manual),
      (Icons.bookmark_border_rounded, strings.templates),
    ];
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
      ),
      child: SingleChildScrollView(
        key: const Key('meal-method-sheet'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        strings.chooseMealMethod,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('close-meal-sheet'),
                    tooltip: strings.close,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(strings.mealMethodsNotice),
              const SizedBox(height: 16),
              ...methods.map(
                (method) => ListTile(
                  enabled: false,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(method.$1),
                  title: Text(method.$2),
                  subtitle: Text(strings.comingSoon),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
