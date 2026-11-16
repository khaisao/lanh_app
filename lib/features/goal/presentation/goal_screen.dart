import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_ui/app_ui.dart';

import '../domain/goal.dart';
import 'goal_controller.dart';
import '../../onboarding/presentation/onboarding_controller.dart';

class GoalScreen extends ConsumerStatefulWidget {
  const GoalScreen({super.key});
  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  GoalType? _type;
  GoalSchedule _schedule = GoalSchedule.none;
  int _step = 0;
  late final _current = TextEditingController();
  late final _target = TextEditingController();
  late final _reference = TextEditingController();
  late final _weeks = TextEditingController();
  DateTime? _date;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _target.dispose();
    _reference.dispose();
    _weeks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(goalControllerProvider).value;
    if (_type == null && saved != null) {
      _load(saved);
    }
    return Scaffold(
      key: const Key('goal-screen'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
            child: ListView(
              key: ValueKey(_step),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
                AppSpacing.pageHorizontal,
                AppSpacing.contentBottom,
              ),
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: _back,
                    icon: const AppIcon.asset(
                      'ph-arrow-left-bold',
                      size: AppSizes.iconMd,
                      color: AppColors.primary,
                    ),
                    label: const Text('Quay lại'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsetsDirectional.only(
                        end: AppSpacing.sm,
                      ),
                      textStyle: AppTypography.button,
                      minimumSize: const Size(0, AppSizes.backAction),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                SizedBox(height: _step == 0 ? AppSpacing.lg : AppSpacing.card),
                _step == 0
                    ? _selection(editing: saved != null)
                    : _step == 1
                    ? _form()
                    : _review(saved),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: SizedBox(
            width: AppSizes.contentMax,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                ),
                child: _footer(saved != null),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _busy => ref.watch(goalControllerProvider).isLoading;

  Widget _footer(bool editing) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_step > 0) ...[
        AppButton(
          key: const Key('goal-primary-action'),
          onPressed: _busy ? null : _next,
          child: Text(
            _step == 1
                ? 'Xem lại mục tiêu'
                : _type == GoalType.logOnly && !editing
                ? 'Bắt đầu ghi bữa'
                : editing
                ? 'Lưu mục tiêu mới'
                : 'Lưu mục tiêu đầu tiên',
            textAlign: TextAlign.center,
          ),
        ),
        if (_step == 2) ...[
          const SizedBox(height: AppSpacing.xs),
          AppButton.secondary(
            onPressed: _busy ? null : _back,
            child: const Text('Quay lại chỉnh sửa'),
          ),
        ],
      ],
      if (_step != 1 || editing)
        TextButton(
          onPressed: _busy
              ? null
              : _step == 0 && !editing
              ? _skip
              : _cancelEdit,
          style: TextButton.styleFrom(
            minimumSize: const Size(0, AppSizes.compactAction),
            foregroundColor: AppColors.mutedForeground,
            textStyle: AppTypography.button,
          ),
          child: Text(
            editing
                ? 'Hủy, giữ mục tiêu đang lưu'
                : _step == 0
                ? 'Để sau, ghi bữa trước'
                : 'Hủy, chưa đặt mục tiêu',
            textAlign: TextAlign.center,
          ),
        ),
    ],
  );

  void _back() {
    if (_step == 0) {
      context.pop();
    } else {
      setState(() {
        _step--;
        _error = null;
      });
    }
  }

