import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// One entry per focus session: when, how long, what for, and what the user wrote afterwards.
class FocusLog {
  static const _key = 'focus_logs';

  static Future<List<Map<String, dynamic>>> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> _save(List<Map<String, dynamic>> list) async {
    final p = await SharedPreferences.getInstance();
    final trimmed = list.length > 200 ? list.sublist(list.length - 200) : list;
    await p.setString(_key, jsonEncode(trimmed));
  }

  /// [minutes] is how long the session lasted, [credited] is the part Tomarin could confirm.
  static Future<void> add({
    required int minutes,
    required int credited,
    String goal = '',
  }) async {
    final list = await load();
    list.add({
      't': DateTime.now().millisecondsSinceEpoch,
      'minutes': minutes,
      'credited': credited,
      'goal': goal,
      'text': '',
      'progress': '',
    });
    await _save(list);
  }

  /// Adds what the user wrote to the newest entry. progress: none, little, fair or great.
  static Future<void> updateLast({
    required String text,
    required String progress,
  }) async {
    final list = await load();
    if (list.isEmpty) return;
    list.last['text'] = text;
    list.last['progress'] = progress;
    await _save(list);
  }
}