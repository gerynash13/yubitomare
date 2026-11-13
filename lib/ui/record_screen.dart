import 'package:flutter/material.dart';
import '../focus_log.dart';
import '../l10n/app_localizations.dart';
import 'theme.dart';
import 'tomarin_ui.dart';

/// First version of the Record tab: focus time this week and the latest notes.
/// The weak-hour chart comes later.
class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  List<Map<String, dynamic>> _logs = [];
  int _weekMinutes = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await FocusLog.load();
    final cutoff = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    final week = all.where((e) => (e['t'] as num) >= cutoff);
    final minutes = week.fold<int>(0, (sum, e) => sum + (e['credited'] as num).toInt());
    if (!mounted) return;
    setState(() {
      _logs = all.reversed.take(6).toList();
      _weekMinutes = minutes;
    });
  }

  String _emoji(String progress) => switch (progress) {
        'great' => '🌸',
        'fair' => '✨',
        'little' => '🌱',
        'none' => '☁️',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(l.recTitle, style: T.shout(24)),
        const SizedBox(height: 14),
        PaperCard(
          tape: true,
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
          child: Column(
            children: [
              Text(l.recHero, style: T.body(15, color: T.inkSoft, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                l.recTime(_weekMinutes ~/ 60, _weekMinutes % 60),
                style: T.shout(32, color: T.vermilion),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(l.recMemo, style: T.shout(19)),
        const SizedBox(height: 10),
        if (_logs.isEmpty)
          Column(
            children: [
              const TomarinSprite(Pose.sleepy, height: 120),
              const SizedBox(height: 8),
              Text(
                l.recEmpty,
                textAlign: TextAlign.center,
                style: T.body(14, color: T.inkSoft, weight: FontWeight.w600),
              ),
            ],
          ),
        for (final e in _logs) _entry(e),
      ],
    );
  }

  Widget _entry(Map<String, dynamic> e) {
    final t = DateTime.fromMillisecondsSinceEpoch((e['t'] as num).toInt());
    final stamp =
        '${t.month}/${t.day} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final text = (e['text'] as String?)?.isNotEmpty == true
        ? e['text'] as String
        : ((e['goal'] as String?) ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: T.paperMid,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(stamp, style: T.body(11, weight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${e['credited']}分  $text',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: T.body(14, weight: FontWeight.w600),
            ),
          ),
          Text(_emoji((e['progress'] as String?) ?? ''), style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}