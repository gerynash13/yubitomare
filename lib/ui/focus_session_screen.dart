import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../bond.dart';
import '../focus_log.dart';
import '../l10n/app_localizations.dart';
import 'summary_screen.dart';
import 'theme.dart';
import 'tomarin_ui.dart';

/// Set to true to test: Tomarin asks "are you there?" every 20 to 30 seconds
/// instead of every 8 to 12 minutes.
const bool kFocusTestMode = true;

Duration _randomCheckDelay() {
  final r = math.Random();
  return kFocusTestMode
      ? Duration(seconds: 20 + r.nextInt(11))
      : Duration(minutes: 8, seconds: r.nextInt(4 * 60 + 1));
}

// How long the user has to answer a check.
const Duration _checkWindow = kFocusTestMode ? Duration(seconds: 15) : Duration(minutes: 2);
// How much time after the last answer still counts if the user never answers again.
const Duration _maxTail = kFocusTestMode ? Duration(seconds: 45) : Duration(minutes: 14);

class FocusSessionScreen extends StatefulWidget {
  final String task;
  final String goal;
  const FocusSessionScreen({super.key, this.task = '', this.goal = ''});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final DateTime _start = DateTime.now();
  late DateTime _confirmedAt = _start;
  late final AnimationController _breath;
  Timer? _tick;
  Timer? _checkTimer;
  Timer? _windowTimer;
  int _minutes = 0;
  bool _checking = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _breath = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat(reverse: true);
    _tick = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_finished && mounted) {
        setState(() => _minutes = DateTime.now().difference(_start).inMinutes);
      }
    });
    _scheduleCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _checkTimer?.cancel();
    _windowTimer?.cancel();
    _breath.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Leaving the app ends the session. The time that Tomarin could confirm still counts.
    if (state == AppLifecycleState.paused) _finish();
  }

  // ---------- the presence check ----------

  void _scheduleCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer(_randomCheckDelay(), _startCheck);
  }

  void _startCheck() {
    if (_finished || !mounted) return;
    setState(() => _checking = true);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 350), HapticFeedback.heavyImpact);
    _windowTimer = Timer(_checkWindow, _missCheck);
  }

  void _confirm() {
    if (!_checking) return;
    _windowTimer?.cancel();
    HapticFeedback.selectionClick();
    setState(() => _checking = false);
    _confirmedAt = DateTime.now();
    _scheduleCheck();
  }

  void _missCheck() {
    if (_finished || !mounted) return;
    setState(() => _checking = false);
    _scheduleCheck();
  }

  // ---------- finishing ----------

  Future<void> _finish() async {
    if (_finished) return;
    _finished = true;
    _tick?.cancel();
    _checkTimer?.cancel();
    _windowTimer?.cancel();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final end = DateTime.now();
    final minutes = end.difference(_start).inMinutes;
    // Time up to the last answer counts, plus a short tail after it.
    final tail = end.difference(_confirmedAt);
    final credited = _confirmedAt.difference(_start) + (tail > _maxTail ? _maxTail : tail);
    final creditedMin = math.min(credited.inMinutes, minutes);

    final bond = await Bond.addFocusMinutes(creditedMin);
    await FocusLog.add(
      minutes: minutes,
      credited: creditedMin,
      goal: widget.goal.isNotEmpty ? widget.goal : widget.task,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SummaryScreen(
          start: _start,
          end: end,
          minutes: minutes,
          credited: creditedMin,
          bond: bond,
        ),
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final focus = widget.goal.isNotEmpty ? widget.goal : widget.task;
    return PopScope(
      canPop: false, // the only way out is the long press
      child: Scaffold(
        backgroundColor: T.night,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: focus.isEmpty
                          ? const SizedBox(height: 24)
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.edit_note, size: 18, color: Color(0xFFE8D5C0)),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    l.focusNow(focus),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: T.body(14, color: const Color(0xFFE8D5C0), weight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const Spacer(),
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.04).animate(
                      CurvedAnimation(parent: _breath, curve: Curves.easeInOut),
                    ),
                    child: const TomarinSprite(Pose.sleepy, height: 200),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$_minutes', style: T.shout(72, color: const Color(0xFFFFF1E0))),
                      const SizedBox(width: 8),
                      Text(l.focusUnit, style: T.body(24, color: const Color(0xFFE8D5C0), weight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      l.focusWith,
                      style: T.body(13, color: const Color(0xFFE8D5C0), weight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onLongPress: _finish,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 28),
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.spa_outlined, size: 20, color: T.persimmon),
                          const SizedBox(width: 8),
                          Text(
                            l.focusHint,
                            style: T.body(14, color: const Color(0xFFE8D5C0), weight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_checking) _checkLayer(l),
            ],
          ),
        ),
      ),
    );
  }

  // "Pi? Are you there?" Tap anywhere to answer.
  Widget _checkLayer(AppLocalizations l) {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _confirm,
        child: Container(
          color: T.night.withValues(alpha: 0.97),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 4),
                ),
                child: const Center(child: TomarinSprite(Pose.negotiating, height: 150)),
              ),
              const SizedBox(height: 28),
              Text(l.checkTitle, style: T.shout(30, color: const Color(0xFFFFF1E0))),
              const SizedBox(height: 8),
              Text(
                l.checkHint,
                style: T.body(14, color: const Color(0xFFE8D5C0), weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}