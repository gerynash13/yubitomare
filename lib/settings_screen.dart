import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tracker_config.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _channel = MethodChannel('detox_pet/usage');
  TrackerConfig _config = TrackerConfig();
  List<Map> _installed = [];
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cfg = await TrackerConfig.load();
    final list = await _channel.invokeListMethod<Map>('getInstalledApps');
    setState(() {
      _config = cfg;
      _installed = list ?? [];
      _loading = false;
    });
  }

  Future<void> _toggleApp(String pkg, String name, bool on) async {
    setState(() {
      if (on) {
        _config.apps[pkg] = name;
      } else {
        _config.apps.remove(pkg);
      }
    });
    await _config.save();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final shown = _installed
        .where((a) => (a['name'] as String).toLowerCase().contains(_query))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.languageTitle, style: Theme.of(context).textTheme.titleMedium),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'system', label: Text(l.languageSystem)),
                      const ButtonSegment(value: 'en', label: Text('English')),
                      const ButtonSegment(value: 'ja', label: Text('日本語')),
                    ],
                    selected: {_config.language},
                    onSelectionChanged: (s) async {
                      setState(() => _config.language = s.first);
                      appLocale.value = localeFromCode(s.first);
                      await _config.save();
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(l.alertAfter(_config.thresholdMinutes),
                      style: Theme.of(context).textTheme.titleMedium),
                  Slider(
                    min: 1,
                    max: 60,
                    divisions: 59,
                    value: _config.thresholdMinutes.toDouble(),
                    label: l.minutesShort(_config.thresholdMinutes),
                    onChanged: (v) =>
                        setState(() => _config.thresholdMinutes = v.round()),
                    onChangeEnd: (_) => _config.save(),
                  ),
                  Text(l.testModeNote, style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 16),
                  Text(l.guardedApps(_config.apps.length),
                      style: Theme.of(context).textTheme.titleMedium),
                  TextField(
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search), hintText: l.searchApps),
                    onChanged: (v) =>
                        setState(() => _query = v.toLowerCase().trim()),
                  ),
                  Expanded(
                    child: ListView(
                      children: shown.map((a) {
                        final pkg = a['pkg'] as String;
                        final name = a['name'] as String;
                        return SwitchListTile(
                          title: Text(name),
                          value: _config.apps.containsKey(pkg),
                          onChanged: (on) => _toggleApp(pkg, name, on),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}