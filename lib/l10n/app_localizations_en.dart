// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tasksTitle => 'Tasks';

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
      '*Peck peck.* That has been a while. Is something up?';

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
      'I see, you were tired. Thank you for telling Tomarin.';

  @override
  String get ciReplyBored =>
      'You were bored. Tomarin appreciates you being honest.';

  @override
  String get ciReplyAuto =>
      'That happens, it is easy to open it without noticing. Thank you for telling Tomarin.';

  @override
  String get ciReplyNotif =>
      'A notification pulled you in. Tomarin wishes it had noticed sooner.';

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

  @override
  String bondLevelName(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      '0': 'Nice to meet you',
      '1': 'Getting close',
      '2': 'Friends',
      '3': 'Best friends',
      'other': 'Together forever',
    });
    return '$_temp0';
  }

  @override
  String bondPoints(int points) {
    return 'Bond $points';
  }

  @override
  String get bondUp => 'Tomarin feels like it got closer to you.';

  @override
  String get focusHint => 'Press and hold to finish';

  @override
  String focusElapsed(int minutes) {
    return '$minutes min';
  }

  @override
  String focusDone(int minutes) {
    return 'Thank you for staying with Tomarin for $minutes min.';
  }

  @override
  String focusBondGain(int points) {
    return 'Bond +$points';
  }

  @override
  String get focusCapped => 'That is plenty for today. Rest well, okay?';

  @override
  String get focusShort => 'Come back anytime. Tomarin will be here.';

  @override
  String get focusClose => 'Close';

  @override
  String bondGainSmall(int points) {
    return '+$points Bond';
  }

  @override
  String get planAsk =>
      'Last thing: want to decide one small thing to do next time the urge hits?';

  @override
  String get planSkip => 'Maybe later';

  @override
  String get planActCharge => 'put my phone on the charger and stretch';

  @override
  String get planActWater => 'drink some water';

  @override
  String get planActFocus => 'open the focus screen';

  @override
  String get planActTiny => 'do the first tiny step of my task for 2 minutes';

  @override
  String planSentence(String app, String action) {
    return 'If I feel like opening $app, then I will $action.';
  }

  @override
  String planSaved(String plan) {
    return 'It is settled. $plan Tomarin will remember it too.';
  }

  @override
  String planReminder(String plan) {
    return 'Oh, and you already made a plan. $plan';
  }

  @override
  String tasksDone(int done, int total) {
    return '$done of $total done';
  }

  @override
  String hardAsk(String task) {
    return 'By the way, about $task: what feels hardest about it?';
  }

  @override
  String get hardBig => 'I feel like it\'s too big of a task';

  @override
  String get hardStart => 'I do not know where to start';

  @override
  String get hardAfraid => 'I am afraid of doing it badly';

  @override
  String get hardBoring => 'It is boring';

  @override
  String get hardHeavy => 'I have felt heavy for a while';

  @override
  String get hardReplyBig =>
      'Big things make anyone freeze. Even just opening the file or notebook counts as a start.';

  @override
  String get hardReplyStart =>
      'Not knowing where to start is hard. How about writing one line about what comes first?';

  @override
  String get hardReplyAfraid =>
      'Your first try can be rough. Want to do it messily for just 2 minutes?';

  @override
  String get hardReplyBoring =>
      'Boring tasks make hands stop. Try 2 minutes, then a glass of water as a reward.';

  @override
  String get planPlay => 'I will try it';

  @override
  String get planPlayReply => 'Okay, go for it. Tomarin will be waiting here.';

  @override
  String get planLaterReply => 'Okay, got it.';

  @override
  String get sincere1 => '...Hey, can I talk to you seriously for a moment?';

  @override
  String get sincere2 =>
      'If things have felt heavy for a long time, you do not have to carry it alone. Even a word to family, a friend, a teacher or someone you trust can help.';

  @override
  String get sincere3 =>
      'If it is hard to say out loud, there are free phone lines in Japan. Yorisoi Hotline (0120-279-338) is open 24 hours, and Inochi SOS (0120-061-338) is there for feelings like wanting to disappear.';

  @override
  String get sincere4 => 'Tomarin is right here.';
}
