import 'package:flutter/material.dart';
import 'app_nav.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'tracker_config.dart';
import 'ui/home_shell.dart';
import 'ui/theme.dart';

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
      builder: (context, locale, child) => MaterialApp(
        navigatorKey: navKey,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildTheme(),
        home: const HomeShell(),
      ),
    );
  }
}