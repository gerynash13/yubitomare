import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @tasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTitle;

  /// No description provided for @addTaskLabel.
  ///
  /// In en, this message translates to:
  /// **'Add a task'**
  String get addTaskLabel;

  /// No description provided for @xpValue.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String xpValue(int xp);

  /// No description provided for @levelTitle.
  ///
  /// In en, this message translates to:
  /// **'{level, select, 0{Filthy Casual Scroller} 1{Focus Apprentice} 2{Master of Discipline} other{The Chosen One}}'**
  String levelTitle(String level);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @alertAfter.
  ///
  /// In en, this message translates to:
  /// **'Alert after {minutes} min of scrolling'**
  String alertAfter(int minutes);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @testModeNote.
  ///
  /// In en, this message translates to:
  /// **'1-2 min is test mode (checks every 10 seconds).'**
  String get testModeNote;

  /// No description provided for @guardedApps.
  ///
  /// In en, this message translates to:
  /// **'Apps the pet guards ({count})'**
  String guardedApps(int count);

  /// No description provided for @searchApps.
  ///
  /// In en, this message translates to:
  /// **'Search apps'**
  String get searchApps;

  /// No description provided for @petBackToWork.
  ///
  /// In en, this message translates to:
  /// **'Fine. Back to work.'**
  String get petBackToWork;

  /// No description provided for @petOffline.
  ///
  /// In en, this message translates to:
  /// **'*Peck peck.* That has been a while. Is something up?'**
  String get petOffline;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @memTitle.
  ///
  /// In en, this message translates to:
  /// **'What the pet remembers'**
  String get memTitle;

  /// No description provided for @memNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet. Get caught scrolling first.'**
  String get memNothing;

  /// No description provided for @memCaught.
  ///
  /// In en, this message translates to:
  /// **'Caught scrolling {count} time(s) in the last 7 days.'**
  String memCaught(int count);

  /// No description provided for @memWeakness.
  ///
  /// In en, this message translates to:
  /// **'Biggest weakness: {app} ({count} time(s)).'**
  String memWeakness(String app, int count);

  /// No description provided for @memPeak.
  ///
  /// In en, this message translates to:
  /// **'Most vulnerable around {hour}:00.'**
  String memPeak(int hour);

  /// No description provided for @memToday.
  ///
  /// In en, this message translates to:
  /// **'Already caught {count} times today.'**
  String memToday(int count);

  /// No description provided for @memTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks done: {done} of {total}.'**
  String memTasks(int done, int total);

  /// No description provided for @ciAsk.
  ///
  /// In en, this message translates to:
  /// **'Oops, slipped? Tomarin will not blame you. What was going on?'**
  String get ciAsk;

  /// No description provided for @ciTired.
  ///
  /// In en, this message translates to:
  /// **'I was tired'**
  String get ciTired;

  /// No description provided for @ciBored.
  ///
  /// In en, this message translates to:
  /// **'I was bored'**
  String get ciBored;

  /// No description provided for @ciAuto.
  ///
  /// In en, this message translates to:
  /// **'I opened it without noticing'**
  String get ciAuto;

  /// No description provided for @ciNotif.
  ///
  /// In en, this message translates to:
  /// **'A notification came in'**
  String get ciNotif;

  /// No description provided for @ciSkip.
  ///
  /// In en, this message translates to:
  /// **'Not right now'**
  String get ciSkip;

  /// No description provided for @ciReplyTired.
  ///
  /// In en, this message translates to:
  /// **'I see, you were tired. Thank you for telling Tomarin.'**
  String get ciReplyTired;

  /// No description provided for @ciReplyBored.
  ///
  /// In en, this message translates to:
  /// **'You were bored. Tomarin appreciates you being honest.'**
  String get ciReplyBored;

  /// No description provided for @ciReplyAuto.
  ///
  /// In en, this message translates to:
  /// **'That happens, it is easy to open it without noticing. Thank you for telling Tomarin.'**
  String get ciReplyAuto;

  /// No description provided for @ciReplyNotif.
  ///
  /// In en, this message translates to:
  /// **'A notification pulled you in. Tomarin wishes it had noticed sooner.'**
  String get ciReplyNotif;

  /// No description provided for @ciThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for telling Tomarin. It is great that you can say it honestly.'**
  String get ciThanks;

  /// No description provided for @ciSkipReply.
  ///
  /// In en, this message translates to:
  /// **'Okay, no pressure. Tell Tomarin whenever you feel like it.'**
  String get ciSkipReply;

  /// No description provided for @titleEarnedHonest.
  ///
  /// In en, this message translates to:
  /// **'Title earned: Honest One! Tomarin is so proud.'**
  String get titleEarnedHonest;

  /// No description provided for @memReason.
  ///
  /// In en, this message translates to:
  /// **'Usually slips because: {reason}.'**
  String memReason(String reason);

  /// No description provided for @bondLevelName.
  ///
  /// In en, this message translates to:
  /// **'{level, select, 0{Nice to meet you} 1{Getting close} 2{Friends} 3{Best friends} other{Together forever}}'**
  String bondLevelName(String level);

  /// No description provided for @bondPoints.
  ///
  /// In en, this message translates to:
  /// **'Bond {points}'**
  String bondPoints(int points);

  /// No description provided for @bondUp.
  ///
  /// In en, this message translates to:
  /// **'Tomarin feels like it got closer to you.'**
  String get bondUp;

  /// No description provided for @focusHint.
  ///
  /// In en, this message translates to:
  /// **'Press and hold to finish'**
  String get focusHint;

  /// No description provided for @focusElapsed.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String focusElapsed(int minutes);

  /// No description provided for @focusDone.
  ///
  /// In en, this message translates to:
  /// **'Thank you for staying with Tomarin for {minutes} min.'**
  String focusDone(int minutes);

  /// No description provided for @focusBondGain.
  ///
  /// In en, this message translates to:
  /// **'Bond +{points}'**
  String focusBondGain(int points);

  /// No description provided for @focusCapped.
  ///
  /// In en, this message translates to:
  /// **'That is plenty for today. Rest well, okay?'**
  String get focusCapped;

  /// No description provided for @focusShort.
  ///
  /// In en, this message translates to:
  /// **'Come back anytime. Tomarin will be here.'**
  String get focusShort;

  /// No description provided for @focusClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get focusClose;

  /// No description provided for @bondGainSmall.
  ///
  /// In en, this message translates to:
  /// **'+{points} Bond'**
  String bondGainSmall(int points);

  /// No description provided for @planAsk.
  ///
  /// In en, this message translates to:
  /// **'Last thing: want to decide one small thing to do next time the urge hits?'**
  String get planAsk;

  /// No description provided for @planSkip.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get planSkip;

  /// No description provided for @planActCharge.
  ///
  /// In en, this message translates to:
  /// **'put my phone on the charger and stretch'**
  String get planActCharge;

  /// No description provided for @planActWater.
  ///
  /// In en, this message translates to:
  /// **'drink some water'**
  String get planActWater;

  /// No description provided for @planActFocus.
  ///
  /// In en, this message translates to:
  /// **'open the focus screen'**
  String get planActFocus;

  /// No description provided for @planActTiny.
  ///
  /// In en, this message translates to:
  /// **'do the first tiny step of my task for 2 minutes'**
  String get planActTiny;

  /// No description provided for @planSentence.
  ///
  /// In en, this message translates to:
  /// **'If I feel like opening {app}, then I will {action}.'**
  String planSentence(String app, String action);

  /// No description provided for @planSaved.
  ///
  /// In en, this message translates to:
  /// **'It is settled. {plan} Tomarin will remember it too.'**
  String planSaved(String plan);

  /// No description provided for @planReminder.
  ///
  /// In en, this message translates to:
  /// **'Oh, and you already made a plan. {plan}'**
  String planReminder(String plan);

  /// No description provided for @tasksDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String tasksDone(int done, int total);

  /// No description provided for @hardAsk.
  ///
  /// In en, this message translates to:
  /// **'By the way, about {task}: what feels hardest about it?'**
  String hardAsk(String task);

  /// No description provided for @hardBig.
  ///
  /// In en, this message translates to:
  /// **'I feel like it\'s too big of a task'**
  String get hardBig;

  /// No description provided for @hardStart.
  ///
  /// In en, this message translates to:
  /// **'I do not know where to start'**
  String get hardStart;

  /// No description provided for @hardAfraid.
  ///
  /// In en, this message translates to:
  /// **'I am afraid of doing it badly'**
  String get hardAfraid;

  /// No description provided for @hardBoring.
  ///
  /// In en, this message translates to:
  /// **'It is boring'**
  String get hardBoring;

  /// No description provided for @hardHeavy.
  ///
  /// In en, this message translates to:
  /// **'I have felt heavy for a while'**
  String get hardHeavy;

  /// No description provided for @hardReplyBig.
  ///
  /// In en, this message translates to:
  /// **'Big things make anyone freeze. Even just opening the file or notebook counts as a start.'**
  String get hardReplyBig;

  /// No description provided for @hardReplyStart.
  ///
  /// In en, this message translates to:
  /// **'Not knowing where to start is hard. How about writing one line about what comes first?'**
  String get hardReplyStart;

  /// No description provided for @hardReplyAfraid.
  ///
  /// In en, this message translates to:
  /// **'Your first try can be rough. Want to do it messily for just 2 minutes?'**
  String get hardReplyAfraid;

  /// No description provided for @hardReplyBoring.
  ///
  /// In en, this message translates to:
  /// **'Boring tasks make hands stop. Try 2 minutes, then a glass of water as a reward.'**
  String get hardReplyBoring;

  /// No description provided for @planPlay.
  ///
  /// In en, this message translates to:
  /// **'I will try it'**
  String get planPlay;

  /// No description provided for @planPlayReply.
  ///
  /// In en, this message translates to:
  /// **'Okay, go for it. Tomarin will be waiting here.'**
  String get planPlayReply;

  /// No description provided for @planLaterReply.
  ///
  /// In en, this message translates to:
  /// **'Okay, got it.'**
  String get planLaterReply;

  /// No description provided for @sincere1.
  ///
  /// In en, this message translates to:
  /// **'...Hey, can I talk to you seriously for a moment?'**
  String get sincere1;

  /// No description provided for @sincere2.
  ///
  /// In en, this message translates to:
  /// **'If things have felt heavy for a long time, you do not have to carry it alone. Even a word to family, a friend, a teacher or someone you trust can help.'**
  String get sincere2;

  /// No description provided for @sincere3.
  ///
  /// In en, this message translates to:
  /// **'If it is hard to say out loud, there are free phone lines in Japan. Yorisoi Hotline (0120-279-338) is open 24 hours, and Inochi SOS (0120-061-338) is there for feelings like wanting to disappear.'**
  String get sincere3;

  /// No description provided for @sincere4.
  ///
  /// In en, this message translates to:
  /// **'Tomarin is right here.'**
  String get sincere4;

  /// No description provided for @callMeTitle.
  ///
  /// In en, this message translates to:
  /// **'What should Tomarin call you?'**
  String get callMeTitle;

  /// No description provided for @callMeHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get callMeHint;

  /// No description provided for @suffixSan.
  ///
  /// In en, this message translates to:
  /// **'-san'**
  String get suffixSan;

  /// No description provided for @suffixKun.
  ///
  /// In en, this message translates to:
  /// **'-kun'**
  String get suffixKun;

  /// No description provided for @suffixChan.
  ///
  /// In en, this message translates to:
  /// **'-chan'**
  String get suffixChan;

  /// No description provided for @suffixNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get suffixNone;

  /// No description provided for @interceptShout0.
  ///
  /// In en, this message translates to:
  /// **'Peck.'**
  String get interceptShout0;

  /// No description provided for @interceptSub0.
  ///
  /// In en, this message translates to:
  /// **'You just opened {app}, right?'**
  String interceptSub0(String app);

  /// No description provided for @interceptShout1.
  ///
  /// In en, this message translates to:
  /// **'Hey, {app} again?'**
  String interceptShout1(String app);

  /// No description provided for @interceptSub1.
  ///
  /// In en, this message translates to:
  /// **'You were just on it!'**
  String get interceptSub1;

  /// No description provided for @interceptShout2.
  ///
  /// In en, this message translates to:
  /// **'What are you DOING?!'**
  String get interceptShout2;

  /// No description provided for @interceptSub2.
  ///
  /// In en, this message translates to:
  /// **'How many times do I have to say it? Go back now.'**
  String get interceptSub2;

  /// No description provided for @interceptBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get interceptBack;

  /// No description provided for @interceptPass.
  ///
  /// In en, this message translates to:
  /// **'{minutes} more min'**
  String interceptPass(int minutes);

  /// No description provided for @interceptTag.
  ///
  /// In en, this message translates to:
  /// **'Extensions today {used}/{total}'**
  String interceptTag(int used, int total);

  /// No description provided for @interceptStamp.
  ///
  /// In en, this message translates to:
  /// **'DONE\nTODAY'**
  String get interceptStamp;

  /// No description provided for @interceptClosedTitle.
  ///
  /// In en, this message translates to:
  /// **'That is it for today!'**
  String get interceptClosedTitle;

  /// No description provided for @interceptClosedBody.
  ///
  /// In en, this message translates to:
  /// **'{app} is closed until tomorrow. You have had enough for today, so rest well.'**
  String interceptClosedBody(String app);

  /// No description provided for @interceptClosedUsed.
  ///
  /// In en, this message translates to:
  /// **'Extensions today'**
  String get interceptClosedUsed;

  /// No description provided for @interceptClosedUsedValue.
  ///
  /// In en, this message translates to:
  /// **'{used}/{total} used up'**
  String interceptClosedUsedValue(int used, int total);

  /// No description provided for @interceptClosedNext.
  ///
  /// In en, this message translates to:
  /// **'Unlocks'**
  String get interceptClosedNext;

  /// No description provided for @interceptClosedAt.
  ///
  /// In en, this message translates to:
  /// **'6:00 AM'**
  String get interceptClosedAt;

  /// No description provided for @interceptClosedNote.
  ///
  /// In en, this message translates to:
  /// **'I will be waiting on the perch.'**
  String get interceptClosedNote;

  /// No description provided for @interceptHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get interceptHome;

  /// No description provided for @negTag.
  ///
  /// In en, this message translates to:
  /// **'Excuse time · {minutes} min negotiation'**
  String negTag(int minutes);

  /// No description provided for @negQuestion.
  ///
  /// In en, this message translates to:
  /// **'{minutes} more minutes, huh... so, why do you want them?'**
  String negQuestion(int minutes);

  /// No description provided for @negSub.
  ///
  /// In en, this message translates to:
  /// **'Tell me honestly and I will watch over you for {minutes} minutes.'**
  String negSub(int minutes);

  /// No description provided for @negHmm.
  ///
  /// In en, this message translates to:
  /// **'Hmm...'**
  String get negHmm;

  /// No description provided for @negStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Sizing you up: not convinced yet'**
  String get negStatusWaiting;

  /// No description provided for @negStatusDone.
  ///
  /// In en, this message translates to:
  /// **'...Oh, all right.'**
  String get negStatusDone;

  /// No description provided for @negReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'One honest reason'**
  String get negReasonTitle;

  /// No description provided for @negRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get negRequired;

  /// No description provided for @negLater.
  ///
  /// In en, this message translates to:
  /// **'We will look back on it later'**
  String get negLater;

  /// No description provided for @negSubTired.
  ///
  /// In en, this message translates to:
  /// **'Needed a breather'**
  String get negSubTired;

  /// No description provided for @negSubBored.
  ///
  /// In en, this message translates to:
  /// **'Had nothing to do'**
  String get negSubBored;

  /// No description provided for @negSubAuto.
  ///
  /// In en, this message translates to:
  /// **'Tapped without thinking'**
  String get negSubAuto;

  /// No description provided for @negSubNotif.
  ///
  /// In en, this message translates to:
  /// **'Only meant to reply'**
  String get negSubNotif;

  /// No description provided for @negPromise.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min only, I promise'**
  String negPromise(int minutes);

  /// No description provided for @negPinky.
  ///
  /// In en, this message translates to:
  /// **'Pinky promise'**
  String get negPinky;

  /// No description provided for @negBackOut.
  ///
  /// In en, this message translates to:
  /// **'Actually, I will go back (close the screen)'**
  String get negBackOut;

  /// No description provided for @negFootnote.
  ///
  /// In en, this message translates to:
  /// **'* After {minutes} minutes I will land on the screen again.'**
  String negFootnote(int minutes);

  /// No description provided for @crisisTitle.
  ///
  /// In en, this message translates to:
  /// **'When things are hard'**
  String get crisisTitle;

  /// No description provided for @crisisHotline1.
  ///
  /// In en, this message translates to:
  /// **'Yorisoi Hotline'**
  String get crisisHotline1;

  /// No description provided for @crisisHotline2.
  ///
  /// In en, this message translates to:
  /// **'#Inochi SOS'**
  String get crisisHotline2;

  /// No description provided for @crisisFree24.
  ///
  /// In en, this message translates to:
  /// **'Free · 24 hours'**
  String get crisisFree24;

  /// No description provided for @crisisFree24Sos.
  ///
  /// In en, this message translates to:
  /// **'Free · 24 hours (also when you feel like disappearing)'**
  String get crisisFree24Sos;

  /// No description provided for @crisisCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get crisisCall;

  /// No description provided for @crisisOk.
  ///
  /// In en, this message translates to:
  /// **'I am okay for now'**
  String get crisisOk;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get navFocus;

  /// No description provided for @navRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get navRecord;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Yubitomare'**
  String get appTitle;

  /// No description provided for @statusRunning.
  ///
  /// In en, this message translates to:
  /// **'Watching ({count} apps)'**
  String statusRunning(int count);

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'Guard paused'**
  String get statusPaused;

  /// No description provided for @statusPausedSub.
  ///
  /// In en, this message translates to:
  /// **'The guard is paused, so nothing stops you from scrolling.'**
  String get statusPausedSub;

  /// No description provided for @statusMissing.
  ///
  /// In en, this message translates to:
  /// **'Permission missing'**
  String get statusMissing;

  /// No description provided for @statusMissingSub.
  ///
  /// In en, this message translates to:
  /// **'Tomarin cannot watch without a permission. Please check it.'**
  String get statusMissingSub;

  /// No description provided for @statusResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get statusResume;

  /// No description provided for @statusFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get statusFix;

  /// No description provided for @todayBond.
  ///
  /// In en, this message translates to:
  /// **'Bond Lv.{level} {name}'**
  String todayBond(int level, String name);

  /// No description provided for @todayNagTitle.
  ///
  /// In en, this message translates to:
  /// **'Did you really look at today?'**
  String get todayNagTitle;

  /// No description provided for @todayNag.
  ///
  /// In en, this message translates to:
  /// **'Start with {task}. Put the phone down and get ready!'**
  String todayNag(String task);

  /// No description provided for @todayNagEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing is planned yet. Pick one small thing for today.'**
  String get todayNagEmpty;

  /// No description provided for @todayTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'To-dos for today'**
  String get todayTasksTitle;

  /// No description provided for @todayAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get todayAdd;

  /// No description provided for @todayDoneStamp.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get todayDoneStamp;

  /// No description provided for @todayStartFocus.
  ///
  /// In en, this message translates to:
  /// **'Start focusing'**
  String get todayStartFocus;

  /// No description provided for @todayStartFocusSub.
  ///
  /// In en, this message translates to:
  /// **'Focus together with Tomarin'**
  String get todayStartFocusSub;

  /// No description provided for @fsTitle.
  ///
  /// In en, this message translates to:
  /// **'What will you do?'**
  String get fsTitle;

  /// No description provided for @fsGoalHint.
  ///
  /// In en, this message translates to:
  /// **'A one-line goal (optional)'**
  String get fsGoalHint;

  /// No description provided for @fsStart.
  ///
  /// In en, this message translates to:
  /// **'Focus with Tomarin'**
  String get fsStart;

  /// No description provided for @fsNote.
  ///
  /// In en, this message translates to:
  /// **'The screen will go dark. Every 10 minutes or so Tomarin will call out, so answer it.'**
  String get fsNote;

  /// No description provided for @fsNoTasks.
  ///
  /// In en, this message translates to:
  /// **'Add tasks on the Today tab, or just start.'**
  String get fsNoTasks;

  /// No description provided for @focusNow.
  ///
  /// In en, this message translates to:
  /// **'Now: {goal}'**
  String focusNow(String goal);

  /// No description provided for @focusUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get focusUnit;

  /// No description provided for @focusWith.
  ///
  /// In en, this message translates to:
  /// **'Focusing with Tomarin'**
  String get focusWith;

  /// No description provided for @checkTitle.
  ///
  /// In en, this message translates to:
  /// **'Pi? Are you there?'**
  String get checkTitle;

  /// No description provided for @checkHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to answer'**
  String get checkHint;

  /// No description provided for @sumTitle.
  ///
  /// In en, this message translates to:
  /// **'Good work!'**
  String get sumTitle;

  /// No description provided for @sumResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get sumResult;

  /// No description provided for @sumDone.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min of focus done!'**
  String sumDone(int minutes);

  /// No description provided for @sumPartial.
  ///
  /// In en, this message translates to:
  /// **'You were here for {minutes} min. Only the part I could confirm counts.'**
  String sumPartial(int minutes);

  /// No description provided for @sumBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact book'**
  String get sumBookTitle;

  /// No description provided for @sumWhat.
  ///
  /// In en, this message translates to:
  /// **'What did you do?'**
  String get sumWhat;

  /// No description provided for @sumWhatHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Planned the report outline'**
  String get sumWhatHint;

  /// No description provided for @sumHow.
  ///
  /// In en, this message translates to:
  /// **'How well did you focus?'**
  String get sumHow;

  /// No description provided for @sumP0.
  ///
  /// In en, this message translates to:
  /// **'Not at all'**
  String get sumP0;

  /// No description provided for @sumP1.
  ///
  /// In en, this message translates to:
  /// **'A little'**
  String get sumP1;

  /// No description provided for @sumP2.
  ///
  /// In en, this message translates to:
  /// **'Quite'**
  String get sumP2;

  /// No description provided for @sumP3.
  ///
  /// In en, this message translates to:
  /// **'Perfectly'**
  String get sumP3;

  /// No description provided for @sumSave.
  ///
  /// In en, this message translates to:
  /// **'Write it down and thank Tomarin'**
  String get sumSave;

  /// No description provided for @sumSkip.
  ///
  /// In en, this message translates to:
  /// **'Close the book and rest'**
  String get sumSkip;

  /// No description provided for @sumPenTitle.
  ///
  /// In en, this message translates to:
  /// **'Red pen from Tomarin'**
  String get sumPenTitle;

  /// No description provided for @sumReward.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get sumReward;

  /// No description provided for @replyGreat.
  ///
  /// In en, this message translates to:
  /// **'Well done! Look at all that progress. Keep it up!'**
  String get replyGreat;

  /// No description provided for @replyFair.
  ///
  /// In en, this message translates to:
  /// **'Good job! You moved forward. Next time, aim for a little more.'**
  String get replyFair;

  /// No description provided for @replyLittle.
  ///
  /// In en, this message translates to:
  /// **'A little is still something. Let us make the first step smaller next time.'**
  String get replyLittle;

  /// No description provided for @replyNone.
  ///
  /// In en, this message translates to:
  /// **'That happens. Next step: just open your notebook. The time you sat there counts too.'**
  String get replyNone;

  /// No description provided for @recTitle.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get recTitle;

  /// No description provided for @recHero.
  ///
  /// In en, this message translates to:
  /// **'Time focused this week'**
  String get recHero;

  /// No description provided for @recTime.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String recTime(int hours, int minutes);

  /// No description provided for @recMemo.
  ///
  /// In en, this message translates to:
  /// **'Notes from Tomarin'**
  String get recMemo;

  /// No description provided for @recEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet. Let us start writing from today.'**
  String get recEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
