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
