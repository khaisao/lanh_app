part of 'meal_voice_flow.dart';

/// VoiceMealInput. Two states share one screen: the waveform state (Sleek
/// `cQLCsQQiBRB`) before any words — also used for asking access, a refusal
/// or a silent session — and the live-text state ("VoiceLiveB – ThinWave")
/// once words are heard. [_MorphBody] interpolates between them; a new
/// recording morphs back and the waveform spreads from the centre on entry.
/// Reduce Motion switches instantly.
class _MealVoiceInputView extends StatefulWidget {
  const _MealVoiceInputView({required this.controller, required this.onClose});

  final MealVoiceController controller;
  final VoidCallback onClose;

  @override
  State<_MealVoiceInputView> createState() => _MealVoiceInputViewState();
}

class _MealVoiceInputViewState extends State<_MealVoiceInputView>
    with TickerProviderStateMixin {
  /// 0 = waveform state, 1 = live-text state.
  late final _reveal = AnimationController(
    vsync: this,
    duration: AppMotion.voiceReveal,
  );

  /// Opening the screen: the waveform line spreads out from the centre.
  late final _enter = AnimationController(
    vsync: this,
    duration: AppMotion.voiceEnter,
  );
  bool _started = false;

  MealVoiceController get _controller => widget.controller;

  bool get _showText {
    final stage = _controller.stage;
    final recording =
        stage == MealVoiceStage.listening || stage == MealVoiceStage.finishing;
    return recording && _controller.transcript.trim().isNotEmpty;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (!_started) {
      _started = true;
      _reveal.value = _showText ? 1 : 0;
      if (still) {
        _enter.value = 1;
      } else {
        _enter.forward();
      }
    } else if (still) {
      _enter.value = 1;
      _reveal.value = _showText ? 1 : 0;
    }
  }

  @override
  void didUpdateWidget(_MealVoiceInputView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _showText ? 1.0 : 0.0;
    if (MediaQuery.disableAnimationsOf(context)) {
      _reveal.value = target;
    } else if (_reveal.value != target &&
        (!_reveal.isAnimating || _revealTarget != target)) {
      _revealTarget = target;
      // Linear here; each part applies its own easing in [_MorphBody].
      _reveal.animateTo(target);
    }
  }

  double? _revealTarget;

  @override
  void dispose() {
    _reveal.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final controller = _controller;
    final stage = controller.stage;
    final listening = stage == MealVoiceStage.listening;
    final finishing = stage == MealVoiceStage.finishing;
    final checking = stage == MealVoiceStage.checking;
    final recording = listening || finishing;
    // Refused or unavailable access is explained here, not on another screen.
    final noAccess =
        stage == MealVoiceStage.idle &&
        controller.access != null &&
        !controller.hasAccess;
    final unavailable = controller.access == MealVoiceAccess.unavailable;

    final status = checking
        ? strings.mealVoicePreparing
        : finishing
        ? strings.mealVoiceFinishing
        : listening
        ? strings.mealVoiceRecording
        : noAccess
        ? strings.mealVoiceNoAccessTitle
        : controller.listenFailure != null
        ? strings.mealVoiceNotHeardTitle
        : strings.mealVoiceReadyTitle;
    final notice = noAccess
        ? (unavailable
              ? strings.mealVoiceUnavailable
              : strings.mealVoiceNoAccess)
        : controller.listenFailure == null
        ? null
        : _failure(strings);

    return _VoiceScaffold(
      header: _VoiceHeader(
        title: strings.mealVoiceTitle,
        leading: AppNavigationButton.close(
          key: const Key('meal-voice-close'),
          tooltip: strings.close,
          onPressed: widget.onClose,
        ),
      ),
      dock: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xs,
          children: [
            _RecordButton(
              stage: stage,
              noAccess: noAccess,
              onRecord: unavailable ? null : controller.record,
              onStop: controller.stopListening,
            ),
            Text(
              checking
                  ? strings.mealVoicePreparing
                  : finishing
                  ? strings.mealVoiceFinishing
                  : listening
                  ? strings.mealVoiceStopCaption
                  : noAccess
                  ? strings.mealVoiceAllowCaption
                  : strings.mealVoiceStartCaption,
              textAlign: TextAlign.center,
              style: AppTypography.label,
            ),
            if (recording)
              _DockTextButton(
                buttonKey: const Key('meal-voice-cancel'),
                label: strings.mealVoiceCancel,
                onPressed: widget.onClose,
              )
            else
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.xs,
                children: [
                  if (noAccess && !unavailable)
                    _DockTextButton(
                      buttonKey: const Key('meal-voice-settings'),
                      label: strings.mealPhotoOpenSettings,
                      color: AppColors.primary,
                      onPressed: controller.openSettings,
                    ),
                  _DockTextButton(
                    buttonKey: const Key('meal-voice-type'),
                    label: strings.mealVoiceTypeInstead,
                    onPressed: checking ? null : controller.typeInstead,
                  ),
                ],
              ),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_reveal, _enter]),
        builder: (context, _) => _MorphBody(
          controller: controller,
          status: status,
          notice: notice,
          recording: recording,
          listening: listening,
          reveal: _reveal.value,
          spread: Curves.easeOutCubic.transform(_enter.value),
        ),
      ),
    );
  }

  String _failure(AppLocalizations strings) =>
      switch (_controller.listenFailure) {
        MealVoiceFailureKind.languageUnavailable =>
          strings.mealVoiceLanguageUnavailable,
        MealVoiceFailureKind.recognition => strings.mealVoiceRecognitionError,
        MealVoiceFailureKind.noSpeech || null => strings.mealVoiceNoSpeech,
      };
}

