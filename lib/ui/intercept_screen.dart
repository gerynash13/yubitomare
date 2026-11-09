import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';
import 'tomarin_ui.dart';

enum _Mood { soft, annoyed, furious, closed }

/// The full-screen card Tomarin shows the moment a guarded app opens.
///
/// It only draws and reports what the user did. Android decides what happens next:
///  - [onBack]: the user chose to go back
///  - [onPass]: the user took a pass of the given minutes
///  - [onLeft]: the user left (home button, app switcher) without answering
class InterceptScreen extends StatefulWidget {
  final String app; // name of the guarded app, e.g. YouTube
  final int level; // passes already used today
  final int total; // passes allowed per day
  final bool locked; // no passes left: "closed for today"
  final List<int> passOptions; // minutes, e.g. [5, 10, 15]
  final VoidCallback onBack;
  final void Function(int minutes) onPass;
  final VoidCallback onLeft;

  const InterceptScreen({
    super.key,
    required this.app,
    required this.level,
    required this.total,
    required this.locked,
    required this.passOptions,
    required this.onBack,
    required this.onPass,
    required this.onLeft,
  });

  @override
  State<InterceptScreen> createState() => _InterceptScreenState();
}

class _InterceptScreenState extends State<InterceptScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _shake;
  Timer? _timer;
  int _elapsed = 0; // seconds since the card appeared
  bool _answered = false;

  _Mood get _mood {
    if (widget.locked) return _Mood.closed;
    switch (math.min(widget.level, 2)) {
      case 0:
        return _Mood.soft;
      case 1:
        return _Mood.annoyed;
      default:
        return _Mood.furious;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (_mood == _Mood.furious) {
      _shake.repeat();
      HapticFeedback.heavyImpact();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _shake.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Home button or app switcher: the user walked away without answering.
    if (state == AppLifecycleState.paused && !_answered) {
      _answered = true;
      widget.onLeft();
    }
  }

  void _back() {
    if (_answered) return;
    _answered = true;
    widget.onBack();
  }

  void _pass(int minutes) {
    if (_answered) return;
    _answered = true;
    widget.onPass(minutes);
  }

  // A longer pass, or a later card of the day, means a longer wait.
  int _waitFor(int minutes) => minutes * (widget.level + 1);

  String _mmss(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final mood = _mood;
    return PopScope(
      canPop: false, // the system back button must not skip the card
      child: Scaffold(
        body: mood == _Mood.closed ? _closed(l) : _active(l, mood),
      ),
    );
  }

  // ---------- soft / annoyed / furious ----------

  Widget _active(AppLocalizations l, _Mood mood) {
    final (title, sub) = switch (mood) {
      _Mood.soft => (l.interceptShout0, l.interceptSub0(widget.app)),
      _Mood.annoyed => (l.interceptShout1(widget.app), l.interceptSub1),
      _ => (l.interceptShout2, l.interceptSub2),
    };
    final colors = switch (mood) {
      _Mood.soft => const [Color(0xFFFFA944), Color(0xFFF6C9AE)],
      _Mood.annoyed => const [Color(0xFFE2582C), Color(0xFFB8240C)],
      _ => const [Color(0xFFB41F09), Color(0xFF7F1304)],
    };
    final pose = switch (mood) {
      _Mood.soft => Pose.landing,
      _Mood.annoyed => Pose.annoyed,
      _ => Pose.furious,
    };
    final furious = mood == _Mood.furious;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          if (furious)
            const Positioned.fill(child: CustomPaint(painter: _SpeedLines())),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  SpeechBubble(
                    tilt: mood == _Mood.soft ? 0 : -0.02,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.level > 0)
                          Align(
                            alignment: Alignment.centerRight,
                            child: _Tag(l.interceptTag(widget.level, widget.total)),
                          ),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: T.shout(
                            furious ? 26 : 24,
                            color: mood == _Mood.soft ? T.ink : T.vermilion,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          sub,
                          textAlign: TextAlign.center,
                          style: T.body(16, weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final h = math.min(box.maxHeight, furious ? 360.0 : 320.0);
                        return Center(child: _bird(pose, h, furious));
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back, color: T.vermilion),
                      label: Text(
                        l.interceptBack,
                        style: T.shout(22, color: T.vermilion),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final m in widget.passOptions)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _passButton(l, m),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bird(Pose pose, double height, bool shaking) {
    final sprite = TomarinSprite(pose, height: height);
    if (!shaking) return sprite;
    return AnimatedBuilder(
      animation: _shake,
      child: sprite,
      builder: (context, child) {
        final t = _shake.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(math.sin(t * 6) * 4, math.cos(t * 5) * 3),
          child: Transform.scale(scale: 1 + math.sin(t) * 0.02, child: child),
        );
      },
    );
  }

  Widget _passButton(AppLocalizations l, int minutes) {
    final left = math.max(0, _waitFor(minutes) - _elapsed);
    final enabled = left == 0;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: Colors.white.withValues(alpha: enabled ? 0.28 : 0.16),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? () => _pass(minutes) : null,
          child: SizedBox(
            height: 56,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Text(
                      l.interceptPass(minutes),
                      style: T.body(14, color: Colors.white, weight: FontWeight.w700),
                    ),
                  ),
                ),
                if (!enabled)
                  Positioned(
                    top: 4,
                    right: 8,
                    child: Text(
                      _mmss(left),
                      style: T.body(10, color: Colors.white70),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- closed for today ----------

  Widget _closed(AppLocalizations l) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const TomarinSprite(Pose.disappointed, height: 210),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: HankoStamp(text: l.interceptStamp, size: 84),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.interceptClosedTitle,
                        textAlign: TextAlign.center,
                        style: T.shout(26, color: T.vermilion),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.interceptClosedBody(widget.app),
                        textAlign: TextAlign.center,
                        style: T.body(16, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      _infoCard(l),
                      const SizedBox(height: 14),
                      Text(
                        l.interceptClosedNote,
                        textAlign: TextAlign.center,
                        style: T.note(15, color: T.inkSoft),
                      ),
                    ],
                  ),
                ),
                const Positioned(top: 0, child: WashiTape(width: 96)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _back,
                icon: const Icon(Icons.home_outlined),
                label: Text(
                  l.interceptHome,
                  style: T.body(18, color: Colors.white, weight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: T.vermilion,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(AppLocalizations l) {
    Widget row(String label, String value, {bool big = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: T.body(14, color: T.inkSoft, weight: FontWeight.w700),
              ),
              Text(
                value,
                style: big
                    ? T.shout(18, color: T.vermilion)
                    : T.body(14, color: T.vermilion, weight: FontWeight.w800),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: T.paperLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: T.line),
      ),
      child: Column(
        children: [
          row(l.interceptClosedUsed, l.interceptClosedUsedValue(widget.total, widget.total)),
          const Divider(height: 1, color: T.line),
          row(l.interceptClosedNext, l.interceptClosedAt, big: true),
        ],
      ),
    );
  }
}

/// Small tilted label, like "Extensions today 1/3".
class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.04,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: T.paperHigh,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: T.body(12, color: T.vermilion, weight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Manga-style speed lines for the furious card.
class _SpeedLines extends CustomPainter {
  const _SpeedLines();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.5);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const lines = 28;
    for (var i = 0; i < lines; i++) {
      final angle = i * 2 * math.pi / lines + 0.1;
      final inner = size.shortestSide * 0.32 + (i % 3) * 10;
      final outer = size.longestSide;
      paint.strokeWidth = 2.0 + (i % 4) * 1.5;
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}