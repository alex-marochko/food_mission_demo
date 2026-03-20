import 'package:food_mission_demo/src/app/food_mission_app.dart';
import 'package:food_mission_demo/src/core/localization/app_locale_cubit.dart';
import 'package:food_mission_demo/src/core/localization/app_locale_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeStorage = SharedPreferencesAppLocaleStorage(
    SharedPreferencesAsync(),
  );
  final initialLocale = await localeStorage.load() ?? AppLocaleOption.ukrainian;

  runApp(
    FoodMissionApp(initialLocale: initialLocale, localeStorage: localeStorage),
  );
}
