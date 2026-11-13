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

  @override
  String get callMeTitle => 'What should Tomarin call you?';

  @override
  String get callMeHint => 'Your name';

  @override
  String get suffixSan => '-san';

  @override
  String get suffixKun => '-kun';

  @override
  String get suffixChan => '-chan';

  @override
  String get suffixNone => 'None';

  @override
  String get interceptShout0 => 'Peck.';

  @override
  String interceptSub0(String app) {
    return 'You just opened $app, right?';
  }

  @override
  String interceptShout1(String app) {
    return 'Hey, $app again?';
  }

  @override
  String get interceptSub1 => 'You were just on it!';

  @override
  String get interceptShout2 => 'What are you DOING?!';

  @override
  String get interceptSub2 =>
      'How many times do I have to say it? Go back now.';

  @override
  String get interceptBack => 'Go back';

  @override
  String interceptPass(int minutes) {
    return '$minutes more min';
  }

  @override
  String interceptTag(int used, int total) {
    return 'Extensions today $used/$total';
  }

  @override
  String get interceptStamp => 'DONE\nTODAY';

  @override
  String get interceptClosedTitle => 'That is it for today!';

  @override
  String interceptClosedBody(String app) {
    return '$app is closed until tomorrow. You have had enough for today, so rest well.';
  }

  @override
  String get interceptClosedUsed => 'Extensions today';

  @override
  String interceptClosedUsedValue(int used, int total) {
    return '$used/$total used up';
  }

  @override
  String get interceptClosedNext => 'Unlocks';

  @override
  String get interceptClosedAt => '6:00 AM';

  @override
  String get interceptClosedNote => 'I will be waiting on the perch.';

  @override
  String get interceptHome => 'Back to home';

  @override
  String negTag(int minutes) {
    return 'Excuse time · $minutes min negotiation';
  }

  @override
  String negQuestion(int minutes) {
    return '$minutes more minutes, huh... so, why do you want them?';
  }

  @override
  String negSub(int minutes) {
    return 'Tell me honestly and I will watch over you for $minutes minutes.';
  }

  @override
  String get negHmm => 'Hmm...';

  @override
  String get negStatusWaiting => 'Sizing you up: not convinced yet';

  @override
  String get negStatusDone => '...Oh, all right.';

  @override
  String get negReasonTitle => 'One honest reason';

  @override
  String get negRequired => 'Required';

  @override
  String get negLater => 'We will look back on it later';

  @override
  String get negSubTired => 'Needed a breather';

  @override
  String get negSubBored => 'Had nothing to do';

  @override
  String get negSubAuto => 'Tapped without thinking';

  @override
  String get negSubNotif => 'Only meant to reply';

  @override
  String negPromise(int minutes) {
    return '$minutes min only, I promise';
  }

  @override
  String get negPinky => 'Pinky promise';

  @override
  String get negBackOut => 'Actually, I will go back (close the screen)';

  @override
  String negFootnote(int minutes) {
    return '* After $minutes minutes I will land on the screen again.';
  }

  @override
  String get crisisTitle => 'When things are hard';

  @override
  String get crisisHotline1 => 'Yorisoi Hotline';

  @override
  String get crisisHotline2 => '#Inochi SOS';

  @override
  String get crisisFree24 => 'Free · 24 hours';

  @override
  String get crisisFree24Sos =>
      'Free · 24 hours (also when you feel like disappearing)';

  @override
  String get crisisCall => 'Call';

  @override
  String get crisisOk => 'I am okay for now';

  @override
  String get navToday => 'Today';

  @override
  String get navFocus => 'Focus';

  @override
  String get navRecord => 'Record';

  @override
  String get appTitle => 'Yubitomare';

  @override
  String statusRunning(int count) {
    return 'Watching ($count apps)';
  }

  @override
  String get statusPaused => 'Guard paused';

  @override
  String get statusPausedSub =>
      'The guard is paused, so nothing stops you from scrolling.';

  @override
  String get statusMissing => 'Permission missing';

  @override
  String get statusMissingSub =>
      'Tomarin cannot watch without a permission. Please check it.';

  @override
  String get statusResume => 'Resume';

  @override
  String get statusFix => 'Fix';

  @override
  String todayBond(int level, String name) {
    return 'Bond Lv.$level $name';
  }

  @override
  String get todayNagTitle => 'Did you really look at today?';

  @override
  String todayNag(String task) {
    return 'Start with $task. Put the phone down and get ready!';
  }

  @override
  String get todayNagEmpty =>
      'Nothing is planned yet. Pick one small thing for today.';

  @override
  String get todayTasksTitle => 'To-dos for today';

  @override
  String get todayAdd => 'Add';

  @override
  String get todayDoneStamp => 'DONE';

  @override
  String get todayStartFocus => 'Start focusing';

  @override
  String get todayStartFocusSub => 'Focus together with Tomarin';

  @override
  String get fsTitle => 'What will you do?';

  @override
  String get fsGoalHint => 'A one-line goal (optional)';

  @override
  String get fsStart => 'Focus with Tomarin';

  @override
  String get fsNote =>
      'The screen will go dark. Every 10 minutes or so Tomarin will call out, so answer it.';

  @override
  String get fsNoTasks => 'Add tasks on the Today tab, or just start.';

  @override
  String focusNow(String goal) {
    return 'Now: $goal';
  }

  @override
  String get focusUnit => 'min';

  @override
  String get focusWith => 'Focusing with Tomarin';

  @override
  String get checkTitle => 'Pi? Are you there?';

  @override
  String get checkHint => 'Tap to answer';

  @override
  String get sumTitle => 'Good work!';

  @override
  String get sumResult => 'Result';

  @override
  String sumDone(int minutes) {
    return '$minutes min of focus done!';
  }

  @override
  String sumPartial(int minutes) {
    return 'You were here for $minutes min. Only the part I could confirm counts.';
  }

  @override
  String get sumBookTitle => 'Contact book';

  @override
  String get sumWhat => 'What did you do?';

  @override
  String get sumWhatHint => 'e.g. Planned the report outline';

  @override
  String get sumHow => 'How well did you focus?';

  @override
  String get sumP0 => 'Not at all';

  @override
  String get sumP1 => 'A little';

  @override
  String get sumP2 => 'Quite';

  @override
  String get sumP3 => 'Perfectly';

  @override
  String get sumSave => 'Write it down and thank Tomarin';

  @override
  String get sumSkip => 'Close the book and rest';

  @override
  String get sumPenTitle => 'Red pen from Tomarin';

  @override
  String get sumReward => 'Rewards';

  @override
  String get replyGreat => 'Well done! Look at all that progress. Keep it up!';

  @override
  String get replyFair =>
      'Good job! You moved forward. Next time, aim for a little more.';

  @override
  String get replyLittle =>
      'A little is still something. Let us make the first step smaller next time.';

  @override
  String get replyNone =>
      'That happens. Next step: just open your notebook. The time you sat there counts too.';

  @override
  String get recTitle => 'This week';

  @override
  String get recHero => 'Time focused this week';

  @override
  String recTime(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get recMemo => 'Notes from Tomarin';

  @override
  String get recEmpty => 'Nothing yet. Let us start writing from today.';
}
