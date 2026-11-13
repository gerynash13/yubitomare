import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_nav.dart';
import 'l10n/app_localizations.dart';
import 'memory.dart';
import 'roast_api.dart';
import 'settings_screen.dart';
import 'tasks_screen.dart';
import 'tracker_config.dart';
import 'locale_controller.dart';
import 'ui/ai_line.dart';
import 'ui/intercept_screen.dart';

/// Developer page: permissions, tracker on/off and test buttons.
/// Open it from the Today tab by long-pressing the logo.
class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  static const _channel = MethodChannel('detox_pet/usage');
  bool _hasAccess = false;
  List<String> _events = [];
  final _taskCtl = TextEditingController(text: 'Math homework');
  String _roast = '';
  int _testLevel = 0;
  int _previewStep = 0;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  @override
  void dispose() {
    _taskCtl.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    final ok = await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;
    if (mounted) setState(() => _hasAccess = ok);
  }

  Future<void> _loadEvents() async {
    final list = await _channel.invokeListMethod<String>('getRecentEvents');
    if (mounted) setState(() => _events = list ?? []);
  }

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

  void _previewIntercept() {
    final nav = navKey.currentState;
    if (nav == null) return;
    final thisPage = ModalRoute.of(context)!;
    final step = _previewStep;
    _previewStep = (_previewStep + 1) % 4; // 0, 1, 2 = passes used, 3 = closed for today
    // Close the card (and the negotiation screen on top of it), back to this page.
    void backHere() => nav.popUntil((route) => route == thisPage);
    nav.push(MaterialPageRoute(
      builder: (_) => InterceptScreen(
        app: 'YouTube',
        level: step,
        total: 3,
        locked: step == 3,
        passOptions: const [5, 10, 15],
        onBack: backHere,
        onPass: (m, reason) => backHere(),
        onLeft: backHere,
        fetchLine: (shout) => fetchCardLine('YouTube', step, shout),
      ),
    ));
  }

  Future<void> _showMemory() async {
    final l = AppLocalizations.of(context)!;
    final bullets = await PetMemory.buildBullets(l);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.memTitle),
        content: Text(bullets.isEmpty ? l.memNothing : bullets.map((b) => '- $b').join('\n')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer page')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usage access: ${_hasAccess ? "GRANTED" : "not granted"}'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              ElevatedButton(
                onPressed: () => _channel.invokeMethod('openUsageSettings'),
                child: const Text('Usage settings'),
              ),
              ElevatedButton(
                onPressed: () => _channel.invokeMethod('openOverlaySettings'),
                child: const Text('Overlay permission'),
              ),
              ElevatedButton(onPressed: _checkAccess, child: const Text('Check permission')),
              ElevatedButton(onPressed: _loadEvents, child: const Text('Load recent apps')),
              ElevatedButton(
                onPressed: () => _channel.invokeMethod('requestNotificationPermission'),
                child: const Text('Allow notifications'),
              ),
              ElevatedButton(
                onPressed: () => _channel.invokeMethod('startTracker'),
                child: const Text('Start tracker'),
              ),
              ElevatedButton(
                onPressed: () => _channel.invokeMethod('stopTracker'),
                child: const Text('Stop tracker'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const TasksScreen())),
                child: const Text('Old tasks'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                child: const Text('Settings'),
              ),
              ElevatedButton(onPressed: _showMemory, child: const Text('Pet memory')),
              ElevatedButton(onPressed: _previewIntercept, child: const Text('Preview intercept')),
            ]),
            TextField(
              controller: _taskCtl,
              decoration: const InputDecoration(labelText: 'Next task'),
            ),
            ElevatedButton(onPressed: _testRoast, child: const Text('Test roast')),
            Text(_roast),
            const Divider(),
            Expanded(child: ListView(children: _events.map((e) => Text(e)).toList())),
          ],
        ),
      ),
    );
  }
}