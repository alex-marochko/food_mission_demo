import 'dart:ui';

import 'package:food_mission_demo/src/core/localization/app_locale_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppLocaleOption {
  ukrainian('uk'),
  english('en');

  const AppLocaleOption(this.languageCode);

  final String languageCode;

  Locale get locale => Locale(languageCode);
}

extension AppLocaleOptionX on AppLocaleOption {
  static AppLocaleOption? fromLanguageCode(String? languageCode) {
    for (final option in AppLocaleOption.values) {
      if (option.languageCode == languageCode) {
        return option;
      }
    }
    return null;
  }
}

class AppLocaleCubit extends Cubit<AppLocaleOption> {
  AppLocaleCubit({
    required AppLocaleOption initialLocale,
    required AppLocaleStorage storage,
  }) : _storage = storage,
       super(initialLocale);

  final AppLocaleStorage _storage;

  void select(AppLocaleOption locale) {
    if (state == locale) {
      return;
    }
    emit(locale);
    _storage.save(locale);
  }
}
