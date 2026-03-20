import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_mission_demo/src/core/theme/app_theme.dart';
import 'package:food_mission_demo/src/core/localization/app_locale_cubit.dart';
import 'package:food_mission_demo/src/core/localization/app_strings.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_cubit.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/food_mission_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FoodMissionApp extends StatelessWidget {
  const FoodMissionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppLocaleCubit()),
        BlocProvider(create: (_) => MissionSessionCubit()),
      ],
      child: BlocBuilder<AppLocaleCubit, AppLocaleOption>(
        builder: (context, localeOption) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: localeOption.locale,
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: const [
              AppStrings.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            onGenerateTitle: (context) => context.strings.appTitle,
            theme: buildAppTheme(),
            home: const FoodMissionScreen(),
          );
        },
      ),
    );
  }
}
