part of '../app_ui.dart';

/// The CSS `corner-shape: squircle` used by the design export.
class AppSquircleBorder extends OutlinedBorder {
  const AppSquircleBorder({required this.radius, super.side});

  final double radius;

  @override
  AppSquircleBorder copyWith({BorderSide? side}) =>
      AppSquircleBorder(radius: radius, side: side ?? this.side);

  @override
  ShapeBorder scale(double t) =>
      AppSquircleBorder(radius: radius * t, side: side.scale(t));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect.inflate(side.strokeOutset), radius + side.strokeOutset);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect.deflate(side.strokeInset), radius - side.strokeInset);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty || side.style == BorderStyle.none) return;
    final outline = getOuterPath(rect);
    if (side.width == 0) {
      canvas.drawPath(outline, side.toPaint());
      return;
    }
    outline
      ..fillType = PathFillType.evenOdd
      ..addPath(getInnerPath(rect), Offset.zero);
    canvas.drawPath(outline, Paint()..color = side.color);
  }

  Path _path(Rect rect, double requestedRadius) {
    if (rect.isEmpty) return Path();
    final r = requestedRadius.clamp(0.0, rect.shortestSide / 2);
    final path = Path()..moveTo(rect.left + r, rect.top);

    void corner(Offset Function(double x, double y) point) {
      // Two cubic segments fit the fourth-power superellipse at its diagonal.
      const diagonal = 0.1591035847;
      const tangent = 0.159;
      void curve(Offset a, Offset b, Offset end) =>
          path.cubicTo(a.dx, a.dy, b.dx, b.dy, end.dx, end.dy);
      final start = point(1, 0);
      path.lineTo(start.dx, start.dy);
      curve(
        point(0.568, 0),
        point(diagonal + tangent, diagonal - tangent),
        point(diagonal, diagonal),
      );
      curve(
        point(diagonal - tangent, diagonal + tangent),
        point(0, 0.568),
        point(0, 1),
      );
    }

    corner((x, y) => Offset(rect.right - x * r, rect.top + y * r));
    corner((x, y) => Offset(rect.right - y * r, rect.bottom - x * r));
    corner((x, y) => Offset(rect.left + x * r, rect.bottom - y * r));
    corner((x, y) => Offset(rect.left + y * r, rect.top + x * r));
    return path..close();
  }

  @override
  bool operator ==(Object other) =>
      other is AppSquircleBorder &&
      radius == other.radius &&
      side == other.side;

  @override
  int get hashCode => Object.hash(radius, side);
}
