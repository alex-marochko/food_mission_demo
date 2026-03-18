import 'package:food_mission_demo/src/core/theme/app_theme.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_cubit.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/food_mission_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FoodMissionApp extends StatelessWidget {
  const FoodMissionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MissionSessionCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Food Mission Demo',
        theme: buildAppTheme(),
        home: const FoodMissionScreen(),
      ),
    );
  }
}
