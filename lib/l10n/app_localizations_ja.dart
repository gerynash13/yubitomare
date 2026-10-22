// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get tasksTitle => 'タスク';

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
  String get petOffline => 'つんつん。ちょっと長いぴ。……なにか、あった？';

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
  String get ciReplyTired => 'そっか、疲れてたんだね。話してくれてありがとぴ。';

  @override
  String get ciReplyBored => 'ひまだったんだね。ちゃんと教えてくれて、えらいぴ。';

  @override
  String get ciReplyAuto => '気づいたら開いてること、あるよね。教えてくれてありがとぴ。';

  @override
  String get ciReplyNotif => '通知にひっぱられちゃったんだね。……とまりんも、もっと早く気づけたらよかった。';

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

  @override
  String bondGainSmall(int points) {
    return '+$points絆';
  }

  @override
  String get planAsk => 'じゃあ最後に。次に開きたくなったとき用に、ひとつだけ決めとこ？';

  @override
  String get planSkip => 'あとでいいよ';

  @override
  String get planActCharge => 'スマホを充電器に置いて、のびをする';

  @override
  String get planActWater => 'お水を飲む';

  @override
  String get planActFocus => '集中画面を開く';

  @override
  String get planActTiny => 'タスクの最初の一歩を2分だけやる';

  @override
  String planSentence(String app, String action) {
    return '$appを開きたくなったら、$action。';
  }

  @override
  String planSaved(String plan) {
    return '決まりだぴ。$plan とまりんも覚えとくよ。';
  }

  @override
  String planReminder(String plan) {
    return 'そういえば、決めたプランがあったよね。$plan';
  }

  @override
  String tasksDone(int done, int total) {
    return '$total件中$done件完了';
  }

  @override
  String hardAsk(String task) {
    return 'ところで、「$task」……いちばん手をつけにくいのは、どこ？';
  }

  @override
  String get hardBig => '大きすぎる';

  @override
  String get hardStart => 'どこから始めたらいいかわからない';

  @override
  String get hardAfraid => 'うまくできるか不安';

  @override
  String get hardBoring => 'つまらない';

  @override
  String get hardHeavy => 'ずっとしんどい';

  @override
  String get hardReplyBig => '大きいと、固まっちゃうよね。ファイルやノートを開くだけでも、立派な一歩だよ。';

  @override
  String get hardReplyStart => 'どこから始めるか迷うよね。『最初にやること』を、ひとことで書くだけでいいぴ。';

  @override
  String get hardReplyAfraid => 'さいしょは下手でいいんだよ。雑なままで、2分だけやってみよ？';

  @override
  String get hardReplyBoring => 'つまらないと、手が止まるよね。2分だけやって、そのあとお水でも飲も？';

  @override
  String get planPlay => 'やってみる';

  @override
  String get planPlayReply => 'うん、いってらっしゃい。とまりんはここで待ってるぴ。';

  @override
  String get planLaterReply => 'うん、わかった。';

  @override
  String get sincere1 => '……ねえ、ちょっと真面目な話してもいい？';

  @override
  String get sincere2 =>
      'ずっとしんどいときは、とまりんだけで抱えなくていいよ。家族や友だち、先生、信頼できる人に、ひとことだけでも話してみてほしいな。';

  @override
  String get sincere3 =>
      '話しにくいときは、無料の電話相談もあるよ。よりそいホットライン（0120-279-338）は24時間つながるよ。「消えたい」って気持ちのときは、#いのちSOS（0120-061-338）もあるよ。';

  @override
  String get sincere4 => 'とまりんは、ここにいるよ。';
}
