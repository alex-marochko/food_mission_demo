# Food Mission Demo

Flame-powered Flutter demo for a gamified e-com mini-game.

## Concept

The player drags a bowl horizontally and catches only the emoji that match the active mission:

- `Вітамінізація`
- `Поїж нормально`
- `Бувай, дієта`
- `Перекус в дорозі`
- `Сніданок`
- `Каво-брейк`

Each session lasts 20 seconds. Correct catches grow the combo and increase score. Wrong catches break the combo and subtract points.

## Stack

- `Flutter`
- `Flame`
- `flutter_bloc`
- `equatable`

## Structure

- `lib/src/features/food_mission/domain` - mission definitions and emoji catalog
- `lib/src/features/food_mission/application` - session state and scoring rules
- `lib/src/features/food_mission/presentation/game` - Flame scene and falling emoji loop
- `lib/src/features/food_mission/presentation/widgets` - promo shell UI

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

- Add reward reveal flow after `won`
- Replace fallback emoji fonts with bundled `Noto Color Emoji`
- Add audio/haptics hooks
- Tune spawn balance per mission
- Add analytics events for mission start, catch, streak, finish
