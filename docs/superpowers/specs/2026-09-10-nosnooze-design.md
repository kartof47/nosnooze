# NoSnooze — Design

**Date:** 2026-09-10
**Platform:** iPhone, iOS 26+
**Stack:** Swift, SwiftUI, AlarmKit, SwiftData, Vision, Speech

## What it is

NoSnooze is an alarm clock you can't sleep through. When an alarm rings, the only
way to end it is to complete a **mission** — do push-ups, photograph something,
read a line aloud, or solve a puzzle. Every morning you win extends your
**streak**.

## Goals

- An alarm that rings reliably: on silent, in Focus, with the app closed.
- No way to silence the alarm without completing a mission.
- A daily win/loss record that motivates consistency.
- Zero running cost: no server, no account, no paid services.

## Non-goals (v1)

- App blocking (requires a paid Apple Developer membership).
- Home-screen widgets (require App Groups, paid membership only).
- Cloud sync, social features, Android.
- Escalating mission difficulty and a photo journal (candidates for v2).

## 1. Alarm loop

Alarms are scheduled with **AlarmKit**, so the system rings them — they break
through silent mode and Focus and fire even if the app was force-quit.

Each alarm's alert has two buttons:

- **Start mission** — opens the app on the mission screen.
- **Stop** — runs a custom stop intent. If no mission has been completed for this
  alarm, it schedules a one-off **re-ring 60 seconds later**. This repeats until a
  mission is completed.

On mission completion:

1. Cancel all pending re-rings for this alarm.
2. Record the wake-up (timestamp, mission type) for the streak engine.
3. If "Still awake?" is enabled, schedule a check alarm **5 minutes** later. Its
   Stop button simply ends it — a single tap proves you're up.

**Safety valve.** If a mission cannot be completed (camera fails, room too dark,
microphone denied), a "Switch to math" option appears after **2 minutes** of the
mission screen being open. The user can never be trapped by a ringing alarm.

**Lock-in.** Within **4 hours** before an alarm, disabling it, deleting it, or
moving it later is allowed but records that morning as a **loss**, after a
confirmation dialog.

**Risk (verified first).** The design depends on the custom stop intent being
able to schedule a new alarm. Step 1 of the build is a throwaway test app that
proves this on a real device before anything else is built.

## 2. Missions

All recognition runs on-device; no data leaves the phone.

| Mission | How it's verified | Default |
|---|---|---|
| Push-ups | Front camera + Vision human body-pose; a rep = shoulders dip below a threshold relative to wrists, then return above it | 10 reps |
| Photo: item | Random item from a list Vision's image classifier recognises well (cup, shoe, toothbrush, book…); pass if the label appears with confidence ≥ 0.3 | — |
| Photo: sky | Classifier label "sky" | — |
| Photo: bed | Classifier label "bed" (cannot verify it is made — accepted limitation) | — |
| Read aloud | On-device speech recognition; pass if ≥ 80% of the target words are recognised in order | Built-in affirmations, quotes, Bible verses |
| Math | N arithmetic problems; wrong answer resets that problem | 3 problems, medium |

Each alarm stores its mission type and settings. "Random" picks a mission type at
ring time.

## 3. Streaks and progress

- A morning is **won** if a mission is completed within **15 minutes** of the
  scheduled alarm time. Otherwise it is **lost**.
- Days with no scheduled alarm are **rest days**: they neither extend nor break
  the streak.
- **Streak freezes:** earn 1 for every 7 consecutive won mornings; hold at most 2.
  A freeze is consumed automatically on a lost morning and the streak survives.
- **Bedtime reminder:** a local notification at alarm time minus the user's sleep
  goal (default 8 h), shown on the home screen as "Bed by 10:30 PM".

**Achievements** (streak milestones): First Light (1), Three-peat (3),
Full Week (7), Fortnight (14), Month Strong (30), Quarter (90), Year One (365).

**Screens:** Home (next alarm, bed-by time, streak, week strip) · Alarms list ·
Alarm editor (time, repeat days, mission, label) · Mission screens ·
History (calendar of wins/losses/rest days/freezes) · Achievements · Settings.

## 4. Visual style

Dark and minimal: true-black background, one bright accent colour, very large
time numerals, SF Pro Rounded. Built to be comfortable to look at at 6 AM.

## 5. Data (SwiftData, local only)

- `AlarmSpec` — id, hour, minute, repeat weekdays, label, mission type + settings,
  enabled, AlarmKit alarm id.
- `WakeLog` — date, alarm id, scheduled time, completed time, mission type,
  outcome (won / lost / rest / frozen).
- `StreakState` — current streak, best streak, freezes held (derived from
  `WakeLog` and cached).

The streak engine is a pure function of `[WakeLog]` → `StreakState`, so it is
unit-testable without a device.

## 6. Build and install (no Mac)

1. Public GitHub repo. The Xcode project is generated from `project.yml` by
   **XcodeGen** on the build machine — no `.xcodeproj` is edited by hand.
2. A GitHub Actions workflow on a free `macos` runner generates the project,
   runs unit tests on the iOS simulator, and builds an **unsigned `.ipa`**
   uploaded as a workflow artifact.
3. The user downloads the `.ipa` on Windows and installs it with **Sideloadly**
   using a free Apple ID. Free signing expires after 7 days; Sideloadly
   re-signs automatically.

## 7. Testing

- **Unit tests (CI, simulator):** streak engine (wins, losses, rest days,
  freezes, lock-in penalties), push-up rep counter (fed recorded joint
  sequences), read-aloud matcher, math generator.
- **Device tests (manual, iPhone 13 on iOS 26):** alarm rings on silent with
  app closed; Stop re-rings; each mission completes; "Still awake?" fires.

## 8. Build order

1. **Spike:** one hard-coded alarm + custom stop intent that re-rings. Install via
   the full pipeline. Go/no-go for the design.
2. Alarm model, editor, scheduling, lock-in.
3. Missions: math → read aloud → photo → push-ups.
4. Streak engine, history, achievements, freezes, bedtime reminder.
5. "Still awake?" check, visual polish.
