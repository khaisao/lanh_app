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
        color: AppColors.primaryForeground,
        leading: AppGlassIconButton(
          key: const Key('meal-voice-back'),
          icon: 'ph-caret-left-bold',
          tooltip: strings.mealVoiceBackToRecording,
          color: AppColors.primaryForeground,
          onPressed: controller.returnToInput,
        ),
      ),
      hero: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppMascot(size: AppSizes.voiceConfirmHeroMascot),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            header: true,
            child: Text(
              typed
                  ? strings.mealVoiceHeading
                  : strings.mealVoiceConfirmHeading,
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(
                color: AppColors.primaryForeground,
              ),
            ),
          ),
        ],
      ),
      child: SingleChildScrollView(
        key: const Key('meal-voice-confirm'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.md,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    typed
                        ? strings.mealVoiceTypedLabel
                        : strings.mealVoiceTranscriptLabel,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  strings.mealVoiceWordCount(controller.wordCount),
                  key: const Key('meal-voice-word-count'),
                  style: AppTypography.micro,
                ),
              ],
            ),
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
            Text(strings.mealVoiceConfirmHint, style: AppTypography.caption),
            Text(strings.mealVoicePrivacy, style: AppTypography.caption),
            AppButton(
              key: const Key('meal-voice-send'),
              onPressed: controller.canSend ? _send : null,
              fullWidth: true,
              leadingIcon: 'ph-paper-plane-tilt-bold',
              label: strings.mealVoiceSend,
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

class _VoiceConfirmScaffold extends StatelessWidget {
  const _VoiceConfirmScaffold({
    required this.header,
    required this.hero,
    required this.child,
  });

  final Widget header;
  final Widget hero;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.primary,
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
              0,
            ),
            child: header,
          ),
          Expanded(
            child: Stack(
              children: [
                Center(child: hero),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Material(
                      color: AppColors.card,
                      elevation: 8,
                      shadowColor: AppColors.foreground.withValues(alpha: 0.22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: child,
                        ),
                      ),
                    ),
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
