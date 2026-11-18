# ゆびとまれ (Yubitomare)

**A tiny bird lands on your screen when you open a distracting app, and talks you out of doomscrolling the way a friend would.**

Yubitomare is an Android app that guards the apps you choose. When you open one, a small hand-tame Java sparrow named **とまりん (Tomarin)** lands on top of it, notices what is happening, and asks you to stop. If you want more time, you have to negotiate: give Tomarin an honest reason first. Tomarin never guilt-trips and never punishes you with loss. It stays firm about the limit and stays kind about you.

> 止まれ means both "stop" and "perch". The verb つつく means both "peck" and "nag". Hence a bird.

<!-- Add screenshots here: intercept card (soft / annoyed / furious / closed), negotiation, focus session, Today tab -->

---

## Why this exists

Most screen-time tools fail in one of two ways: they are easy to dismiss, or they shame you into deleting them. Built-in tools already show you your numbers, so numbers alone don't change behavior.

Yubitomare tries a different approach:

- **Friction at the moment of the urge.** The card appears over the guarded app itself, and extensions cost a countdown plus an honest reason.
- **Ask why, don't scold.** Every extension is logged with a reason (tired, bored, opened without noticing, notification). Tomarin uses it later, like a friend who remembers.
- **A relationship instead of a score.** Progress is a **Bond (絆)** bar that only goes up. There is no starving or dying pet, and no shame over a broken streak.
- **A daily budget that actually ends.** Three extensions a day, shared across all guarded apps, then the app is closed until 6:00 the next morning.

## Features

### Interception
- A foreground service watches which app is in front (`UsageStatsManager`, polled every 2 s).
- When a guarded app opens, a full-screen Flutter card is launched over it.
- The card has four moods depending on how many extensions you have used today: **soft** (ぴとっ) → **annoyed** → **furious** → **closed for today**.
- Extension buttons (5 / 10 / 15 min, capped by your setting) are locked behind a countdown that grows with the length of the extension and with each extension already used.
- If the Flutter card fails to appear within 5 s (some phones block it), a plain native overlay takes over, so the guard never silently fails.
- Leaving without answering (home, recents, screen off) is logged as "left" and resets the visit.

