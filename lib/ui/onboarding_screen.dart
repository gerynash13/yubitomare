import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../tracker_config.dart';
import 'home_shell.dart';
import 'theme.dart';
import 'tomarin_ui.dart';

/// First-run flow: welcome, name, guarded apps, permissions.
/// When it finishes it saves the settings, starts the guard and opens the app.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('detox_pet/usage');
  static const _stepCount = 4;

  // Apps people most often want guarded. Only the installed ones are shown on top.
  static const _suggested = {
    'com.google.android.youtube',
    'com.twitter.android',
    'com.instagram.android',
    'com.instagram.barcelona',
    'com.zhiliaoapp.musically',
    'com.ss.android.ugc.trill',
    'com.facebook.katana',
    'com.reddit.frontpage',
    'com.netflix.mediaclient',
    'tv.twitch.android.app',
    'com.snapchat.android',
    'com.pinterest',
  };

  int _step = 0;

  // name step
  final _nameCtl = TextEditingController();
  String _suffix = 'san';

  // apps step
  TrackerConfig _cfg = TrackerConfig();
  List<Map> _installed = [];
  bool _appsLoaded = false;
  String _query = '';

  // permissions step
  bool _usage = false;
  bool _overlay = false;
  bool _notif = false;
  bool _xiaomi = false;
  bool? _popupCheck; // null: this phone cannot tell us
  bool _popupConfirmed = false; // the user says they turned it on
  bool _notifAsked = false;
  bool _finishing = false;

  bool get _popupOk => !_xiaomi || _popupCheck == true || _popupConfirmed;
  bool get _requiredOk => _usage && _overlay && _popupOk;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameCtl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from a settings page: check the permissions again.
    if (state == AppLifecycleState.resumed) _refreshPerms();
  }

  Future<void> _init() async {
    final cfg = await TrackerConfig.load();
    final list = await _channel.invokeListMethod<Map>('getInstalledApps');
    if (!mounted) return;
    setState(() {
      _cfg = cfg;
      _nameCtl.text = cfg.name;
      _suffix = cfg.suffix;
      _installed = list ?? [];
      _appsLoaded = true;
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
      _popupCheck = popup;
    });
  }

  // ---------- saving ----------

  Future<void> _saveName() async {
    _cfg.name = _nameCtl.text.trim();
    _cfg.suffix = _suffix;
    await _cfg.save();
  }

  Future<void> _toggleApp(String pkg, String name, bool on) async {
    setState(() {
      if (on) {
        _cfg.apps[pkg] = name;
      } else {
        _cfg.apps.remove(pkg);
      }
    });
    await _cfg.save();
  }

  Future<void> _next() async {
    if (_step == 1) await _saveName();
    if (_step < _stepCount - 1) {
      setState(() => _step++);
      if (_step == _stepCount - 1) _refreshPerms();
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await _saveName();
    await _channel.invokeMethod('startTracker');
    final p = await SharedPreferences.getInstance();
    await p.setBool('onboarded', true);
    // Give the service a moment to write its "running" flag before Today reads it.
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  Future<void> _askNotif() async {
    if (_notifAsked) {
      await _channel.invokeMethod('openNotificationSettings');
    } else {
      setState(() => _notifAsked = true);
      await _channel.invokeMethod('requestNotificationPermission');
      await Future.delayed(const Duration(milliseconds: 1200));
      _refreshPerms();
    }
  }

  String _displayName(AppLocalizations l) {
    final n = _nameCtl.text.trim();
    if (n.isEmpty) return '';
    // Suffixes only exist in Japanese.
    if (Localizations.localeOf(context).languageCode != 'ja') return n;
    final s = switch (_suffix) {
      'san' => l.suffixSan,
      'kun' => l.suffixKun,
      'chan' => l.suffixChan,
      _ => '',
    };
    return '$n$s';
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: _dots(),
            ),
            Expanded(
              child: switch (_step) {
                0 => _welcome(l),
                1 => _nameStep(l),
                2 => _appsStep(l),
                _ => _permStep(l),
              },
            ),
            _footer(l),
          ],
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _stepCount; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _step ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= _step ? T.vermilion : T.line,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }

  Widget _footer(AppLocalizations l) {
    final last = _step == _stepCount - 1;
    final bool canNext;
    String? hint;
    if (_step == 2) {
      canNext = _cfg.apps.isNotEmpty;
      hint = canNext ? l.onbAppsPicked(_cfg.apps.length) : l.onbAppsNeedOne;
    } else if (last) {
      canNext = _requiredOk && !_finishing;
      if (!_requiredOk) hint = l.onbFinishNeed;
    } else {
      canNext = true;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                hint,
                textAlign: TextAlign.center,
                style: T.body(12, color: T.inkSoft, weight: FontWeight.w700),
              ),
            ),
          Row(
            children: [
              if (_step > 0)
                TextButton(
                  onPressed: _finishing ? null : () => setState(() => _step--),
                  child: Text(l.onbBack, style: T.body(15, weight: FontWeight.w700)),
                ),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: canNext ? _next : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: T.persimmon,
                      foregroundColor: T.ink,
                      disabledBackgroundColor: T.persimmon.withValues(alpha: 0.35),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      last ? l.onbStart : l.onbNext,
                      style: T.shout(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- step 1: welcome ----------

  Widget _welcome(AppLocalizations l) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          const TomarinSprite(Pose.landing, height: 190),
          const SizedBox(height: 12),
          Text(l.onbWelcomeTitle, textAlign: TextAlign.center, style: T.shout(26)),
          const SizedBox(height: 8),
          Text(
            l.onbWelcomeBody,
            textAlign: TextAlign.center,
            style: T.body(16, color: T.inkSoft, weight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          PaperCard(
            tape: true,
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
            child: Column(
              children: [
                _bullet(Icons.touch_app_outlined, l.onbBullet1),
                _bullet(Icons.handshake_outlined, l.onbBullet2),
                _bullet(Icons.hourglass_empty, l.onbBullet3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: T.vermilion),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: T.body(15, weight: FontWeight.w700))),
        ],
      ),
    );
  }

  // ---------- step 2: name ----------

  Widget _nameStep(AppLocalizations l) {
    final shown = _displayName(l);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          const TomarinSprite(Pose.delighted, height: 130),
          const SizedBox(height: 12),
          Text(l.callMeTitle, textAlign: TextAlign.center, style: T.shout(22)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: T.paperLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: T.line),
            ),
            child: TextField(
              controller: _nameCtl,
              style: T.body(17, weight: FontWeight.w700),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l.callMeHint,
                border: InputBorder.none,
              ),
            ),
          ),
          if (Localizations.localeOf(context).languageCode == 'ja') ...[
            const SizedBox(height: 14),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'san', label: Text(l.suffixSan)),
                ButtonSegment(value: 'kun', label: Text(l.suffixKun)),
                ButtonSegment(value: 'chan', label: Text(l.suffixChan)),
                ButtonSegment(value: 'none', label: Text(l.suffixNone)),
              ],
              selected: {_suffix},
              onSelectionChanged: (s) => setState(() => _suffix = s.first),
            ),
          const SizedBox(height: 18),
          if (shown.isNotEmpty)
            Text(
              l.onbHello(shown),
              textAlign: TextAlign.center,
              style: T.note(20, color: T.vermilion),
            ),
          const SizedBox(height: 8),
          Text(
            l.onbNameHelp,
            textAlign: TextAlign.center,
            style: T.body(12, color: T.inkSoft),
          ),
        ],
      ],),
    );
  }

  // ---------- step 3: guarded apps ----------

  Widget _appsStep(AppLocalizations l) {
    final matching = _installed
        .where((a) => (a['name'] as String).toLowerCase().contains(_query))
        .toList();
    final suggested =
        matching.where((a) => _suggested.contains(a['pkg'])).toList();
    final others =
        matching.where((a) => !_suggested.contains(a['pkg'])).toList();

    Widget row(Map a) {
      final pkg = a['pkg'] as String;
      final name = a['name'] as String;
      return SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(name, style: T.body(16, weight: FontWeight.w700)),
        value: _cfg.apps.containsKey(pkg),
        onChanged: (on) => _toggleApp(pkg, name, on),
      );
    }

    Widget header(String text) => Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 2),
          child: Text(
            text,
            style: T.body(13, color: T.vermilion, weight: FontWeight.w800),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.onbAppsTitle, style: T.shout(24)),
          const SizedBox(height: 6),
          Text(
            l.onbAppsBody,
            style: T.body(14, color: T.inkSoft, weight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: T.paperLow,
              borderRadius: BorderRadius.circular(16),
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
          Expanded(
            child: !_appsLoaded
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      if (suggested.isNotEmpty) ...[
                        header(l.onbAppsSuggested),
                        for (final a in suggested) row(a),
                      ],
                      header(l.onbAppsAll),
                      for (final a in others) row(a),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ---------- step 4: permissions ----------

  Widget _permStep(AppLocalizations l) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.onbPermTitle, style: T.shout(24)),
          const SizedBox(height: 6),
          Text(
            l.onbPermBody,
            style: T.body(14, color: T.inkSoft, weight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _permCard(
            l: l,
            title: l.onbPermUsage,
            why: l.onbPermUsageWhy,
            granted: _usage,
            required: true,
            actions: [
              FilledButton(
                onPressed: () => _channel.invokeMethod('openUsageSettings'),
                child: Text(l.onbPermOpen),
              ),
            ],
          ),
          _permCard(
            l: l,
            title: l.onbPermOverlay,
            why: l.onbPermOverlayWhy,
            granted: _overlay,
            required: true,
            actions: [
              FilledButton(
                onPressed: () => _channel.invokeMethod('openOverlaySettings'),
                child: Text(l.onbPermOpen),
              ),
            ],
          ),
          // Only Xiaomi phones have this extra switch.
          if (_xiaomi)
            _permCard(
              l: l,
              title: l.onbPermPopup,
              why: l.onbPermPopupWhy,
              hint: l.onbPermPopupHint,
              granted: _popupOk,
              required: true,
              actions: [
                FilledButton(
                  onPressed: () => _channel.invokeMethod('openBackgroundStartSettings'),
                  child: Text(l.onbPermOpen),
                ),
                TextButton(
                  onPressed: () => setState(() => _popupConfirmed = true),
                  child: Text(l.onbPermConfirm),
                ),
              ],
            ),
          _permCard(
            l: l,
            title: l.onbPermNotif,
            why: l.onbPermNotifWhy,
            granted: _notif,
            required: false,
            actions: [
              FilledButton(
                onPressed: _askNotif,
                child: Text(_notifAsked ? l.onbPermOpen : l.onbPermGrant),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: T.paperLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: T.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline, color: T.inkSoft),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.onbPrivacyTitle, style: T.body(14, weight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        l.onbPrivacyBody,
                        style: T.body(12, color: T.inkSoft, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, {required bool strong}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: strong ? T.paperHigh : T.paperLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: T.body(11, color: strong ? T.vermilion : T.inkSoft, weight: FontWeight.w800),
      ),
    );
  }

  Widget _permCard({
    required AppLocalizations l,
    required String title,
    required String why,
    required bool granted,
    required bool required,
    List<Widget> actions = const [],
    String? hint,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: granted ? T.paperLow : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: granted ? T.persimmonDeep : T.line,
          width: granted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                granted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: granted ? T.persimmonDeep : T.line,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: T.body(16, weight: FontWeight.w800)),
              ),
              _badge(required ? l.negRequired : l.onbRecommended, strong: required),
            ],
          ),
          const SizedBox(height: 6),
          Text(why, style: T.body(13, color: T.inkSoft, weight: FontWeight.w600)),
          if (granted) ...[
            const SizedBox(height: 6),
            Text(
              l.onbPermGranted,
              style: T.body(12, color: T.persimmonDeep, weight: FontWeight.w800),
            ),
          ] else ...[
            if (hint != null) ...[
              const SizedBox(height: 8),
              Text(hint, style: T.body(12, color: T.inkSoft)),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 4, children: actions),
            ],
          ],
        ],
      ),
    );
  }
}