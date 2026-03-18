# Food Mission Level Progression

## Core Loop

- The game has `90` sequential levels.
- Only the game board is visible during normal play.
- At the start of the game and before each level, an intro popup explains:
  - the level number
  - the active mission
  - the short rules
  - the target emoji set for that mission
- At the end of each level:
  - success popup: congratulates the player and offers `Retry` or `Next level`
  - failure popup: shows a sad state and offers `Retry`
  - success popup includes both `level score` and `total score`
  - the success popup uses a staged native Flutter animation where the level score transfers into the total score

## Mission Rotation

Levels rotate through missions in this exact order:

1. `Бувай, дієта`
2. `Поїж нормально`
3. `Вітамінізація`

The first level always starts with `Бувай, дієта`.

## Level Duration

- Level `1` lasts `20s`
- Each next level adds `+1s`
- Formula: `durationSeconds = 19 + levelNumber`

Examples:

- `1 -> 20s`
- `21 -> 40s`
- `90 -> 109s`

## Wave Model

Spawn pacing is driven by repeating `20s` waves:

- each wave starts calmer
- spawn intensity ramps up
- peak intensity happens at local wave second `13`
- spawn intensity then eases down until local wave second `20`

Longer levels contain multiple full waves plus a final partial wave if needed.

The implementation uses a deterministic spawn timeline rather than open-ended random intervals, so each level has a known number of target and distractor spawns.

## Scoring

- correct catch:
  - increases combo by `1`
  - grants `12 + min((combo - 1) * 2, 8)` points
- wrong catch:
  - subtracts `10` points, clamped at `0`
  - resets combo to `0`
- missed items currently do not apply a score penalty

The effective correct-catch sequence is:

- combo `1 -> 12`
- combo `2 -> 14`
- combo `3 -> 16`
- combo `4 -> 18`
- combo `5+ -> 20`

## Win Condition

- Reaching the goal score activates a `goal lock`.
- The level still continues until the timer ends.
- Once `goal lock` is active, the player can no longer lose the level.
- Wrong catches still reset combo, but the score floor is locked at the goal score.
- When the timer ends:
  - `goal lock == true` -> `won`
  - otherwise -> `lost`

## Spawn Balance

Each level plan is deterministic and includes:

- duration
- mission
- goal score
- total spawn count
- exact target count
- exact distractor count
- exact spawn timestamps
- exact target/distractor ordering

The balance rules are:

- target share decreases smoothly from easier early levels to harder late levels
- spare target capacity decreases smoothly across the campaign
- level `90` has exactly enough target spawns to reach the goal with perfect play and full combo conversion

This means:

- early levels allow mistakes and still remain winnable
- late levels become increasingly strict
- level `90` is effectively a near-perfect execution challenge

Special case for level `1`:

- total spawn count is increased to `22`
- target share is reduced to about `0.58`
- this makes the first level more attentive without changing the core rules

## HUD

The in-board HUD uses pill badges for:

- `Рівень`
- `Місія`
- `Очки`
- `Ціль`
- `Час`
- `Комбо`

These badges scale proportionally with the board size.

## Catcher Feedback

The catcher is rendered as a single `🛒` icon with short feedback states:

- success catch: stronger green flash
- wrong catch: stronger red flash
- brief scale pulse on both

## Win Popup Animation

The win popup demonstrates native Flutter animation capabilities using:

- `AnimationController`
- `CurvedAnimation`
- `Tween`
- `IntTween`
- `AnimatedBuilder`

Sequence:

1. popup enters
2. level score counts up
3. level score visually flies toward total score
4. source score fades out
5. total score counts up by the awarded amount

## Architecture Notes

The level system is implemented with a clean split:

- `domain`
  - mission catalog
  - level definition
  - deterministic level planner
- `application`
  - session state
  - level flow
  - retry / next level transitions
- `presentation`
  - board-only shell
  - intro/result popups
  - Flame scene and spawn playback

## Testing Expectations

The level system should be covered by tests for:

- mission rotation
- duration formula
- goal-lock behavior
- exact final-level target sufficiency
- spawn timeline ordering
- first-level balance override
- retry and next-level transitions