### Negotiation and check-ins
- Tapping an extension opens a negotiation screen. You must choose one honest reason before Tomarin agrees.
- The reason is stored and fed back into the next card's line ("you said you were tired, but…").
- Hopping to a different app to dodge the limit is detected and called out.
- A quiet **"I've felt heavy for a while"** button opens a calm support screen with free Japanese helplines (よりそいホットライン, #いのちSOS). Nothing on that screen is saved, scored, or remembered.

### AI-written lines
- The line under the card's headline is written by an LLM through a Supabase Edge Function (`supabase/functions/intervene`).
- The prompt carries the app, the mood, the user's chosen name and suffix, the next task, one recent habit, and the last reason given.
- Replies are validated (length, banned endings like 〜なさい / 〜べき, stray scripts, leftover placeholders), retried once, and fall back to hand-written lines. A 6 s client timeout keeps the fixed text if the network is slow.
- Roasts only target behavior ("that's the third time"), never the person.

### Focus sessions
- Start from a task or a one-line goal. The screen goes dark and Tomarin rests while a timer runs.
- Random **presence checks** ("ぴ？ いる？", with a soft vibration) make sure you didn't just walk away. Only confirmed time counts.
- Long-press to finish. A post-session "contact book" asks what you did and how well it went, and Tomarin replies in red pen.

### Bond (絆)
- Five levels: はじめまして → なかよし → ともだち → しんゆう → ずっとなかま.
- Bond grows from focus minutes, finished tasks, and honest check-ins, with daily caps so it can't be farmed. It never goes down.

### Everything else
- Today tab with tasks, Bond branch (Tomarin sits further along as the bond grows), and permission/status strip.
- Record tab with this week's focus time and the latest notes.
- Japanese and English UI (ARB files), following the device language with a manual override.
- Tomarin calls you by the name and suffix you choose (さん / くん / ちゃん / none).
- Hidden developer page (long-press the logo): permissions, tracker start/stop, intercept preview, roast tester, pet memory.

## Tomarin's character

Tomarin is a caring meddler (世話焼き): small, stubborn, and a little shy. It speaks casual Japanese, refers to itself as 「とまりん」, and ends roughly one line in three with 〜ぴ. For rare serious moments it drops 〜ぴ entirely and speaks plainly.

Tomarin **never** guilt-trips, shames, compares you with other users, lectures, or jokes about you as a person. The full character sheet (voice, states, Bond levels, visual direction, back-burner ideas) lives in the project files.

## Tech stack

| Layer | Technology |
| --- | --- |
| UI | Flutter (Material 3), `google_fonts`, `flutter_localizations` / `intl` |
| Native tracking | Kotlin: `TrackerService` (foreground service), `InterceptOverlay` (fallback card), `InterceptBridge` |
| Flutter ↔ Android | `MethodChannel('detox_pet/usage')` |
| Local storage | `shared_preferences` (the Kotlin service reads and writes the same preferences file) |
| AI lines | Supabase Edge Function (Deno) calling any OpenAI-compatible `/chat/completions` endpoint |
| Misc | `wakelock_plus` (focus screen), `http` |

### How the pieces fit

```
TrackerService (Kotlin, foreground)
  polls usage events every 2 s
  guarded app opened?
      └─ starts MainActivity with intercept_* extras
             └─ HomeShell picks up the request (getPendingIntercept)
                    └─ InterceptScreen  ──►  NegotiationScreen
                           │                      │
                           └── back / pass / left ┘
                                   │
                    interceptDone ► InterceptBridge ► TrackerService
                    (logs outcome, sets pass timer, sends user home)
```

Settings, the intercept log, and the "caught scrolling" log are shared through `FlutterSharedPreferences`, so Flutter and the Kotlin service see the same data without a database.

## Project structure

```
lib/
  main.dart                 app entry, locale wiring
  bond.dart                 Bond points, levels, daily caps
  storage.dart              tasks, check-ins, plans (shared_preferences)
  tracker_config.dart       guarded apps, threshold, language, name/suffix
  intercept_log.dart        reads the log the Kotlin service writes
  memory.dart               short habit facts fed to the AI prompt
  checkin.dart              check-in / plan / "what's hard" option sets
  roast_api.dart            client for the Supabase function
  focus_log.dart            focus session history
  settings_screen.dart      language, name, threshold, guarded apps
  debug_page.dart           developer tools
  l10n/                     app_en.arb, app_ja.arb (+ generated code)
  ui/
    home_shell.dart         tabs + incoming intercept requests
    today_screen.dart       tasks, Bond branch, status
    intercept_screen.dart   the card (soft / annoyed / furious / closed)
    negotiation_screen.dart honest-reason step before an extension
    crisis_screen.dart      calm support screen with helplines
    focus_start_screen.dart / focus_session_screen.dart / summary_screen.dart
    record_screen.dart      weekly record
    tomarin_ui.dart         sprite widget, speech bubble, paper-card widgets
    theme.dart              "warm paper" design tokens
android/app/src/main/kotlin/com/example/detox_pet/
  MainActivity.kt           method channel, pending intercept hand-off
  TrackerService.kt         foreground service and intercept logic
  InterceptOverlay.kt       native fallback card
  InterceptBridge.kt        service ↔ activity result hand-off
supabase/functions/intervene/index.ts   LLM line generator
```

## Getting started

### Requirements
- Flutter (stable channel, recent enough for the `pubspec.lock`) and an Android SDK
- JDK 17
- A physical **Android** phone (interception relies on usage access and overlays, which an emulator handles poorly)
- Optional: a [Supabase](https://supabase.com) project and an OpenAI-compatible LLM endpoint for the AI-written lines

### Run the app

```bash
flutter pub get
flutter run
```

Localization code is generated automatically (`flutter: generate: true`).

### Grant permissions
On first launch the Today tab shows a **Permission missing** strip. Tap **Fix** and grant:

1. **Usage access**: lets the service see which app is in front.
2. **Display over other apps**: lets the card appear on top of a guarded app.
3. **Notifications** (Android 13+).

On Xiaomi / MIUI / HyperOS phones, you may also need to enable **"Display pop-up windows while running in the background"** for the app, otherwise the card may not appear.

Then open Settings (the person icon), pick the apps to guard, and tap **Resume** on the Today tab to start the guard.

### Set up the AI lines (optional)
Without a backend the app still works: cards keep their built-in text.

1. Deploy the function:
   ```bash
   supabase functions deploy intervene
   ```
2. Set its secrets:
   ```bash
   supabase secrets set \
     LLM_BASE_URL=https://your-provider.example/v1 \
     LLM_API_KEY=your-key \
     LLM_MODEL=your-model \
     LLM_MODEL_JA=your-japanese-capable-model   # optional, used for Japanese
   ```
3. Replace `supabaseUrl` and `supabaseAnonKey` in `lib/roast_api.dart` with your own project's values.

### Tuning knobs
| Where | What |
| --- | --- |
| `TrackerService.kt` → `DAILY_PASSES`, `PASS_OPTIONS`, `WAIT_SECONDS`, `DAY_STARTS_AT`, `BUDGET_PER_APP` | Extension budget and countdowns |
| `intercept_log.dart` | Must mirror `DAILY_PASSES` and `DAY_STARTS_AT` from the Kotlin file |
| `bond.dart` | Level thresholds, daily caps, points per task / check-in |
| `focus_session_screen.dart` → `kFocusTestMode` | `true`: presence checks every 20–30 s. Set to `false` for real use (every 8–12 min) |
| Settings slider | Alert threshold. 1–2 min is a test mode that checks every 10 s |

## Status

Working prototype, Android only. The interception loop, negotiation, AI lines, Bond, focus sessions, and ja/en localization are in place.

Known gaps:
- Tomarin's art is still placeholder sprites for some poses (a placeholder bird shows when a file is missing).
- Release builds are signed with the debug key and use the `com.example` application ID.
- iOS, web, and desktop folders exist only as Flutter scaffolding. The tracker uses Android-specific APIs.
- No automated tests yet.

## Roadmap

- Onboarding for permissions and name / suffix selection
- Souvenirs and the 図鑑 (picture book) tied to Bond levels
- Home-screen widget
- Final Tomarin art and per-user colour variants
- iPhone support

Back burner: dialect packs (関西弁 first), outfits (着せ替え), friend focus sessions, sticker exports.

## Design principles

1. **Friend, not warden.** Observe, ask, plan the next step together.
2. **Reward honesty over perfection.** Admitting a slip is worth more than hiding it.
3. **No punishment by loss.** Bond never decreases.
4. **Tease the behavior, never the person.**
5. **Serious moments are serious.** When something sounds bigger than scrolling, Tomarin drops the act and points to real support.

## License

Not yet chosen. All rights reserved until a license is added.