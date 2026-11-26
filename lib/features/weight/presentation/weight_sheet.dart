import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/weight_entry.dart';
import '../weight_providers.dart';
import 'weight_ruler.dart';

/// Opens "Cập nhật cân nặng" for today. The number starts at the latest
/// weigh-in, or the profile weight when none was logged. Completes with true
/// after a save or delete.
Future<bool> showWeightSheet(BuildContext context) async {
  final changed = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.card,
    barrierColor: AppColors.modalBarrier,
    constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
    shape: const RoundedRectangleBorder(
      side: BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
    ),
    sheetAnimationStyle: AnimationStyle(
      duration: AppMotion.duration(context),
      reverseDuration: AppMotion.duration(context),
    ),
    builder: (_) => const WeightSheet(),
  );
  return changed ?? false;
}

class WeightSheet extends ConsumerStatefulWidget {
  const WeightSheet({super.key, this.now});

  /// Fixed clock for tests; defaults to the device time.
  final DateTime? now;

  @override
  ConsumerState<WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends ConsumerState<WeightSheet> {
  late final DateTime _today = weightDay(widget.now ?? DateTime.now());

  /// The number on the ruler; null until history and profile are read, or
  /// when neither holds a weight (the ruler then starts mid-range).
  double? _kg;
  bool _seeded = false;
  bool _busy = false;
  bool _failed = false;

  NumberFormat get _format => NumberFormat.decimalPatternDigits(
    locale: AppLocalizations.of(context).localeName,
    decimalDigits: 1,
  );

  WeightEntry? _entryFor(List<WeightEntry> entries, DateTime day) {
    for (final entry in entries) {
      if (entry.day == day) return entry;
    }
    return null;
  }

  /// The weight entered at profile setup, the start when nothing is logged.
  double? get _profileKg => ref.read(profileGoalProvider).value?.currentWeight;

  Future<void> _run(Future<void> Function(WeightEditor editor) action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await action(ref.read(weightEditorProvider));
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final history = ref.watch(weightHistoryProvider);
    final entries = history.value ?? const <WeightEntry>[];
    if (!_seeded && !history.isLoading) {
      _seeded = true;
      _kg =
          _entryFor(entries, _today)?.kg ??
          latestWeightOnOrBefore(entries, _today)?.kg ??
          switch (_profileKg) {
            final kg? => normalizeWeightKg(kg),
            null => null,
          };
    }
    final kg = _kg;
    return SafeArea(
      top: false,
      child: Padding(
        key: const Key('weight-sheet'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.md,
          AppSpacing.pageHorizontal,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      strings.weightUpdateTitle,
                      style: AppTypography.title,
                    ),
                  ),
                ),
                AppNavigationButton.close(
                  key: const Key('weight-sheet-close'),
                  tooltip: strings.close,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ExcludeSemantics(
              child: Text.rich(
                key: const Key('weight-value'),
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text: kg == null ? '—' : _format.format(kg),
                      style: AppTypography.numericLarge,
                    ),
                    TextSpan(
                      text: ' ${strings.weightUnit}',
                      style: AppTypography.cardTitle.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_seeded)
              WeightRuler(
                // Nothing known yet: start the ruler mid-way, saving needs a
                // drag first.
                value: kg ?? weightRulerFallbackKg,
                enabled: !_busy,
                semanticLabel: strings.weightTitle,
                semanticValue: (value) =>
                    strings.weightKg(_format.format(value)),
                onChanged: (value) => setState(() {
                  _kg = value;
                  _failed = false;
                }),
              )
            else
              const SizedBox(height: AppSizes.weightRuler),
            if (_failed) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                strings.weightSaveError,
                key: const Key('weight-sheet-error'),
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.destructive,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              key: const Key('weight-save'),
              fullWidth: true,
              loading: _busy,
              onPressed: kg == null || _busy
                  ? null
                  : () => _run(
                      (editor) => editor.save(WeightEntry(day: _today, kg: kg)),
                    ),
              leadingIcon: 'ph-check-bold',
              label: strings.weightSave,
            ),
          ],
        ),
      ),
    );
  }
}
