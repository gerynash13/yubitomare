import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'roast_api.dart';
import 'pet_screen.dart';
import 'tasks_screen.dart';
import 'settings_screen.dart';
import 'memory.dart';
import 'l10n/app_localizations.dart';
import 'tracker_config.dart';
import 'locale_controller.dart';
import 'bond.dart';
import 'focus_screen.dart';

final navKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cfg = await TrackerConfig.load();
  appLocale.value = localeFromCode(cfg.language);
  runApp(const DetoxApp());
}

class DetoxApp extends StatelessWidget {
  const DetoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (_, locale, _) => MaterialApp(
        navigatorKey: navKey,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SpikePage(),
      ),
    );
  }
}

class SpikePage extends StatefulWidget {
  const SpikePage({super.key});
  @override
  State<SpikePage> createState() => _SpikePageState();
}

class _SpikePageState extends State<SpikePage> with WidgetsBindingObserver {
  static const _channel = MethodChannel('detox_pet/usage');
  bool _hasAccess = false;
  List<String> _events = [];

  final _taskCtl = TextEditingController(text: 'Math homework');
  String _roast = '';

  Future<void> _testRoast() async {
    setState(() => _roast = 'Thinking up something mean...');
    try {
      final r = await fetchRoast(
        app: 'Youtube', minutes: 15, task: _taskCtl.text);
        setState(() => _roast = r);
    } catch (e) {
      setState(() => _roast = 'Error: $e');
    }
  }

  Future<void> _checkAccess() async {
    final ok = await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;
    setState(() => _hasAccess = ok);
  }

  Future<void> _openSettings() => _channel.invokeMethod('openUsageSettings');
  Future<void> _allowNotifications() => _channel.invokeMethod('requestNotificationPermission');
  Future<void> _startTracker() => _channel.invokeMethod('startTracker');
  Future<void> _stopTracker() => _channel.invokeMethod('stopTracker');

  Future<void> _loadEvents() async {
    final list = await _channel.invokeListMethod<String>('getRecentEvents');
    setState(() => _events = list ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracker spike')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<BondState>(
              future: Bond.load(),
              builder: (context, snap) {
                final s = snap.data;
                if (s == null) return const SizedBox.shrink();
                final l = AppLocalizations.of(context)!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.bondLevelName(Bond.levelFor(s.points).toString()),
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(value: Bond.progress(s.points)),
                      const SizedBox(height: 4),
                      Text(l.bondPoints(s.points)),
                    ],
                  ),
                );
              },
            ),
            Text('Usage access: ${_hasAccess ? "GRANTED" : "not granted"}'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              ElevatedButton(onPressed: _openSettings, child: const Text('Open settings')),
              ElevatedButton(onPressed: _checkAccess, child: const Text('Check permission')),
              ElevatedButton(onPressed: _loadEvents, child: const Text('Load recent apps')),
              ElevatedButton(onPressed: _allowNotifications, child: const Text('Allow notifications')),
              ElevatedButton(onPressed: _startTracker, child: const Text('Start tracker')),
              ElevatedButton(onPressed: _stopTracker, child: const Text('Stop tracker')),
              ElevatedButton(
                onPressed: () => navKey.currentState?.push(
                  MaterialPageRoute(builder: (_) => const TasksScreen())), 
                  child: const Text('Tasks & XP'),),
              ElevatedButton(
                onPressed: () => navKey.currentState?.push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen())), 
                  child: const Text('Settings'),),
              ElevatedButton(onPressed: _showMemory, child: const Text('Pet memory'),),
              ElevatedButton(
                onPressed: () async {
                  await navKey.currentState?.push(
                      MaterialPageRoute(builder: (_) => const FocusScreen()));
                  if (mounted) setState(() {});
                },
                child: const Text('Focus'),
              ),
            ]),
            TextField(
              controller: _taskCtl,
              decoration: const InputDecoration(labelText: 'Next task'),
            ),
            ElevatedButton(onPressed: _testRoast, child: const Text('Test roast')),
            Text(_roast),
            const Divider(),
            Expanded(
              child: ListView(
                children: _events.map((e) => Text(e)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPendingAlert();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _taskCtl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      _checkPendingAlert();
    }
  }

  Future<void> _checkPendingAlert() async {
    final alert =
        await _channel.invokeMapMethod<String, dynamic>('getPendingAlert');
    if (alert == null) return;
    await navKey.currentState?.push(MaterialPageRoute(
      builder: (_) => PetScreen(
        app: alert['app'] as String,
        minutes: (alert['minutes'] as num).toInt(),
      ),
    ));
    if (mounted) setState(() {});
  }

  Future<void> _showMemory() async {
    final l = AppLocalizations.of(context)!;
    final bullets = await PetMemory.buildBullets(l);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.memTitle),
        content: Text(bullets.isEmpty
            ? l.memNothing
            : bullets.map((b) => '- $b').join('\n')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}