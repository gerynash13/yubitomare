import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_nav.dart';
import '../l10n/app_localizations.dart';
import '../storage.dart';
import 'ai_line.dart';
import 'focus_start_screen.dart';
import 'intercept_screen.dart';
import 'record_screen.dart';
import 'theme.dart';
import 'today_screen.dart';

/// The main screen: three tabs (Today, Focus, Record).
///
/// It also listens for the intercept card: when TrackerService opens the app over a
/// guarded app, the request arrives here and the card is shown.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  static const _channel = MethodChannel('detox_pet/usage');
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPendingIntercept();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPendingIntercept();
  }

  Future<void> _checkPendingIntercept() async {
    final r = await _channel.invokeMapMethod<String, dynamic>('getPendingIntercept');
    if (r == null) return;
    final nav = navKey.currentState;
    if (nav == null) return;
    final app = r['app'] as String;
    final level = (r['level'] as num).toInt();

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
        level: level,
        total: (r['total'] as num).toInt(),
        locked: r['locked'] as bool,
        passOptions: (r['options'] as List).map((e) => (e as num).toInt()).toList(),
        onBack: () => answer('back', 0),
        onPass: (m, reason) => answer('pass', m, reason),
        onLeft: () => answer('left', 0),
        fetchLine: (shout) => fetchCardLine(app, level, shout),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // A new page object per tab, so each tab loads fresh data when it is opened.
    final pages = <Widget>[
      TodayScreen(onStartFocus: () => setState(() => _index = 1)),
      const FocusStartScreen(),
      const RecordScreen(),
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: T.paper,
        indicatorColor: T.vermilionBright,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today, color: Colors.white),
            label: l.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.hourglass_empty),
            selectedIcon: const Icon(Icons.hourglass_empty, color: Colors.white),
            label: l.navFocus,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book, color: Colors.white),
            label: l.navRecord,
          ),
        ],
      ),
    );
  }
}