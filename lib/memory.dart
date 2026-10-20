import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'storage.dart';
import 'checkin.dart';

class Intervention {
  final DateTime time;
  final String app;
  final int minutes;
  Intervention(this.time, this.app, this.minutes);
}

class PetMemory {
  static Future<List<Intervention>> loadInterventions() async {
    final p = await SharedPreferences.getInstance();
    await p.reload(); // pick up entries written by the Kotlin service
    final raw = p.getString('interventions');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Intervention(
              DateTime.fromMillisecondsSinceEpoch((e['t'] as num).toInt()),
              e['app'] as String,
              (e['min'] as num).toInt(),
            ))
        .toList();
  }

  /// A few short facts about recent habits, written in the language of [l].
  static Future<List<String>> buildBullets(AppLocalizations l, {String? currentApp}) async {
    final all = await loadInterventions();
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = all.where((i) => i.time.isAfter(cutoff)).toList();
    final bullets = <String>[];
    if (recent.isEmpty) return bullets;

    bullets.add(l.memCaught(recent.length));

    final byApp = <String, int>{};
    for (final i in recent) {
      byApp[i.app] = (byApp[i.app] ?? 0) + 1;
    }
    final topApp = byApp.entries.reduce((a, b) => a.value >= b.value ? a : b);
    if (currentApp == null || topApp.key == currentApp) {
      bullets.add(l.memWeakness(topApp.key, topApp.value));
    }

    final byHour = <int, int>{};
    for (final i in recent) {
      byHour[i.time.hour] = (byHour[i.time.hour] ?? 0) + 1;
    }
    final peak = byHour.entries.reduce((a, b) => a.value >= b.value ? a : b);
    bullets.add(l.memPeak(peak.key));

    final now = DateTime.now();
    final today = recent
        .where((i) =>
            i.time.year == now.year &&
            i.time.month == now.month &&
            i.time.day == now.day)
        .length;
    if (today > 1) bullets.add(l.memToday(today));

    final checkins = await Store.loadCheckins();
    final recentCheckins = checkins
        .where((c) => DateTime.fromMillisecondsSinceEpoch(c['t'] as int)
            .isAfter(cutoff))
        .toList();
    if (recentCheckins.isNotEmpty) {
      final counts = <String, int>{};
      for (final c in recentCheckins) {
        final r = c['reason'] as String;
        counts[r] = (counts[r] ?? 0) + 1;
      }
      final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
      bullets.add(l.memReason(reasonLabel(l, top.key)));
    }

    final tasks = await Store.loadTasks();
    if (tasks.isNotEmpty) {
      final done = tasks.where((t) => t.done).length;
      bullets.add(l.memTasks(done, tasks.length));
    }
    return bullets;
  }
}