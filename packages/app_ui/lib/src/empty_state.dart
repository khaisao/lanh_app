part of '../app_ui.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: Icon(icon, size: 56, color: AppColors.primary)),
        const SizedBox(height: AppSpacing.medium),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.title,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          description,
          textAlign: TextAlign.center,
          style: AppTypography.body,
        ),
        if (action != null) ...[
          const SizedBox(height: AppSpacing.medium),
          action!,
        ],
      ],
    ),
  );
}
