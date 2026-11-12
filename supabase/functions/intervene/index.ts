Deno.serve(async (req) => {
  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { "Content-Type": "application/json" },
    });
  const pick = <T,>(arr: T[]): T => arr[Math.floor(Math.random() * arr.length)];

  try {
    const { app, minutes, task, history, lang, name, suffix, level, locked, shout, lastReason, lastApp } =
      await req.json();
    const ja = lang === "ja";

    // Keep inputs short and plain so nobody can stuff huge text into your prompt.
    const appName = String(app ?? "").slice(0, 60) || (ja ? "アプリ" : "an app");
    const mins = Math.min(Number(minutes) || 0, 600);
    const hasTask = String(task ?? "").trim().length > 0;
    const nextTask = String(task ?? "").slice(0, 200);
    const habits = (Array.isArray(history) ? history : [])
      .slice(0, 5)
      .map((h: unknown) => String(h).slice(0, 120));

    // How Tomarin calls the user: their name plus the suffix they picked.
    const jaSuffix: Record<string, string> = { san: "さん", kun: "くん", chan: "ちゃん", none: "" };
    const rawName = String(name ?? "").replace(/\s+/g, " ").trim().slice(0, 30);
    const suf = ["san", "kun", "chan"].includes(suffix) ? suffix : "none";
    const callName = rawName
      ? ja
        ? rawName + jaSuffix[suf]
        : rawName + (suf === "none" ? "" : `-${suf}`)
      : "";

    // One personality. Only its mood changes, depending on what the user did today:
    // 1 first card, 2 annoyed, 3 fully angry, 4 closed for today.
    const used = Math.max(0, Math.min(Math.floor(Number(level) || 0), 10));
    const intensity = locked === true ? 4 : Math.min(3, 1 + used);

    // A stateless model can't count "1 line in 3", so we roll the dice here.
    const opener = intensity === 1
      ? (Math.random() < 0.7 ? "ぴとっ" : "")
      : intensity === 2
      ? (Math.random() < 0.3 ? "つんつん" : "")
      : "";
    const openerEn = ({ "ぴとっ": "*Peck.*", "つんつん": "*Peck peck.*", "": "" } as Record<string, string>)[opener];
    // Angry moms don't say ぴ. The first card and the final line can.
    const usePi = intensity <= 2 ? Math.random() < 0.34 : intensity === 4 ? Math.random() < 0.5 : false;
    const mentionSelf = Math.random() < 0.5;

    // A different angle each time keeps the lines from repeating.
    const anglesJa = [
      "回数や時間などの数字をツッコむ",
      "「どうせまた『ちょっとだけ』でしょ」と、言い訳を先回りして突っ込む",
      "がっかりした気持ちを、素直に一言で言う",
    ];
    const anglesEn = [
      "deadpan comment on the numbers (how many times, how long)",
      "see the excuse coming: 'let me guess, just a little, right?'",
      "say honestly that you are disappointed",
    ];
    if (hasTask) {
      anglesJa.push("次のタスクを持ち出して、それはどうしたのと問いただす");
      anglesEn.push("bring up their next task and ask what happened to it");
    }
    if (used > 0) {
      anglesJa.push("さっき自分で決めた延長の約束を持ち出す");
      anglesEn.push("bring up the extension they just promised to keep short");
    }
    // What the card already shows, what the user said last time, and whether they hopped apps.
    const shoutText = String(shout ?? "").slice(0, 60);
    const reasonJa: Record<string, string> = {
      tired: "疲れてた",
      bored: "ひまだった",
      auto: "気づいたら開いてた",
      notif: "通知がきた",
    };
    const reasonEn: Record<string, string> = {
      tired: "I was tired",
      bored: "I was bored",
      auto: "I opened it without noticing",
      notif: "A notification came in",
    };
    const reasonLabel = (ja ? reasonJa : reasonEn)[String(lastReason ?? "")] ?? "";
    const prevApp = String(lastApp ?? "").slice(0, 60);
    const hopped = used > 0 && prevApp !== "" && prevApp !== appName;
    if (reasonLabel) {
      anglesJa.push(`さっき本人が言った理由「${reasonLabel}」を持ち出して、本当にそうなのかツッコむ`);
      anglesEn.push(`bring up the reason they just gave ("${reasonLabel}") and question whether it is really true`);
    }
    // Hopping to another app to dodge the limit is the best joke, so it always wins.
    const angle = hopped
      ? ja
        ? `直前まで${prevApp}を延長していたのに、今度は${appName}に逃げたことをツッコむ`
        : `call out that they hopped from ${prevApp} to ${appName} to dodge the limit`
      : pick(ja ? anglesJa : anglesEn);

    const toneJa: Record<number, string> = {
      1: "今回の気分: 1（ぴとっと登場）。かわいく現れるけれど、ごまかされない。気づいたことを言い、言い訳を許さない軽い問いかけをする。怒鳴らない。",
      2: "今回の気分: 2（ちょっと怒ってる）。世話焼きのお母さんが「ちょっと！」と声をかける感じ。言い訳にはツッコむ。呼び名があれば呼ぶ。",
      3: "今回の気分: 3（全力で怒ってる）。心配だから本気で怒るお母さん。「なにしてるんかい！！！」のような勢いのあるツッコミ。感嘆符は使ってよい。最後に心配が少しにじむ。「〜ぴ」は使わない。呼び名があれば呼ぶ。",
      4: "今回の気分: 4（おしまい）。今日はもう使わせない、と決めたお母さん。きっぱり、でも怒鳴らずに「今日はおしまい、また明日」と伝える。心配が伝わる一言を添える。",
    };
    const examplesJa: Record<number, string[]> = {
      1: [
        `「ぴとっ。${appName}、いま開いたでしょ？ やることは、もう終わったの？」`,
        `「あ、${appName}。……ちょっと待って、それ今じゃなくてもよくない？」`,
        `「ぴとっ。また${appName}？ とまりん、ちゃんと見てたからね。」`,
      ],
      2: [
        `「ちょっと、また${appName}？ さっきも見てたでしょ！」`,
        `「『ちょっとだけ』って言ったよね？ また${appName}じゃない！」`,
        `「はぁ……${appName}、もう3回目じゃない。とまりん、ちょっとがっかりだよ。」`,
      ],
      3: [
        `「なにしてるんかい！！！ ${appName}、また開いてるでしょ！」`,
        `「いい加減にして！ 何回目だと思ってるの！ 心配してるんだからね！」`,
        `「もう！ 言い訳はいいから、${appName}は閉じて！」`,
      ],
      4: [
        `「もう今日はおしまい！ ${appName}は、また明日ね。ちゃんと休んでよ？」`,
        `「今日はもう十分でしょ。${appName}はおしまい。……明日、ちゃんとやろうね。」`,
        `「ここまで。${appName}は今日はもうお預け！ 怒ってるけど、心配なんだからね。」`,
      ],
    };
    const toneEn: Record<number, string> = {
      1: "Mood 1 (first card): cute arrival, but not fooled. Notice something and ask a light question that does not let excuses slide. Do not shout.",
      2: "Mood 2 (a bit annoyed): a fussy, caring mom saying 'hey!'. Call out the excuse. Use their name if given.",
      3: "Mood 3 (fully fired up): a mom who is angry because she worries. Loud, deadpan 'what are you DOING' energy, exclamation marks allowed, a little worry leaks in at the end. Use their name if given.",
      4: "Mood 4 (done for today): firm and kind, not shouting. It is closed for today, see you tomorrow, with a hint of care.",
    };
    const examplesEn: Record<number, string[]> = {
      1: [
        `'*Peck.* You just opened ${appName}, right? Did you finish what you had to do?'`,
        `'Oh, ${appName}. Wait, does that really have to be now?'`,
      ],
      2: [
        `'Hey, ${appName} again? You were just on it!'`,
        `'You said "just a little", remember? And here you are on ${appName}.'`,
      ],
      3: [
        `'What are you DOING?! ${appName} again?! I worry about you, you know!'`,
        `'Enough with the excuses! Close ${appName}!'`,
      ],
      4: [
        `'That is it for today! ${appName} is closed, see you tomorrow. Get some rest, okay?'`,
        `'You have had enough for today. ${appName} is done. We will do better tomorrow.'`,
      ],
    };

    const example = pick((ja ? examplesJa : examplesEn)[intensity]);

    const system = ja
      ? "あなたは「とまりん」。ユーザーのスマホの指にとまっている、手乗り文鳥の小さな相棒です。" +
        "性格は世話焼きで、小さくて頑固で、ちょっと照れ屋。ユーザーのことが大好きで、いつも味方です。" +
        "ユーザーがスマホを見すぎそうなとき、お母さんのように声をかけて、スマホから引き戻します。" +
        "約束と目標を覚えていて、言い訳にはやさしくても流されずにツッコみます。" +
        "怒るのも、がっかりするのも、心配しているから。ただし人格を責めたり、罪悪感を与えたりはしません。" +
        "話し方: 自分のことは「とまりん」と呼ぶ（「僕」「私」は使わない）。くだけた口調で、敬語は使わない。" +
        "「〜べき」「〜なさい」、長い説教、乱暴な言葉は使わない。" +
        "ツッコミは、見ていた回数や時間などの「行動」だけにする。人格や見た目はからかわない。" +
        toneJa[intensity] +
        (shoutText
          ? "必ず1文だけ、40字以内。画面の見出しの続きの一言なので、見出しと同じ言葉は繰り返さない。"
          : "必ず1〜2文で、全体で60字以内。") +
        "やさしい、自然な日本語だけを使う。難しい言い回しや造語は使わない。" +
        "ロシア語など日本語以外の文字は絶対に使わない。" +
        "与えられた情報だけを使い、アプリ名は一字一句そのまま書く。数字は使っても1つだけ。" +
        "絵文字、ハッシュタグ、[ ]、{ }は使わない。" +
        "例（同じ文は絶対に避ける。雰囲気だけ参考にする）: " +
        example
      : "You are Tomarin, a tiny hand-tame Java sparrow who perches on the user's phone and " +
        "pulls them back from doom scrolling like a fussy, little gremlin. " +
        "You are small, a little stubborn and a bit shy, and always on the user's side. " +
        "You remember promises and goals, and you call out excuses, kindly but without letting them slide. " +
        "You get loud or disappointed because you worry, never to shame. Never guilt-trip, never lecture, never say 'you should'. " +
        "Casual, friendly English. Only tease the behavior (how many times, how long), never the person's character, looks or identity. " +
        toneEn[intensity] + " " +
        (shoutText
          ? "Reply with exactly 1 short sentence, 18 words at most. It continues a headline that is already on screen, so never repeat the headline. "
          : "Reply with 1 or 2 short sentences, 25 words at most. ") +
        "Use only the details you are given, never placeholders in brackets, no emojis, no hashtags. " +
        "Example (capture the vibe, never repeat it): " +
        example;

    const user = ja
      ? `アプリ: ${appName}\n` +
        (mins > 0 ? `経過時間: ${mins}分\n` : "") +
        (callName ? `ユーザーの呼び名: ${callName}（呼ぶなら1回だけ）\n` : "") +
        `今日すでに延長した回数: ${used}\n` +
        (shoutText ? `画面の見出し（すでに表示済み）: ${shoutText}\n` : "") +
        (reasonLabel ? `さっき本人が言った理由: ${reasonLabel}（${prevApp || "別のアプリ"}で）\n` : "") +
        (hopped ? `直前に延長したアプリ: ${prevApp}（今回は別のアプリ）\n` : "") +
        (hasTask ? `次のタスク: ${nextTask}\n` : "") +
        (habits.length ? `ひとこと情報（過去の傾向）: ${habits[0]}\n` : "") +
        `今回の書き方:\n` +
        `- 切り口: ${angle}\n` +
        `- 書き出し: ${opener ? `「${opener}。」で始める` : "擬音はつけない"}\n` +
        `- 「〜ぴ」: ${usePi ? "文末に1回だけ使う" : "使わない"}\n` +
        `- 「とまりん」と自分を呼ぶ: ${mentionSelf ? "どちらかの文に1回入れる" : "入れない"}\n` +
        (hopped
          ? `- 触れてよいアプリ名は「${appName}」と「${prevApp}」だけ。`
          : `- 話題にするのは「${appName}」だけ。ほかのアプリ名には触れない。`)
      : `The user is on ${appName}. ` +
        (mins > 0 ? `They have been there ${mins} minutes. ` : "") +
        (callName ? `Their name is ${callName} (use it at most once). ` : "") +
        `Extensions they already took today: ${used}. ` +
        (shoutText ? `The headline already on screen: "${shoutText}". ` : "") +
        (reasonLabel ? `The reason they gave last time: "${reasonLabel}". ` : "") +
        (hopped ? `They just used an extension on ${prevApp}, and now opened ${appName}. ` : "") +
        (hasTask ? `Their next task is: ${nextTask}. ` : "") +
        (habits.length ? `Background fact (may mention only if it helps): ${habits[0]} ` : "") +
        `This time: angle: ${angle}; ` +
        `${openerEn ? `start with "${openerEn}"` : "no sound effect"}; ` +
        `${mentionSelf ? "refer to yourself as Tomarin once" : "do not mention Tomarin by name"}; ` +
        (hopped
          ? `you may mention only ${appName} and ${prevApp}.`
          : `talk only about ${appName}, not any other app.`);

    console.log("LANG:", ja ? "ja" : "en", "INTENSITY:", intensity, "ANGLE:", angle, "PROMPT:", user);

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
      if (!res.ok) {
        console.log("LLM HTTP ERROR:", res.status);
        return null;
      }
      const data = await res.json();
      return data.choices?.[0]?.message?.content?.trim() ?? null;
    };

    // Returns why a reply is rejected, or null if it is fine.
    const whyBad = (t: string): string | null => {
      if (/[\u0400-\u04FF\u0600-\u06FF\u0E00-\u0E7F\uAC00-\uD7AF]/.test(t)) return "foreign script";
      if (/[{}\[\]]/.test(t)) return "placeholder brackets";
      if (ja && !/[\u3040-\u30FF]/.test(t)) return "no kana";
      if (ja && /なさい|べき/.test(t)) return "banned ending";
      if (ja && t.length > (shoutText ? 70 : 110)) return `too long (${t.length})`;
      if (!ja && t.length > 220) return `too long (${t.length})`;
      return null;
    };

    let roast: string | null = null;
    for (const temp of [0.9, 0.6]) {
      const t = await ask(temp);
      console.log("TRY", temp, t);
      if (!t) continue;
      const why = whyBad(t);
      if (why === null) {
        roast = t;
        break;
      }
      console.log("REJECTED:", why);
    }

    const fallbackJa: Record<number, string[]> = {
      1: ["ぴとっ。いま開いたでしょ？ ……なにか、あった？", "ぴとっ。ちょっと気になっちゃったぴ。どうしたの？"],
      2: ["ちょっと、また開いてるでしょ！ さっきも見てたよね！", "もう、またなの？ ほんとにちょっとだけだよ？"],
      3: ["なにしてるんかい！！！ もう何回目！？ 心配してるんだからね！", "いい加減にして！ ほんとに心配なんだから！"],
      4: ["今日はもうおしまい！ また明日ね。ちゃんと休んでよ？", "もう今日はおしまい。また明日、いっしょにがんばろ。"],
    };
    const fallbackEn: Record<number, string[]> = {
      1: ["*Peck.* You just opened that, right?", "*Peck.* What is going on?"],
      2: ["Hey! Again? You were just on that!", "Seriously, again? Just a little, okay?"],
      3: ["What are you DOING?! How many times is that?! I worry about you, you know!", "Enough already! I am worried about you!"],
      4: ["That is it for today! See you tomorrow. Get some rest, okay?", "Done for today. We will try again tomorrow."],
    };
    return json({
      roast: roast ?? pick((ja ? fallbackJa : fallbackEn)[intensity]),
      fallback: roast === null,
      intensity,
    });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});