/// One layout shared by both states, interpolated by [reveal]
/// (0 = waveform state `cQLCsQQiBRB`, 1 = live-text state "VoiceLiveB –
/// ThinWave"):
///
/// * the status row stays at the top and gains the inline time;
/// * the 72 pt timer and the hint fold away;
/// * the same waveform (same noise floor and bars) thins from 128 to a
///   40 dp band, rising as the timer folds, so the feedback never resets;
/// * the words appear in the space below, centred vertically and
///   left-aligned, rising from a soft blur.
class _MorphBody extends StatelessWidget {
  const _MorphBody({
    required this.controller,
    required this.status,
    required this.notice,
    required this.recording,
    required this.listening,
    required this.reveal,
    required this.spread,
  });

  final MealVoiceController controller;
  final String status;
  final String? notice;
  final bool recording;
  final bool listening;
  final double reveal;
  final double spread;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    // [reveal] is linear; each part gets one easing curve so nothing is
    // double-eased. The timer fades early, while the movement (timer fold,
    // gap and waveform height, which carry the band upward) eases over the
    // whole morph; the words arrive once space has opened.
    final t = reveal;
    final fade = const Interval(0, 0.35, curve: Curves.easeOut).transform(t);
    // A sine ease spread over the whole morph keeps the band's rise even:
    // its peak speed is ~1.6x the average, versus 3x for a cubic ease.
    final move = Curves.easeInOutSine.transform(t);
    final show = const Interval(
      0.45,
      1,
      curve: Curves.easeOutCubic,
    ).transform(t);
    final elapsed = controller.elapsed;

