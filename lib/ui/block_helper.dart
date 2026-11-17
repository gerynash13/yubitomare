import 'package:flutter/material.dart';
import '../checkin.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
import '../tracker_config.dart';
import '../unlock_api.dart';
import 'crisis_screen.dart';
import 'focus_session_screen.dart';
import 'theme.dart';
import 'tomarin_ui.dart';

/// "Where do I start?": Tomarin asks what feels hard about a task and suggests
/// one tiny first step. Opens from the long-press menu of an unfinished task.
Future<void> showBlockHelper(BuildContext context, String task) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: T.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _BlockHelperSheet(task: task),
  );
}

class _BlockHelperSheet extends StatefulWidget {
  final String task;
  const _BlockHelperSheet({required this.task});

  @override
  State<_BlockHelperSheet> createState() => _BlockHelperSheetState();
}

class _BlockHelperSheetState extends State<_BlockHelperSheet> {
  // The four "hard" reasons. "heavy" is not here: it has its own quiet button below.
  static final _reasons = [for (final id in hardIds) if (id != 'heavy') id];

  String? _hard; // the reason picked
  bool _loading = false;
  String? _reply;

  Future<void> _pick(String id) async {
    final l = AppLocalizations.of(context)!;
    final fallback = hardReply(l, id);
    setState(() {
      _hard = id;
      _loading = true;
      _reply = null;
    });
    String? ai;
    try {
      final cfg = await TrackerConfig.load();
      ai = await fetchUnblock(
        lang: await effectiveLanguage(),
        name: cfg.name,
        suffix: cfg.suffix,
        task: widget.task,
        hard: id,
      ).timeout(const Duration(seconds: 8));
    } catch (_) {
      ai = null;
    }
    // A newer pick may have replaced this one while we were waiting.
    if (!mounted || _hard != id) return;
    setState(() {
      _loading = false;
      _reply = (ai == null || ai.isEmpty) ? fallback : ai;
    });
  }

  void _startFocus() {
    final nav = Navigator.of(context);
    nav.pop();
    nav.push(
      MaterialPageRoute(builder: (_) => FocusSessionScreen(task: widget.task)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final short = widget.task.length > 24
        ? '${widget.task.substring(0, 24)}…'
        : widget.task;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TomarinSprite(Pose.neutral, height: 100),
            const SizedBox(height: 8),
            Text(
              l.blockAsk(short),
              textAlign: TextAlign.center,
              style: T.body(18, weight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final id in _reasons)
                  ChoiceChip(
                    label: Text(
                      hardLabel(l, id),
                      style: T.body(14, weight: FontWeight.w700),
                    ),
                    selected: _hard == id,
                    selectedColor: T.persimmon,
                    backgroundColor: T.paperLow,
                    onSelected: (_) => _pick(id),
                  ),
              ],
            ),
            if (_hard != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: T.paperLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: T.line),
                ),
                child: Text(
                  _loading ? '…' : (_reply ?? ''),
                  style: T.note(18, color: T.vermilion, height: 1.6),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _startFocus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: T.persimmon,
                    foregroundColor: T.ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(l.fsStart, style: T.body(16, weight: FontWeight.w800)),
                ),
              ),
            ],
            const SizedBox(height: 10),
            // Not a reason to start: a quiet way to say "this is bigger than the task".
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CrisisScreen()),
              ),
              style: TextButton.styleFrom(foregroundColor: T.inkSoft),
              child: Text(l.hardHeavy, style: T.body(14, weight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}