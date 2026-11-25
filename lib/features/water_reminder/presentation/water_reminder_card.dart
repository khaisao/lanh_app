import 'dart:math' as math;
import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanh_app/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/water_reminder_schedule.dart';
import '../water_reminder_providers.dart';

/// Sleek "Menu · Nhắc nước tắt/bật" card: the fixed schedule while off, the
/// next reminder time while on. Turning it on asks for notification
/// permission with the system prompt, then confirms with a toast.
class WaterReminderCard extends ConsumerStatefulWidget {
  const WaterReminderCard({super.key});

  @override
  ConsumerState<WaterReminderCard> createState() => _WaterReminderCardState();
}

class _WaterReminderCardState extends ConsumerState<WaterReminderCard> {
  // The Menu tab stays alive, so "lần tới" must follow the clock.
  late final Timer _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final enabled = ref.watch(waterReminderProvider).value ?? false;
    final subtitle = enabled
        ? strings.waterReminderNext(
            _time(WaterReminderSchedule.nextHour(DateTime.now())),
          )
        : strings.waterReminderSchedule(
            _time(WaterReminderSchedule.firstHour),
            _time(WaterReminderSchedule.lastHour),
            WaterReminderSchedule.everyHours,
          );
    return AppGlassCard(
      key: const Key('water-reminder-card'),
      radius: AppRadii.glassInner,
      padding: EdgeInsets.zero,
      fill: Colors.transparent,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppMenu.waterCard,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: ExcludeSemantics(child: _WaterWaves()),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.card),
              child: Row(
                children: [
                  const AppGradientIconWell(
                    icon: 'ph-drop-fill',
                    gradient: AppMenu.wellWater,
                    color: AppColors.waterIcon,
                    size: AppMenu.wellLarge,
                    iconSize: AppSizes.iconLg,
                    edge: AppMenu.wellWaterEdge,
                    shadows: AppMenu.wellLift,
                  ),
                  const SizedBox(width: AppMenu.rowGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.waterReminderTitle,
                          style: AppTypography.sectionTitle,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(subtitle, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  Semantics(
                    label: strings.waterReminderTitle,
                    child: Switch(
                      key: const Key('water-reminder-switch'),
                      value: enabled,
                      onChanged: (on) => _change(context, on),
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

  Future<void> _change(BuildContext context, bool on) async {
    final strings = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final scheduler = ref.read(waterReminderSchedulerProvider);
    messenger.hideCurrentSnackBar();
    void toast(
      Key key,
      String message, {
      String? icon,
      SnackBarAction? action,
    }) => messenger.showSnackBar(
      _toast(key: key, message: message, icon: icon, action: action),
    );
    try {
      final result = await ref
          .read(waterReminderProvider.notifier)
          .setEnabled(
            on,
            message: (
              channel: strings.waterReminderChannel,
              title: strings.waterReminderNotificationTitle,
              body: strings.waterReminderNotificationBody,
            ),
          );
      switch (result) {
        case WaterReminderChange.enabled:
          toast(
            const Key('water-reminder-toast'),
            strings.waterReminderEnabled,
          );
        case WaterReminderChange.permissionDenied:
          toast(
            const Key('water-reminder-denied'),
            strings.waterReminderDenied,
            icon: 'ph-bell',
            action: SnackBarAction(
              label: strings.waterReminderOpenSettings,
              textColor: AppColors.primary,
              onPressed: scheduler.openSettings,
            ),
          );
        case WaterReminderChange.disabled:
          break;
      }
    } catch (_) {
      ref.invalidate(waterReminderProvider);
      toast(
        const Key('water-reminder-error'),
        strings.waterReminderError,
        icon: 'ph-bell',
      );
    }
  }

  /// Sleek Menu toast: a centred `card/70` glass pill 96 dp above the bottom
  /// with an outlined check and a 14 pt semibold line.
  static SnackBar _toast({
    required Key key,
    required String message,
    String? icon,
    SnackBarAction? action,
  }) => SnackBar(
    key: key,
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    backgroundColor: Colors.transparent,
    padding: EdgeInsets.zero,
    margin: const EdgeInsets.fromLTRB(
      AppSpacing.gutter,
      0,
      AppSpacing.gutter,
      AppSizes.nav + AppSpacing.navBottom + AppSpacing.gutter,
    ),
    content: Center(
      child: AppGlassCard(
        stadium: true,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.denseGap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xs,
          children: [
            ExcludeSemantics(
              child: AppIcon.asset(
                icon ?? 'ph-check-circle',
                size: AppSizes.iconSm,
                color: AppColors.primary,
              ),
            ),
            Flexible(child: Text(message, style: AppTypography.choiceTitle)),
            if (action != null)
              TextButton(
                onPressed: action.onPressed,
                child: Text(action.label, style: AppTypography.button),
              ),
          ],
        ),
      ),
    ),
  );

  static String _time(int hour) => '$hour:00';
}

/// The two `chart-3` waves along the card's bottom edge (Sleek: 96 dp at
/// 25 %, 64 dp at 15 %), drifting in opposite directions like water.
/// Reduce Motion and an offstage tab hold them still.
class _WaterWaves extends StatefulWidget {
  const _WaterWaves();

  @override
  State<_WaterWaves> createState() => _WaterWavesState();
}

class _WaterWavesState extends State<_WaterWaves>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppMotion.waterWaves,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RepaintBoundary(child: CustomPaint(painter: _WavesPainter(_controller)));
}

class _WavesPainter extends CustomPainter {
  _WavesPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = t.value * 2 * math.pi;
    // Whole-number phase speeds keep the loop seamless.
    _wave(
      canvas,
      size,
      height: AppMenu.waveBackHeight,
      color: AppMenu.waveBack,
      level: 0.5,
      amplitude: 0.14,
      phase: phase,
    );
    _wave(
      canvas,
      size,
      height: AppMenu.waveFrontHeight,
      color: AppMenu.waveFront,
      level: 0.69,
      amplitude: 0.13,
      phase: -2 * phase + math.pi / 2,
    );
  }

  /// A swell across the card [height] tall: one long sine plus a smaller
  /// ripple, [level] and [amplitude] as fractions of that height.
  void _wave(
    Canvas canvas,
    Size size, {
    required double height,
    required Color color,
    required double level,
    required double amplitude,
    required double phase,
  }) {
    final top = size.height - height;
    double y(double x) {
      final a = 2 * math.pi * x / size.width;
      return top +
          height *
              (level +
                  amplitude * math.sin(a + phase) +
                  amplitude * 0.3 * math.sin(2 * a - phase));
    }

    final path = Path()..moveTo(0, y(0));
    for (var x = 4.0; x < size.width; x += 4) {
      path.lineTo(x, y(x));
    }
    path
      ..lineTo(size.width, y(size.width))
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WavesPainter oldDelegate) => oldDelegate.t != t;
}
