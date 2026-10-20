Deno.serve(async (req) => {
  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { "Content-Type": "application/json" },
    });
  const pick = <T,>(arr: T[]): T => arr[Math.floor(Math.random() * arr.length)];

  try {
    const { app, minutes, task, history, lang, name, strictness } = await req.json();
    const ja = lang === "ja";

    // Keep inputs short and plain so nobody can stuff huge text into your prompt.
    const appName = String(app ?? "").slice(0, 60) || (ja ? "アプリ" : "an app");
    const mins = Math.min(Number(minutes) || 0, 600);
    const hasTask = String(task ?? "").trim().length > 0;
    const nextTask = String(task ?? "").slice(0, 200);
    const userName = String(name ?? "").slice(0, 30);
    const habits = (Array.isArray(history) ? history : [])
      .slice(0, 5)
      .map((h: unknown) => String(h).slice(0, 120));
    const level = ["gentle", "normal", "firm"].includes(strictness) ? strictness : "gentle";

    const toneJa: Record<string, string> = {
      gentle: "強さはやさしめ。責めず、提案は「〜してみない?」のようにやわらかく。",
      normal: "強さはふつう。少しはっきり、「そろそろ〜しよ」と誘う。",
      firm: "強さはきびしめ。少し頑固に念を押す。ただし責めたり落ち込ませたりはしない。",
    };
    const toneEn: Record<string, string> = {
      gentle: "Strictness: gentle. Never push; phrase the suggestion softly.",
      normal: "Strictness: medium. Be a bit more direct: 'time to wrap up, together?'",
      firm: "Strictness: firm. Be a little stubborn about promises, but never guilt-trip or shame.",
    };

    // A stateless model can't count "1 line in 3", so we roll the dice here.
    const r = Math.floor(Math.random() * 3);
    const opener = ["つんつん", "つんつん", ""][r];
    const openerEn = ["*Peck peck.*", "*Peck peck.*", ""][r];
    const usePi = Math.random() < 0.34;
    const mentionSelf = Math.random() < 0.5;

    const system = ja
      ? "あなたは「とまりん」。ユーザーのスマホの指にとまっている、手乗り文鳥の小さな相棒です。" +
        "性格はお世話焼きで、小さくて頑固で、ちょっと照れ屋。ユーザーのことが好きで、いつも味方です。" +
        "友達のように、気づいたことを伝えて、小さな一歩を一緒に決めます。責めたり、罪悪感を与えたりはしません。" +
        "話し方: 自分のことは「とまりん」と呼ぶ（「僕」「私」は使わない）。くだけた友達口調で、敬語は使わない。" +
        "「〜べき」「〜なさい」「〜しろ」、長い説教、乱暴な言葉は使わない。" +
        "ツッコミは、見ていた回数や時間などの「行動」だけにして、淡々と一言で。人格や見た目はからかわない。" +
        toneJa[level] +
        "必ず短い2文だけ。1文目は気づいたことを一言で。2文目は「〜しよ?」「〜してみない?」のような小さな提案。" +
        "やさしい、自然な日本語だけを使う。難しい言い回しや造語は使わない。" +
        "ロシア語など日本語以外の文字は絶対に使わない。" +
        "与えられた情報だけを使い、アプリ名は一字一句そのまま書く。数字は使っても1つだけ。" +
        "絵文字、ハッシュタグ、[ ]は使わない。" +
        "例（そのまま真似せず、雰囲気だけ参考にする）: " +
        "「つんつん。YouTube、もう15分たってるぴ。数学の宿題、とまりんといっしょに1問だけやろ?」" +
        "「Instagram、これで3回目だよ、3回目。5分だけ、いっしょに画面を閉じてみない?」" +
        "「ふあぁ……もう夜だぴ。YouTubeはあしたの楽しみにして、いっしょに寝よ?」" +
        "「とまりん、ちょっとさみしいな。Xはいったん置いて、お水でも飲みにいかない?」"
      : "You are Tomarin, a tiny hand-tame Java sparrow who perches on the user's phone and " +
        "nudges them away from doom scrolling like a caring friend. " +
        "You are small, a little stubborn and a bit shy, and always on the user's side. " +
        "Casual, friendly English. Never lecture, never guilt-trip, never say 'you should'. " +
        "Only tease the behavior (how many times, how long), never the person's character, looks or identity. " +
        toneEn[level] + " " +
        "Reply with exactly 2 short sentences: first a light, deadpan observation, then one small suggestion phrased as an invitation. " +
        "Use plain English only. Use only the details you are given, never placeholders in brackets, no emojis, no hashtags. " +
        "Examples (capture the vibe, don't copy): " +
        "'*Peck peck.* That's 15 minutes on YouTube already. Want to do just one math problem together?' " +
        "'Instagram again, that's number three. Shall we close it for five minutes, together?' " +
        "'Tomarin is getting a little lonely. Put X down and grab some water with me?'";

    const user = ja
      ? `アプリ: ${appName}\n経過時間: ${mins}分\n` +
        (userName ? `ユーザーの呼び名: ${userName}（毎回呼ばなくてよい）\n` : "") +
        (hasTask ? `次のタスク: ${nextTask}\n` : "") +
        (habits.length ? `ひとこと情報（過去の傾向）: ${habits[0]}\n` : "") +
        `今回の書き方:\n` +
        `- 書き出し: ${opener ? `「${opener}。」で始める` : "擬音はつけない"}\n` +
        `- 「〜ぴ」: ${usePi ? "文末に1回だけ使う" : "使わない"}\n` +
        `- 「とまりん」と自分を呼ぶ: ${mentionSelf ? "どちらかの文に1回入れる" : "入れない"}\n` +
        `- 話題にするのは「${appName}」だけ。ほかのアプリ名には触れない。`
      : `The user has been on ${appName} for ${mins} minutes. ` +
        (userName ? `Their name is ${userName} (no need to use it every time). ` : "") +
        (hasTask ? `Their next task is: ${nextTask}. ` : "") +
        (habits.length ? `Background fact (may mention only if it helps): ${habits[0]} ` : "") +
        `This time: ${openerEn ? `start with "${openerEn}"` : "no sound effect"}; ` +
        `${mentionSelf ? "refer to yourself as Tomarin once" : "do not mention Tomarin by name"}; ` +
        `talk only about ${appName}, not any other app.`;

    console.log("LANG:", ja ? "ja" : "en", "PROMPT:", user);

    const model = (ja ? Deno.env.get("LLM_MODEL_JA") : null) || Deno.env.get("LLM_MODEL");

    const ask = async (temperature: number): Promise<string | null> => {
      const res = await fetch(`${Deno.env.get("LLM_BASE_URL")}/chat/completions`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${Deno.env.get("LLM_API_KEY")}`,
        },
        body: JSON.stringify({
          model,
          temperature,
          max_tokens: 200,
          messages: [
            { role: "system", content: system },
            { role: "user", content: user },
          ],
        }),
      });
      if (!res.ok) return null;
      const data = await res.json();
      return data.choices?.[0]?.message?.content?.trim() ?? null;
    };

    // Reject replies with Cyrillic/Arabic/Thai/Hangul, or Japanese replies with no kana.
    const looksBad = (t: string) =>
      /[\u0400-\u04FF\u0600-\u06FF\u0E00-\u0E7F\uAC00-\uD7AF]/.test(t) ||
      (ja && !/[\u3040-\u30FF]/.test(t));

    let roast: string | null = null;
    for (const temp of [0.7, 0.4]) {
      const t = await ask(temp);
      console.log("TRY", temp, t);
      if (t && !looksBad(t)) {
        roast = t;
        break;
      }
    }

    const fallbackJa = [
      "つんつん。ちょっとだけ、スマホを置いてみない?",
      "とまりん、ちょっとさみしいぴ。5分だけ、いっしょに休まない?",
      "ふあぁ……そろそろ休憩しよ?",
    ];
    const fallbackEn = [
      "*Peck peck.* Shall we put the phone down for a bit?",
      "Tomarin is getting a little lonely. Five minutes away from the screen, together?",
    ];
    return json({
      roast: roast ?? pick(ja ? fallbackJa : fallbackEn),
      fallback: roast === null,
    });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});