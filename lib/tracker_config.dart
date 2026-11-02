import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TrackerConfig {
  int thresholdMinutes;
  Map<String, String> apps; // package name -> friendly name
  String language; // 'system', 'en' or 'ja'
  String name; // what Tomarin calls the user (can be empty)
  String suffix; // 'san', 'kun', 'chan' or 'none'
  String strictness; // 'gentle', 'normal' or 'firm'

  TrackerConfig({
    this.thresholdMinutes = 15,
    Map<String, String>? apps,
    this.language = 'system',
    this.name = '',
    this.suffix = 'san',
    this.strictness = 'normal',
  }) : apps = apps ?? {};

  static const _key = 'tracker_config';

  static Future<TrackerConfig> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null) return TrackerConfig();
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final apps = <String, String>{};
    for (final a in (j['apps'] as List? ?? [])) {
      apps[a['pkg'] as String] = a['name'] as String;
    }
    return TrackerConfig(
      thresholdMinutes: (j['thresholdMinutes'] as num?)?.toInt() ?? 15,
      apps: apps,
      language: (j['language'] as String?) ?? 'system',
      name: (j['name'] as String?) ?? '',
      suffix: (j['suffix'] as String?) ?? 'san',
      strictness: (j['strictness'] as String?) ?? 'normal',
    );
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _key,
      jsonEncode({
        'thresholdMinutes': thresholdMinutes,
        'language': language,
        'name': name,
        'suffix': suffix,
        'strictness': strictness,
        'apps': apps.entries
            .map((e) => {'pkg': e.key, 'name': e.value})
            .toList(),
      }),
    );
  }
}