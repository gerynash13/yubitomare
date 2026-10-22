import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'bond.dart';
import 'l10n/app_localizations.dart';

const _bg = Color(0xFF14121A);
const _soft = Color(0xFF8E8A99);
const _warm = Color(0xFFB7A98F);

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});
  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final DateTime _start = DateTime.now();
  late final AnimationController _breath;
  Timer? _tick;
  int _minutes = 0;
  bool _finished = false;
  int _minutesDone = 0;
  BondResult? _result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _tick = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!_finished) {
        setState(() => _minutes = DateTime.now().difference(_start).inMinutes);
      }
    });
  }

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final minutes = DateTime.now().difference(_start).inMinutes;
    final r = await Bond.addFocusMinutes(minutes);
    if (!mounted) return;
    setState(() {
      _minutesDone = minutes;
      _result = r;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Leaving the app ends the session. The time so far still counts.
    if (state == AppLifecycleState.paused) _finish();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _breath.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!_finished) {
      // Left with the back button: still credit the time.
      Bond.addFocusMinutes(DateTime.now().difference(_start).inMinutes);
    }
    super.dispose();
  }

  Widget _tomarin() => ScaleTransition(
        scale: Tween(begin: 1.0, end: 1.04).animate(
          CurvedAnimation(parent: _breath, curve: Curves.easeInOut),
        ),
        // Placeholder bird. Real resting-pose art goes here later.
        child: const Icon(Icons.flutter_dash, size: 110, color: _warm),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final r = _result;

    if (r != null) {
      final lines = <String>[
        _minutesDone < 1 ? l.focusShort : l.focusDone(_minutesDone),
        if (r.gained > 0) l.focusBondGain(r.gained),
        if (r.capped && _minutesDone >= 1) l.focusCapped,
        if (r.leveledUp) l.bondUp,
      ];
      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flutter_dash, size: 90, color: _warm),
                const SizedBox(height: 24),
                for (final t in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      t,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _soft, fontSize: 18),
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l.focusClose),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: _finish,
        child: SizedBox.expand(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tomarin(),
                const SizedBox(height: 28),
                Text(
                  l.focusElapsed(_minutes),
                  style: const TextStyle(
                    color: _soft,
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 80),
                Text(
                  l.focusHint,
                  style: const TextStyle(color: Color(0xFF4A4756), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}