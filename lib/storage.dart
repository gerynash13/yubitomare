import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  String text;
  bool done;
  Task(this.text, {this.done = false});

  Map<String, dynamic> toJson() => {'text': text, 'done': done};
  factory Task.fromJson(Map<String, dynamic> j) =>
      Task(j['text'] as String, done: j['done'] as bool);
}

class Store {
  static const _tasksKey = 'tasks';
  static const _xpKey = 'xp';
  static const xpPerTask = 20;

  static Future<List<Task>> loadTasks() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_tasksKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _tasksKey, jsonEncode(tasks.map((t) => t.toJson()).toList()));
  }

  static Future<int> loadXp() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_xpKey) ?? 0;
  }

  static Future<void> saveXp(int xp) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_xpKey, xp < 0 ? 0 : xp);
  }

  /// The first task that isn't done yet, or null.
  static Future<String?> nextTask() async {
    final tasks = await loadTasks();
    for (final t in tasks) {
      if (!t.done) return t.text;
    }
    return null;
  }

  static String titleFor(int xp) {
    if (xp >= 600) return 'The Chosen One';
    if (xp >= 300) return 'Master of Discipline';
    if (xp >= 100) return 'Focus Apprentice';
    return 'Filthy Casual Scroller';
  }

  static int levelFor(int xp) {
    if (xp >= 600) return 3;
    if (xp >= 300) return 2;
    if (xp >= 100) return 1;
    return 0;
  }

  static Future<List<Map<String, dynamic>>> loadCheckins() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('checkins');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> addCheckin(String app, String reason) async {
    final p = await SharedPreferences.getInstance();
    final list = await loadCheckins();
    list.add({
      't': DateTime.now().millisecondsSinceEpoch,
      'app': app,
      'reason': reason,
    });
    final trimmed = list.length > 200 ? list.sublist(list.length - 200) : list;
    await p.setString('checkins', jsonEncode(trimmed));
  }

  /// Returns true only the first time a title is earned
  static Future<bool> earnTitle(String id) async {
    final p = await SharedPreferences.getInstance();
    final titles = p.getStringList('earned_titles') ?? [];
    if (titles.contains(id)) return false;
    titles.add(id);
    await p.setStringList('earned_titles', titles);
    return true;
  }

  static Future<String?> planFor(String app) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('plans');
    if (raw == null) return null;
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return m[app] as String?;
  }

  static Future<void> savePlan(String app, String actionId) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('plans');
    final m = raw == null
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;
    m[app] = actionId;
    await p.setString('plans', jsonEncode(m));
  }
}