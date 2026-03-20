import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class AppStrings {
  const AppStrings();

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static const supportedLocales = [Locale('uk'), Locale('en')];

  static AppStrings of(BuildContext context) {
    final strings = Localizations.of<AppStrings>(context, AppStrings);
    assert(strings != null, 'AppStrings is not available in the context.');
    return strings!;
  }

  String get appTitle;
  String get languageUaShort;
  String get languageEnShort;
  String get debugIntroPopup;
  String get debugWinPopup;
  String get debugLosePopup;
  String get debugPausePopup;
  String get hudLevel;
  String get hudMission;
  String get hudScore;
  String get hudGoal;
  String get hudTime;
  String get hudCombo;
  String get introInstructions;
  String get introTargetsLabel;
  String get popupGoal;
  String get popupTime;
  String get popupSpawn;
  String get startLevel;
  String get nextLevel;
  String get backToLevelOne;
  String get winSubtitle;
  String get levelScore;
  String get totalScore;
  String get retryLevel;
  String get loseSubtitle;
  String get tryAgain;
  String get pauseTitle;
  String get pauseSubtitle;
  String get continueAction;

  String levelNumber(int level);
  String levelCompleted(int level);
  String levelFailed(int level);
  String secondsCompact(int seconds);
  String missionTitle(String missionId);
  String missionTagline(String missionId);
}

class AppStringsUk extends AppStrings {
  const AppStringsUk();

  @override
  String get appTitle => 'Food Mission Demo';

  @override
  String get languageUaShort => 'UA';

  @override
  String get languageEnShort => 'EN';

  @override
  String get debugIntroPopup => 'Інтро попап';

  @override
  String get debugWinPopup => 'Win попап';

  @override
  String get debugLosePopup => 'Lose попап';

  @override
  String get debugPausePopup => 'Pause попап';

  @override
  String get hudLevel => 'Рівень';

  @override
  String get hudMission => 'Місія';

  @override
  String get hudScore => 'Очки';

  @override
  String get hudGoal => 'Ціль';

  @override
  String get hudTime => 'Час';

  @override
  String get hudCombo => 'Комбо';

  @override
  String get introInstructions =>
      'Лови лише цільові emoji, тримай серію і закривай мету раніше за таймер.';

  @override
  String get introTargetsLabel => 'Усі цільові emoji для цього рівня:';

  @override
  String get popupGoal => 'Ціль';

  @override
  String get popupTime => 'Час';

  @override
  String get popupSpawn => 'Спавн';

  @override
  String get startLevel => 'Почати рівень';

  @override
  String get nextLevel => 'Наступний рівень';

  @override
  String get backToLevelOne => 'На 1 рівень';

  @override
  String get winSubtitle =>
      'Мета закрита. Можна або закріпити результат, або рухатися далі.';

  @override
  String get levelScore => 'Очки за рівень';

  @override
  String get totalScore => 'Загальний рахунок';

  @override
  String get retryLevel => 'Пройти знову';

  @override
  String get loseSubtitle =>
      'Цього разу не вистачило очок. Спробуй ще раз і втримай серію довше.';

  @override
  String get tryAgain => 'Спробувати ще';

  @override
  String get pauseTitle => 'Пауза';

  @override
  String get pauseSubtitle =>
      'Гру призупинено. Можна повернутися до раунду або перезапустити рівень.';

  @override
  String get continueAction => 'Продовжити';

  @override
  String levelNumber(int level) => 'Рівень $level';

  @override
  String levelCompleted(int level) => 'Рівень $level пройдено!';

  @override
  String levelFailed(int level) => 'Рівень $level не закрито';

  @override
  String secondsCompact(int seconds) => '$seconds\u0441';

  @override
  String missionTitle(String missionId) => switch (missionId) {
    'vitamins' => 'Вітамінізація',
    'proper_meal' => 'Поїж нормально',
    'goodbye_diet' => 'Бувай, дієта',
    _ => throw StateError('Unknown mission id: $missionId'),
  };

  @override
  String missionTagline(String missionId) => switch (missionId) {
    'vitamins' =>
      'Фрукти, овочі, зелень і healthy-drinks. Лови вітаміни, не хаос.',
    'proper_meal' =>
      'Ситна їжа, сніданки й домашні страви. Без чітмільних спокус.',
    'goodbye_diet' => 'Фастфуд, десерти, снеки й рідкі калорії. Соромно? Ні.',
    _ => throw StateError('Unknown mission id: $missionId'),
  };
}

class AppStringsEn extends AppStrings {
  const AppStringsEn();

  @override
  String get appTitle => 'Food Mission Demo';

  @override
  String get languageUaShort => 'UA';

  @override
  String get languageEnShort => 'EN';

  @override
  String get debugIntroPopup => 'Intro Popup';

  @override
  String get debugWinPopup => 'Win Popup';

  @override
  String get debugLosePopup => 'Lose Popup';

  @override
  String get debugPausePopup => 'Pause Popup';

  @override
  String get hudLevel => 'Level';

  @override
  String get hudMission => 'Mission';

  @override
  String get hudScore => 'Score';

  @override
  String get hudGoal => 'Goal';

  @override
  String get hudTime => 'Time';

  @override
  String get hudCombo => 'Combo';

  @override
  String get introInstructions =>
      'Catch only target emoji, keep the streak going, and clear the goal before time runs out.';

  @override
  String get introTargetsLabel => 'All target emoji for this level:';

  @override
  String get popupGoal => 'Goal';

  @override
  String get popupTime => 'Time';

  @override
  String get popupSpawn => 'Spawns';

  @override
  String get startLevel => 'Start level';

  @override
  String get nextLevel => 'Next level';

  @override
  String get backToLevelOne => 'Back to level 1';

  @override
  String get winSubtitle =>
      'Goal secured. Lock the result in or move on to the next level.';

  @override
  String get levelScore => 'Level score';

  @override
  String get totalScore => 'Total score';

  @override
  String get retryLevel => 'Play again';

  @override
  String get loseSubtitle =>
      'Not enough points this time. Try again and keep the streak alive longer.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get pauseTitle => 'Paused';

  @override
  String get pauseSubtitle =>
      'The game is paused. Resume the round or restart the level.';

  @override
  String get continueAction => 'Resume';

  @override
  String levelNumber(int level) => 'Level $level';

  @override
  String levelCompleted(int level) => 'Level $level cleared!';

  @override
  String levelFailed(int level) => 'Level $level not cleared';

  @override
  String secondsCompact(int seconds) => '$seconds\u0073';

  @override
  String missionTitle(String missionId) => switch (missionId) {
    'vitamins' => 'Vitamin Boost',
    'proper_meal' => 'Eat Properly',
    'goodbye_diet' => 'Goodbye, Diet',
    _ => throw StateError('Unknown mission id: $missionId'),
  };

  @override
  String missionTagline(String missionId) => switch (missionId) {
    'vitamins' =>
      'Fruits, veggies, greens, and healthy drinks. Catch the vitamins, not the chaos.',
    'proper_meal' =>
      'Hearty meals, breakfasts, and home-style dishes. No cheat-meal temptations.',
    'goodbye_diet' =>
      'Fast food, desserts, snacks, and liquid calories. Guilty? Not really.',
    _ => throw StateError('Unknown mission id: $missionId'),
  };
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => AppStrings.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppStrings> load(Locale locale) {
    final strings = switch (locale.languageCode) {
      'en' => const AppStringsEn(),
      _ => const AppStringsUk(),
    };
    return SynchronousFuture(strings);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}

extension AppStringsContextX on BuildContext {
  AppStrings get strings => AppStrings.of(this);
}