    final top = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          header: true,
          label: t > 0.5
              ? '$status, ${strings.mealVoiceTimerLabel(elapsed.inSeconds)}'
              : null,
          excludeSemantics: t > 0.5,
          // Reserve the inline time's height so the row never shifts.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.textScalerOf(context).scale(
                AppTypography.voiceInlineTimer.fontSize! *
                    AppTypography.voiceInlineTimer.height!,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (listening) ...[
                  const _RecordingDot(blink: true),
                  SizedBox(width: _mix(AppSpacing.xs, AppSpacing.sm, move)),
                ],
                Flexible(
                  child: Text(
                    status,
                    key: const Key('meal-voice-status'),
                    textAlign: TextAlign.center,
                    style: AppTypography.button.copyWith(
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                // Inline time slides in as the big timer folds away.
                _Fold(
                  axis: Axis.horizontal,
                  factor: show,
                  child: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: Text(
                      _clock(elapsed),
                      key: const Key('meal-voice-pill-timer'),
                      style: AppTypography.voiceInlineTimer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _Fold(
          factor: 1 - move,
          opacity: 1 - fade,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                label: strings.mealVoiceTimerLabel(elapsed.inSeconds),
                excludeSemantics: true,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _clock(elapsed),
                    key: const Key('meal-voice-timer'),
                    style: AppTypography.voiceTimer.copyWith(
                      color: recording
                          ? AppColors.foreground
                          : AppColors.mutedForeground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.readableWidth,
                  ),
                  child: Text(
                    notice ?? strings.mealVoiceSpeakHint,
                    key: const Key('meal-voice-message'),
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: notice == null
                          ? AppColors.mutedForeground
                          : AppColors.destructive,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: _mix(AppSpacing.xxl, AppSpacing.md, move)),
        Opacity(
          key: const Key('meal-voice-wave-entrance'),
          opacity: spread,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(0.3 + 0.7 * spread, 1, 1),
            child: _RecordingWaveform(
              level: controller.level,
              listening: listening,
              height: _mix(
                AppSizes.voiceWaveform,
                AppSizes.voiceWaveformBand,
                move,
              ),
            ),
          ),
        ),
      ],
    );

    final words = show == 0
        ? const SizedBox.shrink()
        : ExcludeSemantics(
            excluding: show < 0.5,
            child: Opacity(
              opacity: show,
              child: Transform.translate(
                offset: Offset(0, AppSpacing.md * (1 - show)),
                child: _LiveWords(
                  controller: controller,
                  listening: listening,
                  blur: AppSizes.voiceRevealBlur * (1 - show),
                ),
              ),
            ),
          );

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.xl,
          AppSpacing.pageHorizontal,
          AppSpacing.lg,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.max(
              0,
              constraints.maxHeight - AppSpacing.xl - AppSpacing.lg,
            ),
          ),
          // Words take the remaining space and centre in it (`flex-1
          // justify-center`); on short screens the page scrolls instead.
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                top,
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppSpacing.lg * show),
                    child: Center(child: words),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Clips [child] to [factor] of its size along [axis] (1 = full), so parts
/// fold in or out while the group around them reflows. Folded content is
/// hidden from screen readers.
class _Fold extends StatelessWidget {
  const _Fold({
    required this.factor,
    required this.child,
    this.axis = Axis.vertical,
    this.opacity,
  });

  final double factor;
  final Widget child;
  final Axis axis;

  /// Defaults to [factor]; set it to fade content ahead of the fold.
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    final f = factor.clamp(0.0, 1.0);
    if (f == 0) return const SizedBox.shrink();
    return ExcludeSemantics(
      excluding: f < 0.5,
      child: ClipRect(
        child: Align(
          alignment: Alignment.center,
          heightFactor: axis == Axis.vertical ? f : null,
          widthFactor: axis == Axis.horizontal ? f : null,
          child: Opacity(opacity: (opacity ?? f).clamp(0.0, 1.0), child: child),
        ),
      ),
    );
  }
}

/// The recognized words: left-aligned, one colour throughout, a blinking
/// caret, and long text keeping its newest line in view.
class _LiveWords extends StatelessWidget {
  const _LiveWords({
    required this.controller,
    required this.listening,
    required this.blur,
  });

