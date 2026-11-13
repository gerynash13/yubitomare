import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
import '../memory.dart';
import '../roast_api.dart';
import '../storage.dart';
import '../tracker_config.dart';

/// Asks the AI for the line under a card headline. Returns null if it takes too long
/// or fails, in which case the card keeps its fixed line.
Future<String?> fetchCardLine(String app, int level, String shout) async {
  try {
    final lang = await effectiveLanguage();
    final cfg = await TrackerConfig.load();
    final l = lookupAppLocalizations(Locale(lang));
    final bullets = await PetMemory.buildBullets(l, currentApp: app);
    final history = bullets.isEmpty ? <String>[] : [(bullets..shuffle()).first];

    // What the user said the last time they took a pass (within 3 hours).
    String? lastReason;
    String? lastApp;
    final checkins = await Store.loadCheckins();
    if (checkins.isNotEmpty) {
      final c = checkins.last;
      final age = DateTime.now().millisecondsSinceEpoch - (c['t'] as int);
      if (age < 3 * 60 * 60 * 1000) {
        lastReason = c['reason'] as String;
        lastApp = c['app'] as String;
      }
    }

    return await fetchRoast(
      app: app,
      minutes: 0,
      task: await Store.nextTask(),
      history: history,
      lang: lang,
      name: cfg.name,
      suffix: cfg.suffix,
      level: level,
      shout: shout,
      lastReason: lastReason,
      lastApp: lastApp,
    ).timeout(const Duration(seconds: 6));
  } catch (_) {
    return null;
  }
}