// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get tasksTitle => 'タスク & XP';

  @override
  String get addTaskLabel => 'タスクを追加';

  @override
  String xpValue(int xp) {
    return '$xp XP';
  }

  @override
  String levelTitle(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      '0': '万年スクロール民',
      '1': '集中見習い',
      '2': '自制心の達人',
      'other': '選ばれし者',
    });
    return '$_temp0';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String alertAfter(int minutes) {
    return '$minutes分スクロールしたら通知';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes分';
  }

  @override
  String get testModeNote => '1〜2分はテストモードです（10秒ごとにチェック）。';

  @override
  String guardedApps(int count) {
    return 'ペットが見張るアプリ（$count）';
  }

  @override
  String get searchApps => 'アプリを検索';

  @override
  String get petBackToWork => 'わかったよ。作業に戻る。';

  @override
  String get petOffline => '頭はオフラインだけど、目はちゃんと見てるよ。スマホを置こう。';

  @override
  String get languageTitle => '言語';

  @override
  String get languageSystem => '端末に合わせる';

  @override
  String get memTitle => 'ペットの記憶';

  @override
  String get memNothing => 'まだ何もないよ。まずはスクロールして捕まってみよう。';

  @override
  String memCaught(int count) {
    return 'この7日間で$count回、スクロールしているところを目撃された。';
  }

  @override
  String memWeakness(String app, int count) {
    return '最大の弱点: $app（$count回）。';
  }

  @override
  String memPeak(int hour) {
    return '$hour時ごろに一番誘惑に弱い。';
  }

  @override
  String memToday(int count) {
    return '今日はすでに$count回見つかっている。';
  }

  @override
  String memTasks(int done, int total) {
    return 'タスク完了: $total件中$done件。';
  }

  @override
  String get ciAsk => 'あ、ついやっちゃったぴ？ 責めないよ。なにがあったか、教えて？';

  @override
  String get ciTired => '疲れてた';

  @override
  String get ciBored => 'ひまだった';

  @override
  String get ciAuto => '気づいたら開いてた';

  @override
  String get ciNotif => '通知がきた';

  @override
  String get ciSkip => 'いまはいいや';

  @override
  String get ciReplyTired => 'つかれてたんだね。次はその時間に、とまりんが先にぴとっとするぴ。';

  @override
  String get ciReplyBored => 'ひまだったんだね。次はその時間に、とまりんが先にぴとっとして、ほかのことに誘うよ。';

  @override
  String get ciReplyAuto => '気づいたら開いてること、あるよね。次はとまりんが先にぴとっとするぴ。';

  @override
  String get ciReplyNotif => '通知にひっぱられちゃったんだね。次は通知がきたら、とまりんが先にぴとっとするよ。';

  @override
  String get ciThanks => '教えてくれてありがとぴ。ちゃんと言えるの、えらいぴ。';

  @override
  String get ciSkipReply => 'うん、いまはいいよ。話したくなったら、いつでも言ってね。';

  @override
  String get titleEarnedHonest => '『正直者』ゲットだぴ！ とまりん、誇らしいぴ。';

  @override
  String memReason(String reason) {
    return 'つい開いちゃう理由は、だいたい「$reason」。';
  }

  @override
  String bondLevelName(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      '0': 'はじめまして',
      '1': 'なかよし',
      '2': 'ともだち',
      '3': 'しんゆう',
      'other': 'ずっとなかま',
    });
    return '$_temp0';
  }

  @override
  String bondPoints(int points) {
    return '絆 $points';
  }

  @override
  String get bondUp => 'なんか……もっと仲良くなれた気がするぴ。';

  @override
  String get focusHint => '長押しで終わる';

  @override
  String focusElapsed(int minutes) {
    return '$minutes分';
  }

  @override
  String focusDone(int minutes) {
    return '$minutes分、とまりんといっしょにいてくれてありがとぴ。';
  }

  @override
  String focusBondGain(int points) {
    return '絆 +$points';
  }

  @override
  String get focusCapped => '今日はもう十分がんばったぴ。ゆっくり休んでね。';

  @override
  String get focusShort => 'またいつでもおいで。とまりんはここにいるよ。';

  @override
  String get focusClose => 'とじる';
}