  Widget _selection({required bool editing}) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        child: Text(
          editing ? 'Chỉnh mục tiêu' : 'Bạn muốn hướng đến điều gì?',
          style: AppTypography.screenTitle,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'Chọn một hướng để bắt đầu. Bạn có thể đổi hoặc bỏ mục tiêu sau trong Menu. Chưa có mục tiêu nào được đặt cho đến khi bạn xác nhận.',
        style: AppTypography.bodySmall,
      ),
      const SizedBox(height: AppSpacing.lg),
      for (final option in [
        (
          GoalType.lose,
          'Giảm cân',
          editing
              ? 'Cân nặng, mục tiêu và thời hạn tùy chọn'
              : 'Từng bước nhẹ nhàng, có thể đặt hạn',
        ),
        (
          GoalType.gain,
          'Tăng cân',
          editing
              ? 'Cân nặng, mục tiêu và thời hạn tùy chọn'
              : 'Đủ năng lượng, tăng đều và chậm',
        ),
        (
          GoalType.maintain,
          'Giữ cân',
          editing
              ? 'Đang lưu · không có hạn chót'
              : 'Giữ thói quen ổn định, không có hạn chót',
        ),
        (
          GoalType.logOnly,
          'Chỉ ghi bữa',
          'Không đặt cân nặng hay calo mục tiêu',
        ),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppOptionCard(
            icon: switch (option.$1) {
              GoalType.lose => 'ph-leaf',
              GoalType.gain => 'ph-plant',
              GoalType.maintain => 'ph-scales',
              GoalType.logOnly => 'ph-notebook',
            },
            title: option.$2,
            description: option.$3,
            selected: _type == option.$1,
            onPressed: () => setState(() {
              _type = option.$1;
              _step = 1;
            }),
          ),
        ),
    ],
  );

  Widget _form() {
    final type = _type!;
    if (type == GoalType.logOnly) return _logOnlyContent();
    if (type == GoalType.maintain) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Giữ cân', style: AppTypography.screenTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bạn có thể bỏ trống cân nặng tham khảo.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          _numberField('Cân nặng tham khảo (không bắt buộc)', _reference),
          const SizedBox(height: AppSpacing.md),
          _explanation(
            'Mục tiêu này gồm',
            'Ghi bữa ăn đều đặn và theo dõi nước uống. Không có hạn chót, không có tốc độ.',
          ),
        ],
      );
    }
    final isLose = type == GoalType.lose;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isLose ? 'Giảm cân' : 'Tăng cân',
          style: AppTypography.screenTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isLose
              ? 'Đặt một hướng nhẹ nhàng để theo dõi tiến trình. Bạn có thể đổi mục tiêu sau trong Menu.'
              : 'Đặt một hướng bền vững để theo dõi tiến trình. Bạn có thể đổi mục tiêu sau trong Menu.',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _numberField('Cân nặng hiện tại', _current),
                const SizedBox(height: AppSpacing.md),
                _numberField('Cân nặng mục tiêu', _target),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isLose
                        ? 'Cân mục tiêu phải thấp hơn cân hiện tại.'
                        : 'Cân mục tiêu phải cao hơn cân hiện tại.',
                    style: AppTypography.caption,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Thời hạn (không bắt buộc)', style: AppTypography.button),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<GoalSchedule>(
                  segments: const [
                    ButtonSegment(
                      value: GoalSchedule.none,
                      label: Text('Không hạn'),
                    ),
                    ButtonSegment(
                      value: GoalSchedule.byWeeks,
                      label: Text('Theo tuần'),
                    ),
                    ButtonSegment(
                      value: GoalSchedule.byDate,
                      label: Text('Chọn ngày'),
                    ),
                  ],
                  selected: {_schedule},
                  onSelectionChanged: (value) => setState(() {
                    _schedule = value.first;
                    if (_schedule != GoalSchedule.byDate) _date = null;
                    if (_schedule != GoalSchedule.byWeeks) _weeks.clear();
                  }),
                  showSelectedIcon: false,
                ),
                if (_schedule == GoalSchedule.byWeeks)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: _weekStepper(),
                  ),
                if (_schedule == GoalSchedule.byDate) _dateField(),
              ],
            ),
          ),
        ),

        if (_schedule == GoalSchedule.none)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: _explanation(
              'Không đặt hạn',
              'Bạn có thể theo dõi tiến trình theo nhịp phù hợp mà không cần ngày đích.',
            ),
          ),
        if (_schedule != GoalSchedule.none) _estimateCard(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: _errorText(_error!),
          ),
      ],
    );
  }

  Widget _review(Goal? saved) {
    final type = _type!;
    final name = _goalName(type);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Xem lại mục tiêu', style: AppTypography.screenTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(
          saved != null
              ? 'Mục tiêu đang lưu chỉ đổi khi bạn bấm “Lưu mục tiêu mới”.'
              : type == GoalType.logOnly
              ? 'Bạn chưa đặt mục tiêu nào. Bắt đầu ghi bữa, hoặc quay lại chỉnh sửa.'
              : 'Bạn chưa đặt mục tiêu nào. Lưu để bắt đầu, hoặc quay lại chỉnh sửa.',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.muted,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                saved == null ? 'Chưa có mục tiêu' : 'Đang lưu',
                style: AppTypography.label,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                saved == null
                    ? 'Đây sẽ là mục tiêu đầu tiên của bạn'
                    : _goalName(saved.type),
                style: AppTypography.cardTitle,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            side: const BorderSide(
              color: AppColors.primary,
              width: AppBorders.selected,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bản nháp, chưa lưu',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(name, style: AppTypography.cardTitle),
                if (type == GoalType.logOnly)
                  const Text(
                    'Không cân nặng, không thời hạn, không calo mục tiêu. Bạn có thể đổi sau.',
                    style: AppTypography.optionDescription,
                  ),
                if (type != GoalType.logOnly) ...[
                  const SizedBox(height: AppSpacing.sm),
                  if (_current.text.isNotEmpty)
                    _summary('Hiện tại', '${_current.text} kg'),
                  if (_target.text.isNotEmpty)
                    _summary('Mục tiêu', '${_target.text} kg'),
                  if (_reference.text.isNotEmpty)
                    _summary('Tham khảo', '${_reference.text} kg'),
                  _summary(
                    'Thời gian',
                    _schedule == GoalSchedule.byDate
                        ? _formatDate(_date!)
                        : _schedule == GoalSchedule.byWeeks
                        ? '${_weeks.text} tuần'
                        : 'Không có hạn chót',
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: _errorText(_error!),
          ),
      ],
    );
  }

  String _goalName(GoalType type) => switch (type) {
    GoalType.lose => 'Giảm cân',
    GoalType.gain => 'Tăng cân',
    GoalType.maintain => 'Giữ cân',
    GoalType.logOnly => 'Chỉ ghi bữa',
  };

  Widget _explanation(String title, String body) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.muted,
      borderRadius: BorderRadius.circular(AppRadii.md),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(body),
      ],
    ),
  );

  Widget _logOnlyContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Chỉ ghi bữa', style: AppTypography.screenTitle),
      const SizedBox(height: AppSpacing.xs),
      Text(
        'Lành giúp bạn ghi và hiểu bữa ăn. Không cần cân nặng, không có mục tiêu calo.',
        style: AppTypography.bodySmall,
      ),
      const SizedBox(height: AppSpacing.lg),
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              _checkRow('Không hỏi cân nặng hay chiều cao'),
              _checkRow('Không đặt hạn chót hay tốc độ'),
              _checkRow('Đổi sang mục tiêu khác bất cứ lúc nào'),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _checkRow(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      children: [
        const AppIcon.asset(
          'ph-check-circle-fill',
          size: AppSizes.iconMd,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text)),
      ],
    ),
  );

  Widget _errorText(String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppIcon.asset(
        'ph-warning-circle-fill',
        size: AppSizes.iconXs,
        color: Theme.of(context).colorScheme.error,
      ),
      const SizedBox(width: AppSpacing.xs),
      Expanded(child: Text(text, style: AppTypography.error)),
    ],
  );

  Widget _numberField(
    String label,
    TextEditingController controller, {
    bool integer = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ExcludeSemantics(child: Text(label, style: AppTypography.fieldLabel)),
      const SizedBox(height: AppSpacing.fieldGap),
      Semantics(
        label: label,
        child: TextField(
          controller: controller,
          style: AppTypography.inputValue,
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.numberWithOptions(decimal: !integer),
          decoration: InputDecoration(
            suffixText: integer ? null : 'kg',
            suffixStyle: AppTypography.optionDescription,
          ),
        ),
      ),
    ],
  );

  Widget _dateField() => OutlinedButton.icon(
    onPressed: _pickDate,
    icon: const AppIcon.asset('ph-calendar-blank', size: AppSizes.iconLg),
    label: Text(_date == null ? 'Chọn ngày đích' : _formatDate(_date!)),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, AppSizes.action),
      alignment: Alignment.centerLeft,
    ),
  );

  Widget _weekStepper() => Container(
    height: AppSizes.action,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    decoration: BoxDecoration(
      color: AppColors.input,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppRadii.md),
    ),
    child: Row(
      children: [
        const Expanded(child: Text('Số tuần', style: AppTypography.bodySmall)),
        IconButton(
          tooltip: 'Giảm 1 tuần',
          onPressed: () {
            final value = int.tryParse(_weeks.text) ?? 1;
            setState(() => _weeks.text = '${value > 1 ? value - 1 : 1}');
          },
          icon: const AppIcon.asset('ph-minus-bold', size: AppSizes.iconXs),
        ),
        SizedBox(
          width: AppSizes.weekInput,
          child: TextField(
            controller: _weeks,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        IconButton(
          tooltip: 'Tăng 1 tuần',
          onPressed: () {
            final value = int.tryParse(_weeks.text) ?? 0;
            setState(() => _weeks.text = '${value + 1}');
          },
          icon: const AppIcon.asset('ph-plus-bold', size: AppSizes.iconXs),
        ),
      ],
    ),
  );

  Widget _estimateCard() {
    final current = double.tryParse(_current.text.replaceAll(',', '.'));
    final target = double.tryParse(_target.text.replaceAll(',', '.'));
    final weeks = int.tryParse(_weeks.text);
    final difference = current == null || target == null
        ? null
        : (target - current).abs();
    final rate = difference == null || weeks == null || weeks == 0
        ? null
        : difference / weeks;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ước tính để lên kế hoạch',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: AppColors.secondaryForeground),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            rate == null
                ? 'Nhập đủ số đo để xem ước tính.'
                : '~${rate.toStringAsFixed(2)} kg mỗi tuần',
            style: AppTypography.title.copyWith(
              color: AppColors.secondaryForeground,
            ),
          ),
          if (difference != null &&
              weeks != null &&
              current != null &&
              target != null)
            Text(
              '(${target.toStringAsFixed(0)} − ${current.toStringAsFixed(0)}) kg ÷ $weeks tuần',
              style: AppTypography.caption.copyWith(
                color: AppColors.secondaryForeground,
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Chỉ là con số để bạn lên kế hoạch, không phải chỉ dẫn y tế.',
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label)),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.cardTitle,
          ),
        ),
      ],
    ),
  );

  void _load(Goal goal) {
    _type = goal.type;
    _current.text = goal.currentWeight?.toString() ?? '';
    _target.text = goal.targetWeight?.toString() ?? '';
    _reference.text = goal.referenceWeight?.toString() ?? '';
    _weeks.text = goal.targetWeeks?.toString() ?? '';
    _date = goal.targetDate;
    _schedule = goal.schedule;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _date ?? DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _next() {
    if (_step == 0) {
      if (_type != null) {
        setState(() => _step = 1);
      }
      return;
    }
    if (_step == 1) {
      if (_validate()) {
        setState(() => _step = 2);
      }
      return;
    }
    _save();
  }

  Future<void> _skip() async {
    await ref.read(onboardingControllerProvider.notifier).complete();
    if (mounted) context.go('/today');
  }

  void _cancelEdit() => context.pop();

  bool _validate() {
    _error = null;
    if (_type == GoalType.logOnly || _type == GoalType.maintain) return true;
    final current = double.tryParse(_current.text.replaceAll(',', '.'));
    final target = double.tryParse(_target.text.replaceAll(',', '.'));
    if (current == null || target == null || current <= 0 || target <= 0) {
      setState(() => _error = 'Vui lòng nhập cân nặng hợp lệ.');
      return false;
    }
    if ((_type == GoalType.lose && target >= current) ||
        (_type == GoalType.gain && target <= current)) {
      setState(() => _error = 'Cân nặng mục tiêu cần đúng hướng bạn đã chọn.');
      return false;
    }
    if (_schedule == GoalSchedule.byWeeks &&
        (int.tryParse(_weeks.text) ?? 0) < 1) {
      setState(() => _error = 'Số tuần phải lớn hơn 0.');
      return false;
    }
    if (_schedule == GoalSchedule.byDate && _date == null) {
      setState(() => _error = 'Vui lòng chọn ngày đích.');
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final old = ref.read(goalControllerProvider).value;
    final type = _type!;
    final hasTarget = type == GoalType.lose || type == GoalType.gain;
    final goal = Goal(
      type: type,
      currentWeight: hasTarget
          ? double.tryParse(_current.text.replaceAll(',', '.'))
          : null,
      targetWeight: hasTarget
          ? double.tryParse(_target.text.replaceAll(',', '.'))
          : null,
      referenceWeight: type == GoalType.maintain
          ? double.tryParse(_reference.text.replaceAll(',', '.'))
          : null,
      targetDate: hasTarget && _schedule == GoalSchedule.byDate ? _date : null,
      targetWeeks: hasTarget && _schedule == GoalSchedule.byWeeks
          ? int.tryParse(_weeks.text)
          : null,
      createdAt: old?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      await ref.read(goalControllerProvider.notifier).save(goal);
      await ref.read(onboardingControllerProvider.notifier).complete();
      if (mounted) context.go('/today');
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Chưa lưu được mục tiêu. Vui lòng thử lại.');
      }
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
