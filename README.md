# Food Mission Demo

Flame-powered Flutter demo for a gamified e-com mini-game.

## Concept

The demo is now structured as a `90`-level campaign:

- missions rotate between `Бувай, дієта`, `Поїж нормально`, and `Вітамінізація`
- level duration starts at `20s` and grows by `+1s` per level
- spawn pacing is organized into repeating `20s` waves with a peak at second `13`
- level start and level result are handled by popups on top of the game board
- reaching the goal activates a goal lock, but the level still plays until the timer ends

Full progression and balancing rules are documented in [docs/level_progression.md](docs/level_progression.md).

## Stack

- `Flutter`
- `Flame`
- `flutter_bloc`
- `equatable`

## Structure

- `lib/src/features/food_mission/domain` - mission definitions and emoji catalog
- `lib/src/features/food_mission/application` - session state, level flow, scoring rules
- `lib/src/features/food_mission/presentation/game` - Flame scene and deterministic spawn playback
- `lib/src/features/food_mission/presentation/widgets` - board overlays and popups

## Run

```bash
flutter run -d chrome
```

## Verify

```bash
flutter test
flutter build web
```

## Next polish ideas

- Add audio cues for correct / wrong catches and collision taps
- Polish the success popup with richer Flutter animations
- Replace fallback emoji fonts with bundled `Noto Color Emoji`
- Add analytics events for level start, catch, streak, finish
