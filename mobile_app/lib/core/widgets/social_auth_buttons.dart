import 'package:flutter/material.dart';

/// Shared social auth UI widgets used on login and register screens.

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const GoogleSignInButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: Colors.white,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GoogleIcon(),
            SizedBox(width: 10),
            Text(
              'Continuer avec Google',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const AppleSignInButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apple_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Continuer avec Apple',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
        ),
        Expanded(child: Divider(color: Color(0xFFE2E8F0))),
      ],
    );
  }
}

/// Google "G" multicolor icon rendered with CustomPainter.
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(20, 20),
        painter: _GoogleIconPainter(),
      );
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    Paint arc(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.36
      ..strokeCap = StrokeCap.butt;

    // Blue (right)
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 0.82), -0.3, 2.7, false,
        arc(const Color(0xFF4285F4)));
    // Red (top-left)
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 0.82), 2.4, 1.6, false,
        arc(const Color(0xFFEA4335)));
    // Yellow (bottom-left)
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 0.82), 4.0, 0.9, false,
        arc(const Color(0xFFFBBC05)));
    // Green (bottom)
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 0.82), 4.9, 0.7, false,
        arc(const Color(0xFF34A853)));
    // Cross bar
    canvas.drawLine(
      Offset(c.dx, c.dy),
      Offset(c.dx + r * 0.72, c.dy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = r * 0.32
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GoogleIconPainter old) => false;
}
