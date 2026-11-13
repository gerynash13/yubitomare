import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads the intercept log that TrackerService (Android) writes.
class InterceptLog {
  // Keep these two in sync with TrackerService.kt (DAILY_PASSES and DAY_STARTS_AT).
  static const dailyPasses = 3;
  static const dayStartsAt = 6;

  /// "Today" starts at 6:00 in the morning.
  static DateTime dayStart() {
    final n = DateTime.now();
    var start = DateTime(n.year, n.month, n.day, dayStartsAt);
    if (start.isAfter(n)) start = start.subtract(const Duration(days: 1));
    return start;
  }

  static Future<List<Map<String, dynamic>>> load() async {
    final p = await SharedPreferences.getInstance();
    await p.reload(); // pick up entries written by the Kotlin service
    final raw = p.getString('intercepts');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// How many passes were taken since 6:00 (shared by all guarded apps).
  static Future<int> passesToday() async {
    final start = dayStart().millisecondsSinceEpoch;
    final all = await load();
    return all
        .where((e) => e['outcome'] == 'pass' && (e['t'] as num) >= start)
        .length;
  }
}