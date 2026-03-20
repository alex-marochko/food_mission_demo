import 'package:food_mission_demo/src/core/localization/app_locale_cubit.dart';
import 'package:food_mission_demo/src/core/localization/app_locale_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocaleCubit', () {
    test('starts with provided initial locale', () {
      final cubit = AppLocaleCubit(
        initialLocale: AppLocaleOption.english,
        storage: const NoopAppLocaleStorage(),
      );

      expect(cubit.state, AppLocaleOption.english);
    });

    test('persists locale selection', () async {
      final storage = _FakeAppLocaleStorage();
      final cubit = AppLocaleCubit(
        initialLocale: AppLocaleOption.ukrainian,
        storage: storage,
      );

      cubit.select(AppLocaleOption.english);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, AppLocaleOption.english);
      expect(storage.savedLocale, AppLocaleOption.english);
    });
  });
}

class _FakeAppLocaleStorage extends AppLocaleStorage {
  AppLocaleOption? savedLocale;

  @override
  Future<AppLocaleOption?> load() async => savedLocale;

  @override
  Future<void> save(AppLocaleOption locale) async {
    savedLocale = locale;
  }
}
