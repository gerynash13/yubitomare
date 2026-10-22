import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BondState {
  int points;
  String day; // the date the daily counters belong to
  int focusToday; // focus minutes already counted today
  int checkinsToday;

  BondState({
    this.points = 0,
    this.day = '',
    this.focusToday = 0,
    this.checkinsToday = 0,
  });

  Map<String, dynamic> toJson() => {
        'points': points,
        'day': day,
        'focusToday': focusToday,
        'checkinsToday': checkinsToday,
      };

  factory BondState.fromJson(Map<String, dynamic> j) => BondState(
        points: (j['points'] as num?)?.toInt() ?? 0,
        day: (j['day'] as String?) ?? '',
        focusToday: (j['focusToday'] as num?)?.toInt() ?? 0,
        checkinsToday: (j['checkinsToday'] as num?)?.toInt() ?? 0,
      );
}

class BondResult {
  final int gained;
  final int oldLevel;
  final int newLevel;
  final bool capped;
  BondResult(this.gained, this.oldLevel, this.newLevel, this.capped);
  bool get leveledUp => newLevel > oldLevel;
}

class Bond {
  // Tune these freely.
  static const levelStarts = [0, 100, 300, 700, 1500];
  static const dailyFocusCapMinutes = 120;
  static const checkinPoints = 5;
  static const dailyCheckinCap = 3;
  static const _key = 'bond';

  static String _today() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$d';
  }

  static Future<BondState> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    final s = raw == null
        ? BondState()
        : BondState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    if (s.day != _today()) {
      s.day = _today();
      s.focusToday = 0;
      s.checkinsToday = 0;
    }
    return s;
  }

  static Future<void> _save(BondState s) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(s.toJson()));
  }

  static int levelFor(int points) {
    var level = 0;
    for (var i = 0; i < levelStarts.length; i++) {
      if (points >= levelStarts[i]) level = i;
    }
    return level;
  }

  /// 0.0 to 1.0 progress toward the next level (1.0 at the top level).
  static double progress(int points) {
    final level = levelFor(points);
    if (level >= levelStarts.length - 1) return 1.0;
    final from = levelStarts[level];
    final to = levelStarts[level + 1];
    return (points - from) / (to - from);
  }

  static Future<BondResult> addFocusMinutes(int minutes) async {
    final s = await load();
    final old = levelFor(s.points);
    final room = dailyFocusCapMinutes - s.focusToday;
    final cap = room < 0 ? 0 : room;
    final gained = minutes < cap ? minutes : cap;
    s.focusToday += gained;
    s.points += gained;
    await _save(s);
    return BondResult(gained, old, levelFor(s.points), minutes > gained);
  }

  static Future<BondResult> addCheckin() async {
    final s = await load();
    final old = levelFor(s.points);
    var gained = 0;
    if (s.checkinsToday < dailyCheckinCap) {
      gained = checkinPoints;
      s.checkinsToday += 1;
      s.points += gained;
    }
    await _save(s);
    return BondResult(gained, old, levelFor(s.points), gained == 0);
  }
}