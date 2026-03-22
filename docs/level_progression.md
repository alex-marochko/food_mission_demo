# Food Mission Level Progression

## Core Loop

- The game contains `90` sequential levels.
- Normal play shows only the board, HUD pills, language switcher, and popup overlays when needed.
- Every level starts with an intro popup that explains:
  - level number
  - active mission
  - short instructions
  - all target emoji for that level
- Every finished level ends in one of two result states:
  - win popup with `Retry` and `Next level`
  - lose popup with `Retry`
- There is also a pause popup that can be opened with `Esc` or by focus loss.

## Mission Rotation

Levels rotate in this exact order:

1. `Бувай, дієта`
2. `Поїж нормально`
3. `Вітамінізація`

Level `1` always starts with `Бувай, дієта`.

## Level Duration

- level `1` lasts `20s`
- each next level adds `+1s`
- formula: `durationSeconds = 19 + levelNumber`

Examples:

- `1 -> 20s`
- `21 -> 40s`
- `90 -> 109s`

## Wave Model

Spawn pacing is deterministic and organized into repeating `20s` waves.

Each wave:

- starts calmer
- ramps up in intensity
- peaks at local second `13`
- eases down by local second `20`

Longer levels contain multiple full waves plus a final partial wave.

The planner builds an exact spawn timeline for every level, including:

- total spawn count
- exact target count
- exact distractor count
- exact timestamps
- exact target/distractor ordering

## Scoring

- correct catch:
  - combo `+1`
  - score: `12 + min((combo - 1) * 2, 8)`
- wrong catch:
  - `-10` score, clamped at `0`
  - combo reset to `0`
- missed items do not currently subtract score

Effective score ramp for correct streaks:

- combo `1 -> 12`
- combo `2 -> 14`
- combo `3 -> 16`
- combo `4 -> 18`
- combo `5+ -> 20`

## Goal Lock

- Reaching the goal activates `goal lock`.
- The level does not end early.
- The timer still runs to zero.
- After goal lock:
  - the level can no longer be lost
  - wrong catches still reset combo
  - score is clamped so it cannot fall below the goal score
- When the timer ends:
  - `goalLock == true` -> `won`
  - otherwise -> `lost`

## Spawn Balance

Difficulty scales across the campaign through:

- increasing duration
- changing target share
- changing spare target capacity
- denser later waves and stricter late-level plans

Special early-game override:

- level `1` intentionally has elevated spawn density and lower target share than a naive tutorial level
- this makes the opening level attentive without changing the rules

Late-game constraint:

- level `90` is planned so that perfect play with full combo conversion is required to exactly meet the goal

## Board And Physics

The board uses a fixed aspect ratio and responsive scaling.

Physics currently include:

- downward acceleration
- wall bounces
- obstacle bounces
- food-to-food collisions
- initial angular velocity on spawned food

Board scaling preserves:

- gameplay proportions
- catcher hitbox proportions
- obstacle layout proportions
- effective fall-time feel across board sizes

## HUD

The in-board HUD uses scaling pill badges for:

- `Рівень / Level`
- `Місія / Mission`
- `Очки / Score`
- `Ціль / Goal`
- `Час / Time`
- `Комбо / Combo`

These pills scale proportionally with board size.

## Catcher

The catcher is rendered as a single `🛒` icon.

Feedback states:

- success catch:
  - green flash
  - scale pulse
- wrong catch:
  - red flash
  - scale pulse

## Popups

### Intro Popup

Shows:

- level number
- mission title
- mission tagline
- all target emoji for that level
- goal
- time
- total spawn count

### Win Popup

Shows:

- level score
- combo
- goal
- total score

Animation sequence:

1. popup enters
2. level score counts up
3. awarded score flies toward total score
4. source value fades
5. total score counts up
6. reward sweep shader passes over the total score card

### Lose Popup

Shows:

- current score
- goal
- retry action

### Pause Popup

Shows:

- current score
- goal
- remaining time
- combo
- `Continue`
- `Retry`

## Localization

The app supports:

- Ukrainian
- English

Locale behavior:

- runtime switcher in the upper-left corner
- persisted selection via `shared_preferences`

## Media Assets

- bundled emoji font:
  - `assets/fonts/NotoColorEmoji.ttf`
- catch SFX:
  - `assets/audio/catch_good.wav`
  - `assets/audio/catch_bad.wav`
- reward shader:
  - `shaders/reward_sweep.frag`

## Architecture

### Domain

- `FoodItem`
- `MissionDefinition`
- `MissionCatalog`
- `LevelDefinition`
- `LevelPlanner`

### Application

- `MissionSessionCubit`
- `MissionSessionState`
- retry / next-level transitions
- goal-lock logic
- total score accumulation

### Presentation

- `FoodMissionScreen` as orchestration shell
- `FoodMissionGame` as Flame runtime board
- overlay widgets
- popup layer and popup variants

## Testing

Current automated coverage includes:

- `mission_catalog_test.dart`
- `level_planner_test.dart`
- `mission_session_cubit_test.dart`
- `app_locale_cubit_test.dart`
- `widget_test.dart`

These cover the key behavioral seams:

- mission catalog validity
- level planning rules
- session progression and scoring
- locale persistence
- top-level widget rendering and locale switching
