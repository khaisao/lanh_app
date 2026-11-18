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
    final tooLong =
        controller.draft.trim().length >
        MealVoiceController.maxDescriptionLength;

    return _VoiceScaffold(
      header: _VoiceHeader(
        title: typed
            ? strings.mealVoiceTypedTitle
            : strings.mealVoiceConfirmTitle,
        leading: AppGlassIconButton(
          key: const Key('meal-voice-back'),
          icon: 'ph-caret-left-bold',
          tooltip: strings.mealVoiceBackToRecording,
          onPressed: controller.returnToInput,
        ),
      ),
      dock: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.stepGap,
          children: [
            DecoratedBox(
              decoration: ShapeDecoration(
                shape: const StadiumBorder(),
                shadows: controller.canSend ? AppShadows.primaryGlow : null,
              ),
              child: AppButton(
                key: const Key('meal-voice-send'),
                onPressed: controller.canSend ? _send : null,
                animatePress: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: AppSpacing.xs,
                  children: [
                    AppIcon.asset(
                      'ph-paper-plane-tilt-bold',
                      size: AppSizes.iconSm,
                      color: controller.canSend
                          ? AppColors.primaryForeground
                          : AppColors.secondaryForeground,
                    ),
                    Flexible(child: Text(strings.mealVoiceSend)),
                  ],
                ),
              ),
            ),
            if (controller.access == MealVoiceAccess.granted)
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
          AppSizes.photoPreviewPageHorizontal,
          AppSpacing.lg,
          AppSizes.photoPreviewPageHorizontal,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: AppSpacing.md,
              children: [
                const AppMascot(size: AppSizes.voiceConfirmMascot),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xxs,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          typed
                              ? strings.mealVoiceHeading
                              : strings.mealVoiceConfirmHeading,
                          style: AppTypography.title,
                        ),
                      ),
                      Text(
                        typed
                            ? strings.mealVoiceTypedBody
                            : strings.mealVoiceConfirmBody,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppGlassSurface(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    spacing: AppSpacing.sm,
                    children: [
                      const AppIcon.asset(
                        'ph-quotes-fill',
                        size: AppSizes.iconInfo,
                        color: AppColors.chartGold,
                      ),
                      Expanded(
                        child: Text(
                          typed
                              ? strings.mealVoiceTypedLabel
                              : strings.mealVoiceTranscriptLabel,
                          style: AppTypography.label,
                        ),
                      ),
                      Text(
                        strings.mealVoiceWordCount(controller.wordCount),
                        key: const Key('meal-voice-word-count'),
                        style: AppTypography.micro.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    key: const Key('meal-voice-text'),
                    controller: _text,
                    focusNode: _focus,
                    autofocus: typed,
                    minLines: 3,
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTypography.sectionTitle.copyWith(height: 1.375),
                    decoration: InputDecoration(
                      hintText: typed ? strings.mealVoiceExample : null,
                      hintStyle: AppTypography.bodySmall,
                      errorText: tooLong
                          ? strings.mealVoiceTooLong(
                              MealVoiceController.maxDescriptionLength,
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.input.withValues(alpha: 0.8),
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
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.card),
            // Export: `bg-muted/60 border-white/50 rounded-full`.
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.denseGap,
              ),
              decoration: ShapeDecoration(
                color: AppColors.muted.withValues(alpha: 0.6),
                shape: const StadiumBorder(
                  side: BorderSide(color: AppColors.glassRim),
                ),
              ),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  const AppIcon.asset(
                    'ph-shield-check',
                    size: AppSizes.iconSm,
                    color: AppColors.primary,
                  ),
                  Expanded(
                    child: Text(
                      strings.mealVoicePrivacy,
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
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
    borderSide: BorderSide(color: color.withValues(alpha: 0.6), width: width),
  );
}
