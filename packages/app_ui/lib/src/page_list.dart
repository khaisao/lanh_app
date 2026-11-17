part of '../app_ui.dart';

/// A page that scrolls behind the floating bottom bar, including on short pages.
class AppPageList extends StatelessWidget {
  const AppPageList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.pageTop,
            AppSpacing.pageHorizontal,
            AppSpacing.contentBottom + MediaQuery.paddingOf(context).bottom,
          ),
          children: children,
        ),
      ),
    ),
  );
}
