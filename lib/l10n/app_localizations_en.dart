// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tasksTitle => 'Tasks & XP';

  @override
  String get addTaskLabel => 'Add a task';

  @override
  String xpValue(int xp) {
    return '$xp XP';
  }

  @override
  String levelTitle(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      '0': 'Filthy Casual Scroller',
      '1': 'Focus Apprentice',
      '2': 'Master of Discipline',
      'other': 'The Chosen One',
    });
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String alertAfter(int minutes) {
    return 'Alert after $minutes min of scrolling';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get testModeNote => '1-2 min is test mode (checks every 10 seconds).';

  @override
  String guardedApps(int count) {
    return 'Apps the pet guards ($count)';
  }

  @override
  String get searchApps => 'Search apps';

  @override
  String get petBackToWork => 'Fine. Back to work.';

  @override
  String get petOffline =>
      'My brain is offline, but my eyes work fine. Put the phone down.';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get memTitle => 'What the pet remembers';

  @override
  String get memNothing => 'Nothing yet. Get caught scrolling first.';

  @override
  String memCaught(int count) {
    return 'Caught scrolling $count time(s) in the last 7 days.';
  }

  @override
  String memWeakness(String app, int count) {
    return 'Biggest weakness: $app ($count time(s)).';
  }

  @override
  String memPeak(int hour) {
    return 'Most vulnerable around $hour:00.';
  }

  @override
  String memToday(int count) {
    return 'Already caught $count times today.';
  }

  @override
  String memTasks(int done, int total) {
    return 'Tasks done: $done of $total.';
  }

  @override
  String get ciAsk =>
      'Oops, slipped? Tomarin will not blame you. What was going on?';

  @override
  String get ciTired => 'I was tired';

  @override
  String get ciBored => 'I was bored';

  @override
  String get ciAuto => 'I opened it without noticing';

  @override
  String get ciNotif => 'A notification came in';

  @override
  String get ciSkip => 'Not right now';

  @override
  String get ciReplyTired =>
      'You were tired, huh. Next time, Tomarin will perch on your screen first.';

  @override
  String get ciReplyBored =>
      'You were bored, huh. Next time, Tomarin will perch on your screen first and suggest something else.';

  @override
  String get ciReplyAuto =>
      'That happens. It is easy to open it without noticing. Next time, Tomarin will perch on your screen first.';

  @override
  String get ciReplyNotif =>
      'A notification pulled you in. Next time one comes, Tomarin will perch on your screen first.';

  @override
  String get ciThanks =>
      'Thank you for telling Tomarin. It is great that you can say it honestly.';

  @override
  String get ciSkipReply =>
      'Okay, no pressure. Tell Tomarin whenever you feel like it.';

  @override
  String get titleEarnedHonest =>
      'Title earned: Honest One! Tomarin is so proud.';

  @override
  String memReason(String reason) {
    return 'Usually slips because: $reason.';
  }
}
