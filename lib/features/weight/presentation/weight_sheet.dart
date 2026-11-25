import 'package:app_ui/app_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lanh_app/features/profile_setup/profile_setup.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/weight_entry.dart';
import '../weight_providers.dart';
import 'weight_day_label.dart';

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
  late DateTime _day = _today;
  final _input = TextEditingController();
  bool _seeded = false;
  bool _busy = false;
  bool _failed = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  NumberFormat get _format => NumberFormat.decimalPatternDigits(
    locale: AppLocalizations.of(context).localeName,
    decimalDigits: 1,
  );

  /// Accepts "52,8" and "52.8".
  double? get _value => normalizeWeightKg(
    double.tryParse(_input.text.trim().replaceAll(',', '.')) ?? double.nan,
  );

  WeightEntry? _entryFor(List<WeightEntry> entries, DateTime day) {
    for (final entry in entries) {
      if (entry.day == day) return entry;
    }
    return null;
  }

  void _show(double? kg) {
    _input.text = kg == null ? '' : _format.format(kg);
  }

  /// The weight entered at profile setup, the start when nothing is logged.
  double? get _profileKg => ref.read(profileGoalProvider).value?.currentWeight;

  void _step(int direction) {
    final base = _value ?? _profileKg;
    if (base == null) return;
    final next = normalizeWeightKg(base + direction * weightStepKg);
    if (next == null) return;
    HapticFeedback.selectionClick();
    setState(() => _show(next));
  }

  void _pickDay(DateTime day, List<WeightEntry> entries) {
    setState(() {
      _day = day;
      // Show what that day already holds, so saving is a visible edit.
      final existing = _entryFor(entries, day);
      if (existing != null) _show(existing.kg);
    });
  }

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
      final start =
          _entryFor(entries, _day)?.kg ??
          latestWeightOnOrBefore(entries, _day)?.kg ??
          switch (_profileKg) {
            final kg? => normalizeWeightKg(kg),
            null => null,
          };
      _show(start);
    }
    final existing = _entryFor(entries, _day);
    final value = _value;
    final invalid = _input.text.trim().isNotEmpty && value == null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        key: const Key('weight-sheet'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.md,
          AppSpacing.pageHorizontal,
          AppSpacing.xl,
        ),
        child: Column(
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
            // Label left, chip right; the chip drops below at large text.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                Text(strings.weightDate, style: AppTypography.label),
                _DayPicker(
                  day: _day,
                  today: _today,
                  onPick: (day) => _pickDay(day, entries),
                ),
              ],
            ),
            if (existing != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _Notice(
                key: const Key('weight-sheet-replace'),
                text: strings.weightReplaceWarning(_format.format(existing.kg)),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _StepButton(
                  key: const Key('weight-minus'),
                  icon: 'ph-minus-bold',
                  label: strings.weightDecrease,
                  onPressed: _busy ? null : () => _step(-1),
                ),
                Expanded(
                  child: TextField(
                    key: const Key('weight-input'),
                    controller: _input,
                    enabled: !_busy,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      LengthLimitingTextInputFormatter(5),
                    ],
                    onChanged: (_) => setState(() => _failed = false),
                    style: AppTypography.numericLarge,
                    decoration: InputDecoration(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      suffixText: strings.weightUnit,
                      hintText: '—',
                      semanticCounterText: '',
                    ),
                  ),
                ),
                _StepButton(
                  key: const Key('weight-plus'),
                  icon: 'ph-plus-bold',
                  label: strings.weightIncrease,
                  onPressed: _busy ? null : () => _step(1),
                ),
              ],
            ),
            if (invalid || _failed) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                invalid ? strings.weightRange : strings.weightSaveError,
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
              onPressed: value == null || _busy
                  ? null
                  : () => _run(
                      (editor) =>
                          editor.save(WeightEntry(day: _day, kg: value)),
                    ),
              label: strings.weightSave,
            ),
            if (existing != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                key: const Key('weight-delete'),
                onPressed: _busy
                    ? null
                    : () => _run((editor) => editor.delete(_day)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.destructive,
                  minimumSize: const Size.fromHeight(AppSizes.compactAction),
                ),
                icon: const AppIcon.asset(
                  'ph-x-bold',
                  size: AppSizes.iconSm,
                  color: AppColors.destructive,
                ),
                label: Text(strings.weightDelete),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.day,
    required this.today,
    required this.onPick,
  });

  final DateTime day;
  final DateTime today;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    String label(DateTime value) {
      final relative = weightDayLabel(strings, value, today);
      final date = DateFormat('d/M', strings.localeName).format(value);
      if (relative == date) return date;
      // "Hôm nay, 25/11": the relative word starts the label.
      return '${relative[0].toUpperCase()}${relative.substring(1)}, $date';
    }

    return PopupMenuButton<DateTime>(
      key: const Key('weight-day'),
      tooltip: strings.weightDate,
      initialValue: day,
      onSelected: onPick,
      itemBuilder: (_) => [
        for (var back = 0; back < weightEditableDays; back++)
          PopupMenuItem(
            value: DateTime(today.year, today.month, today.day - back),
            child: Text(
              label(DateTime(today.year, today.month, today.day - back)),
            ),
          ),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: AppSizes.compactAction),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xxs,
          children: [
            const AppIcon.asset(
              'ph-calendar-blank',
              size: AppSizes.iconXs,
              color: AppColors.primary,
            ),
            Flexible(
              child: Text(
                label(day),
                style: AppTypography.label.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.sm),
    decoration: BoxDecoration(
      color: AppColors.sunnyTint,
      borderRadius: BorderRadius.circular(AppRadii.md),
    ),
    child: Row(
      spacing: AppSpacing.xs,
      children: [
        const AppIcon.asset(
          'ph-info',
          size: AppSizes.iconXs,
          color: AppColors.sunny,
        ),
        Expanded(child: Text(text, style: AppTypography.bodySmall)),
      ],
    ),
  );
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final String icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      backgroundColor: AppColors.secondary,
      fixedSize: const Size.square(AppSizes.compactAction),
    ),
    icon: AppIcon.asset(icon, size: AppSizes.iconSm, color: AppColors.primary),
  );
}
