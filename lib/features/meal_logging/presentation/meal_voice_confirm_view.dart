part of 'meal_voice_flow.dart';

/// VoiceMealConfirm: the user edits the transcript, or types a description
/// when voice was not used, before anything is sent.
class _MealVoiceConfirmView extends StatefulWidget {
  const _MealVoiceConfirmView({required this.controller});

  final MealVoiceController controller;

  @override
  State<_MealVoiceConfirmView> createState() => _MealVoiceConfirmViewState();
}

class _MealVoiceConfirmViewState extends State<_MealVoiceConfirmView> {
  late final _text = TextEditingController(text: widget.controller.draft);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _text.addListener(() => widget.controller.updateDraft(_text.text));
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    _focus.unfocus();
    unawaited(widget.controller.startEstimation());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final controller = widget.controller;
    final typed = controller.typed;
    final tooLong = controller.draft.trim().length > maxMealDescriptionLength;

    return _VoiceConfirmScaffold(
      header: _VoiceHeader(
        title: typed
            ? strings.mealVoiceTypedTitle
            : strings.mealVoiceConfirmTitle,
        leading: AppNavigationButton.back(
          key: const Key('meal-voice-back'),
          tooltip: strings.mealVoiceBackToRecording,
          onPressed: controller.returnToInput,
        ),
      ),
      dock: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              key: const Key('meal-voice-send'),
              onPressed: controller.canSend ? _send : null,
              fullWidth: true,
              showShadow: false,
              leadingIcon: 'ph-paper-plane-tilt-bold',
              label: strings.mealVoiceSend,
            ),
            _DockTextButton(
              buttonKey: const Key('meal-voice-record-again'),
              label: strings.mealVoiceRecordAgain,
              onPressed: controller.recordAgain,
            ),
          ],
        ),
      ),
      child: SingleChildScrollView(
        key: const Key('meal-voice-confirm'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.xl,
          AppSpacing.gutter,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: AppSizes.voiceConfirmHeroMascot,
                  height: AppSizes.voiceConfirmHeroMascot,
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: const AppMascot(size: AppSizes.voiceConfirmHeroMascot),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    typed
                        ? strings.mealVoiceHeading
                        : strings.mealVoiceConfirmHeading,
                    style: AppTypography.screenTitle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const AppIcon.asset(
                        'ph-quotes-fill',
                        size: AppSizes.iconInfo,
                        color: AppColors.chartGold,
                      ),
                      const SizedBox(width: AppSpacing.stepGap),
                      Flexible(
                        child: Text(
                          typed
                              ? strings.mealVoiceTypedLabel
                              : strings.mealVoiceTranscriptLabel,
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  strings.mealVoiceWordCount(controller.wordCount),
                  key: const Key('meal-voice-word-count'),
                  style: AppTypography.label,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              key: const Key('meal-voice-text'),
              controller: _text,
              focusNode: _focus,
              autofocus: typed,
              minLines: 4,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: AppTypography.sectionTitle.copyWith(height: 1.375),
              decoration: InputDecoration(
                hintText: typed ? strings.mealVoiceExample : null,
                hintStyle: AppTypography.bodySmall,
                errorText: tooLong
                    ? strings.mealVoiceTooLong(maxMealDescriptionLength)
                    : null,
                filled: true,
                fillColor: AppColors.input,
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                border: _border(AppColors.border),
                enabledBorder: _border(AppColors.border),
                focusedBorder: _border(
                  AppColors.primary,
                  width: AppBorders.selected,
                ),
                errorBorder: _border(AppColors.destructive),
                focusedErrorBorder: _border(
                  AppColors.destructive,
                  width: AppBorders.selected,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppIcon.asset(
                  'ph-shield-check',
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.denseGap),
                Expanded(
                  child: Text(
                    strings.mealVoicePrivacy,
                    style: AppTypography.caption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static InputBorder _border(
    Color color, {
    double width = AppBorders.hairline,
  }) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadii.lg),
    borderSide: BorderSide(color: color, width: width),
  );
}

/// Voice Meal Confirm v9: secondary-to-cream page, editable transcript and a
/// separate floating dock that stays above the system keyboard.
class _VoiceConfirmScaffold extends StatelessWidget {
  const _VoiceConfirmScaffold({
    required this.header,
    required this.dock,
    required this.child,
  });

  final Widget header;
  final Widget dock;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: AppSizes.voiceConfirmGradient,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.secondary, AppColors.background],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.denseVertical,
                      AppSpacing.xl,
                      AppSpacing.denseVertical,
                      0,
                    ),
                    child: header,
                  ),
                  Expanded(child: child),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AppGlassCard(
                      padding: EdgeInsets.zero,
                      radius: AppRadii.glassCard,
                      fill: AppColors.card.withValues(alpha: 0.7),
                      strokeWidth: AppBorders.selected,
                      child: dock,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
