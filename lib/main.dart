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
import 'ui/theme.dart';
import 'ui/intercept_screen.dart';
import 'storage.dart';

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
        theme: buildTheme(),
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
  int _testLevel = 0;
  int _previewStep = 0;

  Future<void> _testRoast() async {
    final level = _testLevel; // 0-2 = passes used, 3 = locked
    _testLevel = (_testLevel + 1) % 4;
    setState(() => _roast = 'Level $level ...');
    try {
      final cfg = await TrackerConfig.load();
      final r = await fetchRoast(
        app: 'YouTube',
        minutes: 0,
        task: _taskCtl.text,
        lang: await effectiveLanguage(),
        name: cfg.name,
        suffix: cfg.suffix,
        level: level == 3 ? 2 : level,
        locked: level == 3,
      );
      setState(() => _roast = 'Level $level: $r');
    } catch (e) {
      setState(() => _roast = 'Error: $e');
    }
  }

  // Asks the AI for the line under the card headline. Returns null if it takes too long.
  Future<String?> _aiLine(String app, int level, String shout) async {
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

  void _previewIntercept() {
    final nav = navKey.currentState;
    if (nav == null) return;
    final step = _previewStep;
    _previewStep = (_previewStep + 1) % 4; // 0, 1, 2 = passes used, 3 = closed for today
    nav.push(MaterialPageRoute(
      builder: (_) => InterceptScreen(
        app: 'YouTube',
        level: step,
        total: 3,
        locked: step == 3,
        passOptions: const [5, 10, 15],
        onBack: () => nav.popUntil((r) => r.isFirst),
        onPass: (m, reason) => nav.popUntil((r) => r.isFirst),
        onLeft: () => nav.popUntil((r) => r.isFirst),
        fetchLine: (shout) => _aiLine('YouTube', step, shout)
      ),
    ));
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
                  child: const Text('Tasks'),),
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
              ElevatedButton(
                onPressed: () => _channel.invokeMethod('openOverlaySettings'),
                child: const Text('Overlay permission'),
              ),
              ElevatedButton(
                onPressed: _previewIntercept, child: const Text('Preview intercept')
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
    _checkPendingIntercept();
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
      _checkPendingIntercept();
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

  Future<void> _checkPendingIntercept() async {
    final r = await _channel.invokeMapMethod<String, dynamic>('getPendingIntercept');
    if (r == null) return;
    final nav = navKey.currentState;
    if (nav == null) return;

    final app = r['app'] as String;

    Future<void> answer(String action, int minutes, [String? reason]) async {
      if (reason != null) await Store.addCheckin(app, reason);
      await _channel.invokeMethod(
        'interceptDone',
        {'action': action, 'minutes': minutes, 'reason': reason},
      );
      nav.popUntil((route) => route.isFirst);
    }

    await nav.push(MaterialPageRoute(
      builder: (_) => InterceptScreen(
        app: app,
        level: (r['level'] as num).toInt(),
        total: (r['total'] as num).toInt(),
        locked: r['locked'] as bool,
        passOptions: (r['options'] as List).map((e) => (e as num).toInt()).toList(),
        onBack: () => answer('back', 0),
        onPass: (m, reason) => answer('pass', m, reason),
        onLeft: () => answer('left', 0),
        fetchLine: (shout) => _aiLine(app, (r['level'] as num).toInt(), shout)
      ),
    ));
  }
}