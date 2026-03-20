import 'package:food_mission_demo/src/core/localization/app_locale_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppLocaleStorage {
  const AppLocaleStorage();

  Future<AppLocaleOption?> load();

  Future<void> save(AppLocaleOption locale);
}

class SharedPreferencesAppLocaleStorage extends AppLocaleStorage {
  const SharedPreferencesAppLocaleStorage(this._preferences);

  static const _languageCodeKey = 'app_locale.language_code';

  final SharedPreferencesAsync _preferences;

  @override
  Future<AppLocaleOption?> load() async {
    final languageCode = await _preferences.getString(_languageCodeKey);
    return AppLocaleOptionX.fromLanguageCode(languageCode);
  }

  @override
  Future<void> save(AppLocaleOption locale) {
    return _preferences.setString(_languageCodeKey, locale.languageCode);
  }
}

class NoopAppLocaleStorage extends AppLocaleStorage {
  const NoopAppLocaleStorage();

  @override
  Future<AppLocaleOption?> load() async => null;

  @override
  Future<void> save(AppLocaleOption locale) async {}
}
