import 'dart:async';
import 'package:flutter/material.dart';
import 'checkin.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'memory.dart';
import 'roast_api.dart';
import 'storage.dart';
import 'bond.dart';

class PetScreen extends StatefulWidget {
  final String app;
  final int minutes;
  const PetScreen({super.key, required this.app, required this.minutes});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  String _full = '';
  String _shown = '';
  bool _loading = true;
  bool _typingDone = false;
  String? _answer; // a reason id, or 'skip'
  bool _newTitle = false;
  bool _levelUp = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final lang = await effectiveLanguage();
      final l = lookupAppLocalizations(Locale(lang));
      final task = await Store.nextTask();
      final all = await PetMemory.buildBullets(l, currentApp: widget.app);
      final history = all.isEmpty ? <String>[] : [(all..shuffle()).first];
      _full = await fetchRoast(
        app: widget.app,
        minutes: widget.minutes,
        task: task,
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
        setState(() => _typingDone = true);
        return;
      }
      setState(() => _shown = _full.substring(0, _shown.length + 1));
    });
  }

  Future<void> _answerWith(String reason) async {
    if (reason == 'skip') {
      setState(() => _answer = 'skip');
      return;
    }
    await Store.addCheckin(widget.app, reason);
    final isNew = await Store.earnTitle('honest');
    final bond = await Bond.addCheckin();
    if (!mounted) return;
    setState(() {
      _answer = reason;
      _newTitle = isNew;
      _levelUp = bond.leveledUp;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _bubble(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              _bubble(_loading ? '...' : _shown),
              const SizedBox(height: 24),
              // Placeholder bird. Real Tomarin art comes later.
              const Icon(Icons.flutter_dash, size: 120),
              const SizedBox(height: 24),
              if (_typingDone && _answer == null) ...[
                _bubble(l.ciAsk),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final id in checkinReasons)
                      OutlinedButton(
                        onPressed: () => _answerWith(id),
                        child: Text(reasonLabel(l, id)),
                      ),
                  ],
                ),
                TextButton(
                  onPressed: () => _answerWith('skip'),
                  child: Text(l.ciSkip),
                ),
              ],
              if (_answer != null && _answer != 'skip') ...[
                _bubble('${reasonReply(l, _answer!)}\n${l.ciThanks}'),
                if (_newTitle) ...[
                  const SizedBox(height: 12),
                  _bubble(l.titleEarnedHonest),
                ],
                if (_levelUp) ...[
                  const SizedBox(height: 12),
                  _bubble(l.bondUp),
                ],
              ],
              if (_answer == 'skip') _bubble(l.ciSkipReply),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.petBackToWork),
              ),
            ],
          ),
        ),
      ),
    );
  }
}