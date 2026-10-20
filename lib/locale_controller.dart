import 'package:flutter/material.dart';
import 'tracker_config.dart';

/// The language the app should use. null means "follow the device".
final ValueNotifier<Locale?> appLocale = ValueNotifier(null);

Locale? localeFromCode(String code) => code == 'system' ? null : Locale(code);

/// 'ja' or 'en': what the user's setting (or, for "System", their phone) resolves to.
Future<String> effectiveLanguage() async {
  final cfg = await TrackerConfig.load();
  final code = cfg.language == 'system'
      ? WidgetsBinding.instance.platformDispatcher.locale.languageCode
      : cfg.language;
  return code == 'ja' ? 'ja' : 'en';
}