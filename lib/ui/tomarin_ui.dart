import 'package:flutter/material.dart';
import 'theme.dart';

/// One file per pose in assets/tomarin/, named tomarin_<pose>.png
enum Pose {
  landing,
  negotiating,
  annoyed,
  furious,
  disappointed,
  sleepy,
  gentle,
  delighted,
}

/// Tomarin as a picture. If the file is missing, a small placeholder bird shows instead.
class TomarinSprite extends StatelessWidget {
  final Pose pose;
  final double height;
  const TomarinSprite(this.pose, {super.key, this.height = 260});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/tomarin/tomarin_${pose.name}.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => SizedBox(
        height: height,
        child: Icon(Icons.flutter_dash, size: height * 0.6, color: T.inkSoft),
      ),
    );
  }
}

/// A white speech bubble with a tail pointing down at Tomarin.
class SpeechBubble extends StatelessWidget {
  final Widget child;
  final double tilt; // radians
  final Color color;
  const SpeechBubble({
    super.key,
    required this.child,
    this.tilt = 0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
          CustomPaint(size: const Size(28, 14), painter: _TailPainter(color)),
        ],
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  final Color color;
  _TailPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TailPainter old) => old.color != color;
}

/// A strip of washi tape, like the ones holding notes in the designs.
class WashiTape extends StatelessWidget {
  final double angle;
  final double width;
  final Color color;
  const WashiTape({
    super.key,
    this.angle = -0.05,
    this.width = 80,
    this.color = T.persimmon,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: 22,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

/// A round red rubber stamp (hanko).
class HankoStamp extends StatelessWidget {
  final String text;
  final double size;
  final double angle;
  const HankoStamp({
    super.key,
    required this.text,
    this.size = 90,
    this.angle = -0.2,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.7),
          border: Border.all(color: T.vermilion, width: 4),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: T.shout(size * 0.24, color: T.vermilion, height: 1.15),
        ),
      ),
    );
  }
}