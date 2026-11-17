part of '../app_ui.dart';

/// The viewport background from the TodayGradientMầmXanh HTML design.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  static const _image = ExactAssetImage(
    'assets/backgrounds/lanh-gradient.jpg',
    package: 'app_ui',
  );

  final Widget child;

  /// Warms the image cache before the first Flutter frame is displayed.
  static Future<void> preload() {
    final ready = Completer<void>();
    final stream = _image.resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    void finish() {
      stream.removeListener(listener);
      ready.complete();
    }

    listener = ImageStreamListener((image, _) {
      image.dispose();
      finish();
    }, onError: (_, _) => finish());
    stream.addListener(listener);
    return ready.future;
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    children: [
      const Positioned.fill(
        child: IgnorePointer(
          child: RepaintBoundary(
            child: ColoredBox(
              color: AppColors.background,
              child: Image(
                image: _image,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ),
          ),
        ),
      ),
      child,
    ],
  );
}
