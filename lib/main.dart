import 'package:flutter/material.dart';
import 'app_nav.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'tracker_config.dart';
import 'ui/home_shell.dart';
import 'ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cfg = await TrackerConfig.load();
  appLocale.value = localeFromCode(cfg.language);
  final prefs = await SharedPreferences.getInstance();
  final onboarded = prefs.getBool('onboarded') ?? false;
  runApp(DetoxApp(onboarded: onboarded));
}

class DetoxApp extends StatelessWidget {
  final bool onboarded;
  const DetoxApp({super.key, required this.onboarded});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocale,
      builder: (context, locale, child) => MaterialApp(
        navigatorKey: navKey,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(),
        home: onboarded ? const HomeShell() : const OnboardingScreen(),
      ),
    );
  }
}