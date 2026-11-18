import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'tracker_config.dart';
import 'ui/crisis_screen.dart';
import 'ui/theme.dart';

/// Everything is saved the moment it changes. There is no Save button.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('detox_pet/usage');

  // The pass lengths the intercept card can offer (see PASS_OPTIONS in TrackerService.kt).
  static const _passChoices = [5, 10, 15];

  final _nameCtl = TextEditingController();
  TrackerConfig _config = TrackerConfig();
  List<Map> _installed = [];
  String _query = '';
  bool _loading = true;

  bool _usage = false;
  bool _overlay = false;
  bool _notif = false;
  bool _xiaomi = false;
  bool? _popup; // null: this phone cannot tell us

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameCtl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from a system settings page: check the permissions again.
    if (state == AppLifecycleState.resumed) _refreshPerms();
  }

  Future<void> _load() async {
    final cfg = await TrackerConfig.load();
    final list = await _channel.invokeListMethod<Map>('getInstalledApps');
    if (!mounted) return;
    setState(() {
      _config = cfg;
      _nameCtl.text = cfg.name;
      _installed = list ?? [];
      _loading = false;
    });
    _refreshPerms();
  }

  Future<void> _refreshPerms() async {
    final usage = await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;
    final overlay = await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
    final notif = await _channel.invokeMethod<bool>('hasNotificationPermission') ?? false;
    final xiaomi = await _channel.invokeMethod<bool>('isXiaomi') ?? false;
    final popup = xiaomi
        ? await _channel.invokeMethod<bool>('hasBackgroundStartPermission')
        : null;
    if (!mounted) return;
    setState(() {
      _usage = usage;
      _overlay = overlay;
      _notif = notif;
      _xiaomi = xiaomi;
      _popup = popup;
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

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Name suffixes (さん, くん, ちゃん) only make sense in Japanese.
    final ja = Localizations.localeOf(context).languageCode == 'ja';

    return Scaffold(
      backgroundColor: T.paper,
      appBar: AppBar(
        title: Text(l.settingsTitle, style: T.shout(22)),
        backgroundColor: T.paper,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _nameSection(l, ja),
                _passSection(l),
                _languageSection(l),
                _permissionSection(l),
                _crisisCard(l),
                const SizedBox(height: 18),
                _appsSection(l),
              ],
            ),
    );
  }

  Widget _section(String title, Widget child, {String? help}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 6, height: 20, color: T.vermilion),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: T.shout(17))),
            ],
          ),
          if (help != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(help, style: T.body(12, color: T.inkSoft)),
            ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: T.line),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  // ---------- name ----------

  Widget _nameSection(AppLocalizations l, bool ja) {
    return _section(
      l.callMeTitle,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: T.paperLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: T.line),
            ),
            child: TextField(
              controller: _nameCtl,
              maxLength: 20,
              style: T.body(16, weight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: l.callMeHint,
                border: InputBorder.none,
                counterText: '',
              ),
              onChanged: (v) {
                _config.name = v;
                _config.save();
              },
            ),
          ),
          if (ja) ...[
            const SizedBox(height: 12),
            SegmentedButton<String>(
              style: T.segmentStyle,
              segments: [
                ButtonSegment(value: 'san', label: Text(l.suffixSan)),
                ButtonSegment(value: 'kun', label: Text(l.suffixKun)),
                ButtonSegment(value: 'chan', label: Text(l.suffixChan)),
                ButtonSegment(value: 'none', label: Text(l.suffixNone)),
              ],
              selected: {_config.suffix},
              onSelectionChanged: (s) async {
                setState(() => _config.suffix = s.first);
                await _config.save();
              },
            ),
          ],
        ],
      ),
    );
  }

  // ---------- longest extension ----------

  Widget _passSection(AppLocalizations l) {
    final current = _config.thresholdMinutes;
    return _section(
      l.setLongestPass,
      SegmentedButton<int>(
        style: T.segmentStyle,
        emptySelectionAllowed: true,
        segments: [
          for (final m in _passChoices)
            ButtonSegment(value: m, label: Text(l.minutesShort(m))),
        ],
        // An old test value (like 1 or 2 minutes) simply shows nothing selected.
        selected: _passChoices.contains(current) ? {current} : <int>{},
        onSelectionChanged: (s) async {
          if (s.isEmpty) return;
          setState(() => _config.thresholdMinutes = s.first);
          await _config.save();
        },
      ),
      help: l.setLongestPassHelp,
    );
  }

  // ---------- language ----------

  Widget _languageSection(AppLocalizations l) {
    return _section(
      l.languageTitle,
      SegmentedButton<String>(
        style: T.segmentStyle,
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
    );
  }

  // ---------- permissions ----------

  Widget _permRow(String title, bool? ok, String method, String openLabel) {
    final IconData icon;
    final Color color;
    if (ok == true) {
      icon = Icons.check_circle;
      color = T.persimmonDeep;
    } else if (ok == false) {
      icon = Icons.error_outline;
      color = T.vermilion;
    } else {
      icon = Icons.help_outline; // cannot tell on this phone
      color = T.inkSoft;
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: color),
      title: Text(title, style: T.body(15, weight: FontWeight.w700)),
      trailing: ok == true
          ? null
          : TextButton(
              onPressed: () => _channel.invokeMethod(method),
              child: Text(openLabel),
            ),
    );
  }

  Widget _permissionSection(AppLocalizations l) {
    return _section(
      l.setPermissions,
      Column(
        children: [
          _permRow(l.onbPermUsage, _usage, 'openUsageSettings', l.onbPermOpen),
          _permRow(l.onbPermOverlay, _overlay, 'openOverlaySettings', l.onbPermOpen),
          if (_xiaomi)
            _permRow(l.onbPermPopup, _popup, 'openBackgroundStartSettings', l.onbPermOpen),
          _permRow(l.onbPermNotif, _notif, 'openNotificationSettings', l.onbPermOpen),
        ],
      ),
    );
  }

  // ---------- hotlines ----------

  Widget _crisisCard(AppLocalizations l) {
    return Material(
      color: T.paperLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CrisisScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: T.line),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite_border, color: T.vermilion),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.crisisTitle, style: T.body(16, weight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      l.setCrisisSub,
                      style: T.body(12, color: T.inkSoft, weight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: T.inkSoft),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- guarded apps ----------

  Widget _appsSection(AppLocalizations l) {
    final shown = _installed
        .where((a) => (a['name'] as String).toLowerCase().contains(_query))
        .toList();
    return _section(
      l.guardedApps(_config.apps.length),
      Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: T.paperLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: T.line),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.toLowerCase().trim()),
              decoration: InputDecoration(
                icon: const Icon(Icons.search),
                hintText: l.searchApps,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 6),
          for (final a in shown)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                a['name'] as String,
                style: T.body(16, weight: FontWeight.w700),
              ),
              value: _config.apps.containsKey(a['pkg'] as String),
              onChanged: (on) => _toggleApp(a['pkg'] as String, a['name'] as String, on),
            ),
        ],
      ),
    );
  }
}