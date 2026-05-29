import 'package:flutter/material.dart';


/// Kits & Kids stroller-K logo, drawn with CustomPainter.
/// Matches the mockup: curved handle arch (dark blue) + upper K arm (light blue)
/// + transparent basket + two wheels.
class AppLogo extends StatelessWidget {
  final double size;
  final bool whiteScheme; // for dark backgrounds (splash)

  const AppLogo({super.key, this.size = 72, this.whiteScheme = false});

  @override
  Widget build(BuildContext context) {
    final primary = whiteScheme ? const Color(0xFF7BB0FF) : const Color(0xFF3C82F5);
    final light   = whiteScheme ? const Color(0xAABDD8FF) : const Color(0xFF89B3E8);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _StrollerPainter(primary: primary, light: light)),
    );
  }
}

class _StrollerPainter extends CustomPainter {
  final Color primary;
  final Color light;
  const _StrollerPainter({required this.primary, required this.light});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final stroke = w * 0.135;

    // ── 1. Stroller basket (semi-transparent light blue D-shape) ──
    final basketPath = Path()
      ..moveTo(w * 0.25, h * 0.38)
      ..quadraticBezierTo(w * 0.25, h * 0.70, w * 0.54, h * 0.70)
      ..quadraticBezierTo(w * 0.83, h * 0.70, w * 0.83, h * 0.38)
      ..close();
    canvas.drawPath(
      basketPath,
      Paint()
        ..color = light.withValues(alpha: 0.38)
        ..style = PaintingStyle.fill,
    );

    // ── 2. Upper K arm (lighter blue diagonal stroke) ──
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.245, h * 0.40) // K-joint
        ..lineTo(w * 0.81, h * 0.06), // upper-right
      Paint()
        ..color = light
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 0.85
        ..strokeCap = StrokeCap.round,
    );

    // ── 3. Handle / K vertical bar (dark blue arch — the stroller handle) ──
    // Starts at bottom-left, goes up, curves into an arch at the top (like a push handle)
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.215, h * 0.73) // bottom of back stroke
        ..lineTo(w * 0.215, h * 0.17) // straight up
        ..quadraticBezierTo(           // curve top-left → right
            w * 0.215, h * 0.04,
            w * 0.395, h * 0.04)
        ..quadraticBezierTo(           // continue arch to the right
            w * 0.630, h * 0.04,
            w * 0.630, h * 0.23),     // end of handle arch
      Paint()
        ..color = primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ── 4. Wheels (solid dark blue circles) ──
    final wheelR = w * 0.082;
    final wheelPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.365, h * 0.875), wheelR, wheelPaint);
    canvas.drawCircle(Offset(w * 0.695, h * 0.875), wheelR, wheelPaint);
  }

  @override
  bool shouldRepaint(_StrollerPainter old) =>
      primary != old.primary || light != old.light;
}
