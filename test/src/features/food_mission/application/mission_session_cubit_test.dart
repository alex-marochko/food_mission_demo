import 'package:flutter_test/flutter_test.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_cubit.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_catalog.dart';

void main() {
  group('MissionSessionCubit', () {
    test('starts in ready state with initial mission', () {
      final cubit = MissionSessionCubit();

      expect(cubit.state.status, MissionSessionStatus.ready);
      expect(cubit.state.selectedMission, MissionCatalog.initialMission);
      expect(
        cubit.state.remainingSeconds,
        MissionCatalog.initialMission.durationSeconds,
      );
    });

    test('builds combo and score for target catches', () {
      final cubit = MissionSessionCubit()..startSession();

      cubit.registerCatch(isTarget: true);
      cubit.registerCatch(isTarget: true);
      cubit.registerCatch(isTarget: true);

      expect(cubit.state.score, 42);
      expect(cubit.state.combo, 3);
      expect(cubit.state.bestCombo, 3);
      expect(cubit.state.caughtTargets, 3);
    });

    test('wrong catch resets combo and cannot push score below zero', () {
      final cubit = MissionSessionCubit()..startSession();

      cubit.registerCatch(isTarget: false);

      expect(cubit.state.score, 0);
      expect(cubit.state.combo, 0);
      expect(cubit.state.caughtDistractors, 1);
    });

    test('finishes with won status when goal achieved', () {
      final cubit = MissionSessionCubit()..startSession();

      for (var index = 0; index < 8; index++) {
        cubit.registerCatch(isTarget: true);
      }

      cubit.finishSession();

      expect(cubit.state.status, MissionSessionStatus.won);
      expect(cubit.state.remainingSeconds, 0);
    });
  });
}
