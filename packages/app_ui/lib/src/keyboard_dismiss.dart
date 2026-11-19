part of '../app_ui.dart';

/// App-wide rule: a tap outside the focused text field closes the keyboard.
///
/// Flutter only unfocuses on tap-outside for web by default. This overrides
/// [EditableTextTapOutsideIntent] / [EditableTextTapUpOutsideIntent] (the
/// pattern from Flutter's own API example) so every field in the app behaves
/// the same. The field unfocuses on pointer up only when the pointer moved
/// less than the platform touch slop, so scrolling a form keeps the keyboard; list views
/// that should close it on drag use `keyboardDismissBehavior` instead. Taps
/// on another field move focus there as usual, and widgets wrapped in
/// [TextFieldTapRegion] count as part of the field.
class AppKeyboardDismiss extends StatefulWidget {
  const AppKeyboardDismiss({super.key, required this.child});

  final Widget child;

  @override
  State<AppKeyboardDismiss> createState() => _AppKeyboardDismissState();
}

/// Flutter's `kTouchSlop`, used when the platform reports none.
const _defaultTouchSlop = 18.0;

class _AppKeyboardDismissState extends State<AppKeyboardDismiss> {
  Offset? _down;

  @override
  Widget build(BuildContext context) => Actions(
    actions: {
      EditableTextTapOutsideIntent:
          CallbackAction<EditableTextTapOutsideIntent>(
            onInvoke: (intent) {
              _down = intent.pointerDownEvent.position;
              return null;
            },
          ),
      EditableTextTapUpOutsideIntent:
          CallbackAction<EditableTextTapUpOutsideIntent>(
            onInvoke: (intent) {
              final down = _down;
              _down = null;
              if (down == null) return null;
              final moved = (intent.pointerUpEvent.position - down).distance;
              final slop =
                  MediaQuery.maybeGestureSettingsOf(context)?.touchSlop ??
                  _defaultTouchSlop;
              if (moved < slop) intent.focusNode.unfocus();
              return null;
            },
          ),
    },
    child: widget.child,
  );
}
