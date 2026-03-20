import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

enum AppLocaleOption {
  ukrainian('uk'),
  english('en');

  const AppLocaleOption(this.languageCode);

  final String languageCode;

  Locale get locale => Locale(languageCode);
}

class AppLocaleCubit extends Cubit<AppLocaleOption> {
  AppLocaleCubit() : super(AppLocaleOption.ukrainian);

  void select(AppLocaleOption locale) {
    if (state == locale) {
      return;
    }
    emit(locale);
  }
}