  final MealVoiceController controller;
  final bool listening;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final words = Text.rich(
      key: const Key('meal-voice-live-text'),
      TextSpan(
        children: [
          TextSpan(text: controller.liveText),
          if (listening)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xxs),
                child: _Blink(
                  child: Container(
                    width: AppBorders.selected,
                    height: AppSizes.voiceCaret,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      style: AppTypography.voiceLiveText,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: AppSizes.voiceLiveTextMax),
      child: SingleChildScrollView(
        // Newest line stays visible; earlier lines scroll up.
        reverse: true,
        child: SizedBox(
          width: double.infinity,
          child: _GrowSmoothly(
            child: Semantics(
              liveRegion: true,
              child: blur > 0.05
                  ? ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(
                        sigmaX: blur,
                        sigmaY: blur,
                      ),
                      child: words,
                    )
                  : words,
            ),
          ),
        ),
      ),
    );
  }
}

/// Eases height changes as lines are added; Reduce Motion resizes at once
/// (AnimatedSize with a zero duration re-dirties its own layout).
class _GrowSmoothly extends StatelessWidget {
  const _GrowSmoothly({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MediaQuery.disableAnimationsOf(context)
      ? child
      : AnimatedSize(
          duration: AppMotion.voiceGrow,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topLeft,
          child: child,
        );
}

class _RecordingDot extends StatelessWidget {
  const _RecordingDot({required this.blink});

  final bool blink;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: AppSizes.voiceRecordDot,
      height: AppSizes.voiceRecordDot,
      decoration: const BoxDecoration(
        color: AppColors.destructive,
        shape: BoxShape.circle,
      ),
    );
    return blink ? _Blink(child: dot) : dot;
  }
}

double _mix(double a, double b, double t) => a + (b - a) * t;

String _clock(Duration elapsed) =>
    '${elapsed.inMinutes.toString().padLeft(2, '0')}:'
    '${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

/// The 80 dp round control: a white square to stop, a spinner while access
/// or the final text is pending, otherwise a microphone to start or allow.
class _RecordButton extends StatelessWidget {
  const _RecordButton({
    required this.stage,
    required this.noAccess,
    required this.onRecord,
    required this.onStop,
  });

  final MealVoiceStage stage;
  final bool noAccess;
  final VoidCallback? onRecord;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final listening = stage == MealVoiceStage.listening;
    final waiting =
        stage == MealVoiceStage.checking || stage == MealVoiceStage.finishing;
    final VoidCallback? onTap = listening
        ? onStop
        : waiting
        ? null
        : onRecord;
    final enabled = onTap != null || waiting;

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: waiting
          ? (stage == MealVoiceStage.checking
                ? strings.mealVoicePreparing
                : strings.mealVoiceFinishing)
          : listening
          ? strings.mealVoiceStop
          : noAccess
          ? strings.mealVoiceAllowAction
          : strings.mealVoiceStartAction,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: const CircleBorder(),
          shadows: enabled ? AppShadows.voiceRecord : null,
        ),
        child: Material(
          color: enabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.4),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const Key('meal-voice-record'),
            onTap: onTap,
            child: SizedBox.square(
              dimension: AppSizes.voiceRecordButton,
              child: Center(
                child: AnimatedSwitcher(
                  duration: AppMotion.duration(context),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: waiting
                      ? SizedBox.square(
                          key: const ValueKey('waiting'),
                          dimension: AppSizes.iconXl,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryForeground,
                            strokeWidth: AppBorders.selected + 1,
                            value: MediaQuery.disableAnimationsOf(context)
                                ? 1
                                : null,
                          ),
                        )
                      : listening
                      // Export: `size-7 rounded-md bg-primary-foreground`.
                      ? Container(
                          key: const ValueKey('stop'),
                          width: AppSizes.iconXl,
                          height: AppSizes.iconXl,
                          decoration: BoxDecoration(
                            color: AppColors.primaryForeground,
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                        )
                      : const AppIcon.asset(
                          'ph-microphone-fill',
                          key: ValueKey('mic'),
                          size: AppSizes.iconXl,
                          color: AppColors.primaryForeground,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
