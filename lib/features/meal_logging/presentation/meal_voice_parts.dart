part of 'meal_voice_flow.dart';

/// Shared page frame of VoiceMealInput/VoiceMealConfirm: cream page, green and
/// blue glows, a 20 dp gutter and a floating glass [dock].
class _VoiceScaffold extends StatelessWidget {
  const _VoiceScaffold({required this.child, this.header, this.dock});

  final Widget? header;
  final Widget child;
  final Widget? dock;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Stack(
      children: [
        const Positioned.fill(child: _VoiceGlow()),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.contentMax),
              child: BackdropGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (header != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.sm,
                          AppSpacing.md,
                          AppSpacing.sm,
                          0,
                        ),
                        child: header,
                      ),
                    Expanded(child: child),
                    if (dock != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        child: AppGlassSurface(
                          radius: AppRadii.glassHero,
                          shadows: AppShadows.glassDock,
                          opacity: 0.7,
                          child: dock!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _VoiceGlow extends StatelessWidget {
  const _VoiceGlow();

  @override
  Widget build(BuildContext context) => ClipRect(
    child: Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: AppSizes.voiceGradient,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.secondary,
                  AppColors.chartBlue.withValues(alpha: 0.2),
                  AppColors.background.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -AppSizes.summaryImage,
          left: -AppSpacing.xxl - AppSpacing.md,
          child: _glow(AppColors.secondary, AppSizes.welcomeOuterHalo),
        ),
        Positioned(
          top: AppSizes.readableWidth,
          right: -AppSpacing.xxl * 2,
          child: _glow(
            AppColors.chartBlue.withValues(alpha: 0.4),
            AppSizes.readableWidth,
          ),
        ),
      ],
    ),
  );

  Widget _glow(Color color, double size) => ImageFiltered(
    imageFilter: ui.ImageFilter.blur(
      sigmaX: AppSizes.estimationBlur,
      sigmaY: AppSizes.estimationBlur,
    ),
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

/// Header row: a 44 dp glass control, a centered title and an empty slot of
/// the same width so the title stays centered.
class _VoiceHeader extends StatelessWidget {
  const _VoiceHeader({required this.title, required this.leading, this.color});

  final String title;
  final Widget leading;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      leading,
      Expanded(
        child: Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.sectionTitle.copyWith(color: color),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      const SizedBox(width: AppSizes.action),
    ],
  );
}

/// The export's `lanh-blink`: fades [child] in and out; steady with Reduce
/// Motion. Used for the recording dot and the caption caret.
class _Blink extends StatefulWidget {
  const _Blink({required this.child});

  final Widget child;

  @override
  State<_Blink> createState() => _BlinkState();
}

class _BlinkState extends State<_Blink> with SingleTickerProviderStateMixin {
  late final _blink = AnimationController(
    vsync: this,
    duration: AppMotion.voiceBlink,
    lowerBound: 0.2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _blink.value = 1;
    } else if (!_blink.isAnimating) {
      _blink.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _blink, child: widget.child);
}

/// The quiet text action under a dock's main control.
class _DockTextButton extends StatelessWidget {
  const _DockTextButton({
    required this.label,
    required this.onPressed,
    this.buttonKey,
    this.color = AppColors.mutedForeground,
  });

  final String label;
  final VoidCallback? onPressed;
  final Key? buttonKey;
  final Color color;

  @override
  Widget build(BuildContext context) => TextButton(
    key: buttonKey,
    onPressed: onPressed,
    style: TextButton.styleFrom(
      // The export's h-10 text action, kept at the 56 dp touch minimum.
      minimumSize: const Size(0, AppSizes.action),
      foregroundColor: color,
      textStyle: AppTypography.button,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    ),
    child: Text(label, textAlign: TextAlign.center),
  );
}
