import 'dart:async';
import 'package:flutter/material.dart';
import 'bond.dart';
import 'checkin.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'memory.dart';
import 'roast_api.dart';
import 'storage.dart';

class _Msg {
  final String text;
  final bool fromUser;
  final bool note;
  _Msg(this.text, {this.fromUser = false, this.note = false});
}

class PetScreen extends StatefulWidget {
  final String app;
  final int minutes;
  const PetScreen({super.key, required this.app, required this.minutes});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  List<MapEntry<String, String>> _options = [];
  Completer<String>? _pending;
  String _full = '';
  String _shown = '';
  bool _loading = true;
  bool _typing = false;
  String? _task;
  String? _plan; // saved plan (action id) for this app, if any
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ---------- the first message (typed out, from the AI) ----------

  Future<void> _load() async {
    _plan = await Store.planFor(widget.app);
    _task = await Store.nextTask();
    try {
      final lang = await effectiveLanguage();
      final l = lookupAppLocalizations(Locale(lang));
      final all = await PetMemory.buildBullets(l, currentApp: widget.app);
      final history = all.isEmpty ? <String>[] : [(all..shuffle()).first];
      _full = await fetchRoast(
        app: widget.app,
        minutes: widget.minutes,
        task: _task,
        history: history,
        lang: lang,
      );
    } catch (_) {
      if (!mounted) return;
      _full = AppLocalizations.of(context)!.petOffline;
    }
    if (!mounted) return;
    setState(() => _loading = false);
    _timer = Timer.periodic(const Duration(milliseconds: 30), (t) {
      if (_shown.length >= _full.length) {
        t.cancel();
        _converse();
        return;
      }
      setState(() => _shown = _full.substring(0, _shown.length + 1));
    });
  }

  // ---------- small chat helpers ----------

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Tomarin says something, after a short "..." pause.
  Future<void> _say(String text) async {
    if (!mounted) return;
    setState(() => _typing = true);
    _scrollDown();
    final ms = (500 + text.length * 25).clamp(600, 1500).toInt();
    await Future.delayed(Duration(milliseconds: ms));
    if (!mounted) return;
    setState(() {
      _typing = false;
      _msgs.add(_Msg(text));
    });
    _scrollDown();
  }

  /// A small grey note (bond points and so on), not a speech bubble.
  void _note(String text) {
    if (!mounted) return;
    setState(() => _msgs.add(_Msg(text, note: true)));
    _scrollDown();
  }

  /// Shows tap-to-answer choices and waits for the user to pick one.
  Future<String> _ask(List<MapEntry<String, String>> options) {
    final c = Completer<String>();
    _pending = c;
    if (mounted) {
      setState(() => _options = options);
      _scrollDown();
    }
    return c.future;
  }

  void _pick(MapEntry<String, String> o) {
    setState(() {
      _msgs.add(_Msg(o.value, fromUser: true));
      _options = [];
    });
    _scrollDown();
    _pending?.complete(o.key);
  }

  // ---------- the conversation ----------

  Future<void> _converse() async {
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;

    // 1. The nudge just asked how they are. They answer.
    final reason = await _ask([
      for (final id in checkinReasons) MapEntry(id, reasonLabel(l, id)),
      MapEntry('skip', l.ciSkip),
    ]);
    if (reason == 'skip') {
      await _say(l.ciSkipReply);
      return;
    }

    // 2. Acknowledge it once, honestly.
    await Store.addCheckin(widget.app, reason);
    final isNew = await Store.earnTitle('honest');
    final bond = await Bond.addCheckin();
    await _say(reasonReply(l, reason));
    if (bond.gained > 0) _note(l.bondGainSmall(bond.gained));
    if (isNew) await _say(l.titleEarnedHonest);
    if (bond.leveledUp) await _say(l.bondUp);

    // 3. The task, at most once a day.
    final task = _task;
    if (task != null && !await Store.hardnessAskedToday()) {
      await Store.markHardnessAsked();
      final short = task.length > 24 ? '${task.substring(0, 24)}…' : task;
      await _say(l.hardAsk(short));
      final hard = await _ask([
        for (final id in hardIds) MapEntry(id, hardLabel(l, id)),
        MapEntry('skip', l.ciSkip),
      ]);
      if (hard == 'heavy') {
        // Sincere mode. Nothing is saved, scored or remembered here.
        await _say(l.sincere1);
        await _say(l.sincere2);
        await _say(l.sincere3);
        await _say(l.sincere4);
        return;
      }
      await _say(hard == 'skip' ? l.ciSkipReply : hardReply(l, hard));
    }

    // 4. One small plan.
    if (_plan != null) {
      await _say(l.planReminder(planSentence(l, widget.app, _plan!)));
      final go = await _ask([
        MapEntry('go', l.planPlay),
        MapEntry('skip', l.ciSkip),
      ]);
      await _say(go == 'go' ? l.planPlayReply : l.planLaterReply);
    } else {
      await _say(l.planAsk);
      final pick = await _ask([
        for (final id in planActions)
          if (id != 'tiny' || _task != null)
            MapEntry(id, planActionLabel(l, id)),
        MapEntry('skip', l.planSkip),
      ]);
      if (pick == 'skip') {
        await _say(l.planLaterReply);
      } else {
        await Store.savePlan(widget.app, pick);
        await _say(l.planSaved(planSentence(l, widget.app, pick)));
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  // ---------- UI ----------

  Widget _bubble(_Msg m) {
    if (m.note) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(
          child: Text(
            m.text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      );
    }
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: m.fromUser ? cs.primaryContainer : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(m.text, style: const TextStyle(fontSize: 17)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Placeholder bird. Real Tomarin art comes later.
            const Icon(Icons.flutter_dash, size: 72),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  children: [
                    _bubble(_Msg(_loading ? '...' : _shown)),
                    for (final m in _msgs) _bubble(m),
                    if (_typing) _bubble(_Msg('...')),
                  ],
                ),
              ),
            ),
            if (_options.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    for (final o in _options)
                      OutlinedButton(
                        onPressed: () => _pick(o),
                        child: Text(o.value),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.petBackToWork),
              ),
            ),
          ],
        ),
      ),
    );
  }
}