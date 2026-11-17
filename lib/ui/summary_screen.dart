import 'package:flutter/material.dart';
import '../bond.dart';
import '../focus_log.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';
import 'tomarin_ui.dart';
import 'focus_session_screen.dart' show kFocusTestMode;
import '../locale_controller.dart';
import '../reflect_api.dart';
import '../tracker_config.dart';
import 'crisis_screen.dart';
import '../storage.dart';

/// Shown right after a focus session. The user can write what they did and how well it went.
/// Everything here is optional: closing the book is always allowed.
class SummaryScreen extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  final int minutes; // how long the session lasted
  final int credited; // the part Tomarin could confirm
  final BondResult bond;
  final String task;

  const SummaryScreen({
    super.key,
    required this.start,
    required this.end,
    required this.minutes,
    required this.credited,
    required this.bond,
    required this.task,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _text = TextEditingController();
  String? _progress; // none, little, fair, great
  bool _saved = false;
  String _reply = '';
  bool _waiting = false;
  bool _crisis = false;
  bool _taskOpen = false; // the card is shown
  bool _taskDone = false;
  int _taskGain = 0;
  bool _taskLevelUp = false;

  @override
  void initState() {
    super.initState();
    _checkTask();
  }

  // Show the card only if that task still exists and is not done.
  Future<void> _checkTask() async {
    if (widget.task.isEmpty) return;
    final tasks = await Store.loadTasks();
    if (!mounted) return;
    setState(() => _taskOpen = tasks.any((t) => t.text == widget.task && !t.done));
  }

  Future<void> _finishTask() async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.taskDoneTitle),
        content: Text(l.taskDoneBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.taskDoneNot),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.taskDoneYes),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final tasks = await Store.loadTasks();
    final i = tasks.indexWhere((t) => t.text == widget.task && !t.done);
    if (i < 0) {
      setState(() => _taskOpen = false);
      return;
    }
    tasks[i].done = true;
    tasks[i].doneOn = Store.todayKey();
    await Store.saveTasks(tasks);
    final r = await Bond.addTaskDone();
    if (!mounted) return;
    setState(() {
      _taskDone = true;
      _taskGain = r.gained;
      _taskLevelUp = r.leveledUp;
    });
  }

  Widget _taskCard(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _taskDone ? T.paperLow : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _taskDone ? T.vermilion : T.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.sumTaskAsk, style: T.body(15, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.task,
                  style: T.body(16, weight: FontWeight.w700).copyWith(
                    decoration: _taskDone ? TextDecoration.lineThrough : null,
                    color: _taskDone ? T.inkSoft : T.ink,
                  ),
                ),
              ),
              if (_taskDone) HankoStamp(text: l.todayDoneStamp, size: 46, angle: -0.2),
            ],
          ),
          const SizedBox(height: 10),
          if (!_taskDone)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _finishTask,
                child: Text(l.taskDoneYes),
              ),
            )
          else if (_taskGain > 0)
            Text(
              _taskLevelUp
                  ? '${l.bondGainSmall(_taskGain)}  ${l.bondUp}'
                  : l.bondGainSmall(_taskGain),
              style: T.body(13, color: T.vermilion, weight: FontWeight.w700),
            ),
        ],
      ),
    );
  }

  // A note that sounds like real distress is never sent to the AI.
  static final _heavyWords = RegExp(
    r'死にた|消えたい|いなくなりたい|自殺|生きて.{0,6}(たくない|意味)|kill myself|suicide|want to die|end it all',
    caseSensitive: false,
  );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _replyFor(AppLocalizations l, String progress) => switch (progress) {
        'great' => l.replyGreat,
        'fair' => l.replyFair,
        'little' => l.replyLittle,
        _ => l.replyNone,
      };

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final progress = _progress ?? '';
    final note = _text.text.trim();
    await FocusLog.updateLast(text: note, progress: progress);
    if (!mounted) return;

    if (_heavyWords.hasMatch(note)) {
      setState(() {
        _saved = true;
        _crisis = true;
        _reply = '${l.sincere1}\n\n${l.sincere2}';
      });
      return;
    }

    final fallback = _replyFor(l, progress);
    setState(() {
      _saved = true;
      _waiting = true;
      _reply = '';
    });
    String? ai;
    try {
      final cfg = await TrackerConfig.load();
      final logs = await FocusLog.load();
      final goal = logs.isEmpty ? '' : (logs.last['goal'] as String? ?? '');
      ai = await fetchReflection(
        lang: await effectiveLanguage(),
        name: cfg.name,
        suffix: cfg.suffix,
        progress: progress,
        note: note,
        goal: goal,
        minutes: widget.credited,
      ).timeout(const Duration(seconds: 8));
    } catch (_) {
      ai = null;
    }
    if (!mounted) return;
    setState(() {
      _waiting = false;
      _reply = (ai == null || ai.isEmpty) ? fallback : ai;
    });
  }

  void _close() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // A very short session: no notebook, just a friendly word.
    if (widget.credited < (kFocusTestMode ? 0 : 2)) return _short(l);

    final proud = _progress == 'great' || _progress == 'fair';
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: T.paperHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_outlined, size: 18, color: T.vermilion),
                      const SizedBox(width: 6),
                      Text(l.sumTitle, style: T.shout(17)),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(onPressed: _close, icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 14),
            PaperCard(
              tape: true,
              color: T.paperLow,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: T.paperHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l.sumResult,
                                style: T.body(12, color: T.inkSoft, weight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_hm(widget.start)} – ${_hm(widget.end)}',
                              style: T.body(12, color: T.inkSoft),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l.sumDone(widget.credited),
                          style: T.shout(28, color: T.vermilion),
                        ),
                        if (widget.credited < widget.minutes) ...[
                          const SizedBox(height: 6),
                          Text(
                            l.sumPartial(widget.minutes),
                            style: T.body(12, color: T.inkSoft, weight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const TomarinSprite(Pose.delighted, height: 100),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PaperCard(
              tape: true,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: T.vermilion,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(l.sumBookTitle, style: T.shout(20)),
                    ],
                  ),
                  const Divider(color: T.line, height: 24),
                  Text(l.sumWhat, style: T.body(17, weight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _text,
                    enabled: !_saved,
                    minLines: 3,
                    maxLines: 5,
                    style: T.body(15, weight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: l.sumWhatHint,
                      filled: true,
                      fillColor: T.paperLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l.sumHow, style: T.body(17, weight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _chip('none', '☁️', l.sumP0),
                      _chip('little', '🌱', l.sumP1),
                      _chip('fair', '✨', l.sumP2),
                      _chip('great', '🌸', l.sumP3),
                    ],
                  ),
                  if (_saved) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: T.paperLow,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.sumPenTitle,
                                  style: T.note(14, color: T.vermilion),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _waiting ? '…' : _reply,
                                  style: T.note(19, color: T.vermilion, height: 1.6),
                                ),
                                if (_crisis) ...[
                                  const SizedBox(height: 12),
                                  OutlinedButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const CrisisScreen()),
                                    ),
                                    child: Text(l.crisisTitle),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (proud && !_waiting && !_crisis) HankoStamp(text: l.todayDoneStamp, size: 60, angle: -0.2),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_taskOpen) ...[
              const SizedBox(height: 16),
              _taskCard(l),
            ],
            const SizedBox(height: 16),
            _rewards(l),
            const SizedBox(height: 18),
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _saved ? _close : (_progress == null ? null : _save),
                style: ElevatedButton.styleFrom(
                  backgroundColor: T.vermilion,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: T.vermilion.withValues(alpha: 0.35),
                  disabledForegroundColor: Colors.white70,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  _saved ? l.focusClose : l.sumSave,
                  style: T.body(17, color: Colors.white, weight: FontWeight.w800),
                ),
              ),
            ),
            if (!_saved)
              TextButton(
                onPressed: _close,
                child: Text(l.sumSkip, style: T.body(14, weight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String id, String emoji, String label) {
    final selected = _progress == id;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: selected ? T.persimmon : T.paperLow,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _saved ? null : () => setState(() => _progress = id),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: selected ? T.persimmonDeep : Colors.transparent, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(label, style: T.body(12, weight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _rewards(AppLocalizations l) {
    final b = widget.bond;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: T.paperLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: T.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_border, color: T.vermilion),
              const SizedBox(width: 8),
              Text(l.sumReward, style: T.body(15, weight: FontWeight.w800)),
              const Spacer(),
              if (b.gained > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: T.persimmon.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    l.focusBondGain(b.gained),
                    style: T.shout(16, color: T.vermilion),
                  ),
                ),
            ],
          ),
          if (b.leveledUp) ...[
            const SizedBox(height: 8),
            Text(l.bondUp, style: T.body(13, color: T.vermilion, weight: FontWeight.w700)),
          ],
          if (b.capped && widget.credited >= 1) ...[
            const SizedBox(height: 8),
            Text(l.focusCapped, style: T.body(13, color: T.inkSoft, weight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  Widget _short(AppLocalizations l) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TomarinSprite(Pose.sleepy, height: 160),
              const SizedBox(height: 20),
              Text(
                l.focusShort,
                textAlign: TextAlign.center,
                style: T.body(18, weight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              OutlinedButton(onPressed: _close, child: Text(l.focusClose)),
            ],
          ),
        ),
      ),
    );
  }
}