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

  @override
  String get callMeTitle => 'とまりんに、なんて呼ばれたい？';

  @override
  String get callMeHint => 'あなたの名前';

  @override
  String get suffixSan => 'さん';

  @override
  String get suffixKun => 'くん';

  @override
  String get suffixChan => 'ちゃん';

  @override
  String get suffixNone => 'なし';

  @override
  String get interceptShout0 => 'ぴとっ。';

  @override
  String interceptSub0(String app) {
    return '$app、いま開いたでしょ？';
  }

  @override
  String interceptShout1(String app) {
    return 'ちょっと、また$app？';
  }

  @override
  String get interceptSub1 => 'さっきも見てたでしょ！';

  @override
  String get interceptShout2 => 'なにしてるんかい！！！';

  @override
  String get interceptSub2 => '何度言ったらわかるの？ 今すぐ戻って。';

  @override
  String get interceptBack => '戻る';

  @override
  String interceptPass(int minutes) {
    return 'あと$minutes分';
  }

  @override
  String interceptTag(int used, int total) {
    return '今日の延長 $used/$total';
  }

  @override
  String get interceptStamp => '本日\n終了';

  @override
  String get interceptClosedTitle => 'もう今日はおしまい！';

  @override
  String interceptClosedBody(String app) {
    return '$appは、また明日ね。今日はもう十分でしょ。ゆっくり休んでね。';
  }

  @override
  String get interceptClosedUsed => '今日の延長';

  @override
  String interceptClosedUsedValue(int used, int total) {
    return '$used/$total 使いきりました';
  }

  @override
  String get interceptClosedNext => '次の解除';

  @override
  String get interceptClosedAt => 'あさ6:00';

  @override
  String get interceptClosedNote => '止まり木で待ってるからね。';

  @override
  String get interceptHome => 'ホームに戻る';

  @override
  String negTag(int minutes) {
    return '言い訳タイム・$minutes分の交渉';
  }

  @override
  String negQuestion(int minutes) {
    return 'あと$minutes分ね。……で、なんで延長したいの？';
  }

  @override
  String negSub(int minutes) {
    return 'ちゃんと言えたら、$minutes分だけ見守ってあげる。';
  }

  @override
  String get negHmm => 'ふむ…';

  @override
  String get negStatusWaiting => '見定め中：まだ納得していません';

  @override
  String get negStatusDone => '……しょうがないなぁ。';

  @override
  String get negReasonTitle => '正直な理由をひとつ';

  @override
  String get negRequired => '必須';

  @override
  String get negLater => 'あとで振り返ります';

  @override
  String get negSubTired => 'ひと息つきたかった';

  @override
  String get negSubBored => '手持ち無沙汰で…';

  @override
  String get negSubAuto => '無意識にタップした';

  @override
  String get negSubNotif => '返信だけのはずが';

  @override
  String negPromise(int minutes) {
    return '$minutes分だけ、約束する';
  }

  @override
  String get negPinky => '指切り';

  @override
  String get negBackOut => 'やっぱり戻る（画面を閉じる）';

  @override
  String negFootnote(int minutes) {
    return '※ $minutes分経ったら、また画面にとまりに来るからね';
  }

  @override
  String get crisisTitle => 'つらいときは';

  @override
  String get crisisHotline1 => 'よりそいホットライン';

  @override
  String get crisisHotline2 => '#いのちSOS';

  @override
  String get crisisFree24 => '無料・24時間';

  @override
  String get crisisFree24Sos => '無料・24時間（「消えたい」ときにも）';

  @override
  String get crisisCall => '電話をかける';

  @override
  String get crisisOk => 'いまはだいじょうぶ';

  @override
  String get navToday => '今日';

  @override
  String get navFocus => '集中';

  @override
  String get navRecord => '記録';

  @override
  String get appTitle => 'ゆびとまれ';

  @override
  String statusRunning(int count) {
    return '見守り中（$countアプリ）';
  }

  @override
  String get statusPaused => '見張りを止めています';

  @override
  String get statusPausedSub => '見張りを止めているので、スマホを見すぎても止めてあげられないよ。';

  @override
  String get statusMissing => '許可が足りません';

  @override
  String get statusMissingSub => '見守りに必要な許可が足りないみたい。確認してね。';

  @override
  String get statusResume => '再開する';

  @override
  String get statusFix => 'なおす';

  @override
  String todayBond(int level, String name) {
    return '絆 レベル$level $name';
  }

  @override
  String get todayNagTitle => '今日の予定、ちゃんと見た？';

  @override
  String todayNag(String task) {
    return 'まずは「$task」からだよ。スマホを触ってないで、準備して！';
  }

  @override
  String get todayNagEmpty => 'まだ何も決まってないよ。今日やることをひとつ決めよ。';

  @override
  String get todayTasksTitle => 'きょうのお役目';

  @override
  String get todayAdd => '追加';

  @override
  String get todayDoneStamp => '花丸';

  @override
  String get todayStartFocus => '集中をはじめる';

  @override
  String get todayStartFocusSub => 'とまりんと一緒に集中';

  @override
  String get fsTitle => '何をする？';

  @override
  String get fsGoalHint => 'ひとこと目標（なくてもOK）';

  @override
  String get fsStart => 'とまりんと集中する';

  @override
  String get fsNote => '画面は暗くなるよ。10分ごとに『ぴ？』と呼ぶから、返事してね。';

  @override
  String get fsNoTasks => 'タスクは「今日」タブで足せるよ。なしでもはじめられるよ。';

  @override
  String focusNow(String goal) {
    return 'いま：$goal';
  }

  @override
  String get focusUnit => '分';

  @override
  String get focusWith => 'とまりんと一緒に集中';

  @override
  String get checkTitle => 'ぴ？ いる？';

  @override
  String get checkHint => 'タップで返事';

  @override
  String get sumTitle => 'おつかれさま！';

  @override
  String get sumResult => '本日の成果';

  @override
  String sumDone(int minutes) {
    return '$minutes分 集中完了！';
  }

  @override
  String sumPartial(int minutes) {
    return '$minutes分いたけど、確認できたぶんだけ数えたよ。';
  }

  @override
  String get sumBookTitle => '今日のれんらく帳';

  @override
  String get sumWhat => '今日は何をした？';

  @override
  String get sumWhatHint => '例：レポートの構成を考えた';

  @override
  String get sumHow => '集中できたかな？';

  @override
  String get sumP0 => 'ぜんぜん';

  @override
  String get sumP1 => 'ちょっと';

  @override
  String get sumP2 => 'けっこう';

  @override
  String get sumP3 => 'ばっちり';

  @override
  String get sumSave => '記録して、とまりんをねぎらう';

  @override
  String get sumSkip => '連絡帳をとじて休憩する';

  @override
  String get sumPenTitle => '赤ペン先生コメント';

  @override
  String get sumReward => 'もらったごほうび';

  @override
  String get replyGreat => 'えらい！ よくやったじゃない。この調子でいこうね！';

  @override
  String get replyFair => 'いいじゃない！ ちゃんと進んだよ。次はもうちょっとだけ欲張ろ。';

  @override
  String get replyLittle => 'ちょっとでも進んだなら十分だよ。次の一歩は、もっと小さくしよ。';

  @override
  String get replyNone => 'ぜんぜんだったんだね。次の一歩は、ノートを開くだけにしよ。座っていた時間も、ちゃんと数えたよ。';

  @override
  String get recTitle => '今週のきろく';

  @override
  String get recHero => '今週、集中した時間';

  @override
  String recTime(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String get recMemo => 'とまりんの連絡帳メモ';

  @override
  String get recEmpty => 'まだ記録がないよ。今日から、いっしょにつけよ。';
}
