import 'package:flutter_test/flutter_test.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_cubit.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';

void main() {
  group('MissionSessionCubit', () {
    test('starts in intro state for level one', () {
      final cubit = MissionSessionCubit();

      expect(cubit.state.status, MissionSessionStatus.intro);
      expect(cubit.state.level.number, 1);
      expect(cubit.state.level.mission.id, 'goodbye_diet');
      expect(cubit.state.remainingSeconds, 20);
      expect(cubit.state.totalScore, 0);
      expect(cubit.state.pendingAwardScore, 0);
      expect(cubit.state.goalLocked, isFalse);
    });

    test('starts current level and builds combo score for targets', () {
      final cubit = MissionSessionCubit()..startCurrentLevel();

      cubit.registerCatch(isTarget: true);
      cubit.registerCatch(isTarget: true);
      cubit.registerCatch(isTarget: true);

      expect(cubit.state.status, MissionSessionStatus.playing);
      expect(cubit.state.score, 42);
      expect(cubit.state.combo, 3);
      expect(cubit.state.bestCombo, 3);
      expect(cubit.state.caughtTargets, 3);
    });

    test('wrong catch resets combo and cannot push score below zero', () {
      final cubit = MissionSessionCubit()..startCurrentLevel();

      cubit.registerCatch(isTarget: true);
      cubit.registerCatch(isTarget: false);

      expect(cubit.state.score, 2);
      expect(cubit.state.combo, 0);
      expect(cubit.state.caughtDistractors, 1);
    });

    test('locks the goal when enough score is reached, but keeps playing', () {
      final cubit = MissionSessionCubit()..startCurrentLevel();

      while (cubit.state.status == MissionSessionStatus.playing) {
        cubit.registerCatch(isTarget: true);
        if (cubit.state.goalLocked) {
          break;
        }
      }

      expect(cubit.state.status, MissionSessionStatus.playing);
      expect(cubit.state.goalLocked, isTrue);
      expect(cubit.state.score, greaterThanOrEqualTo(cubit.state.level.goalScore));
      expect(cubit.state.pendingAwardScore, 0);
    });

    test('goal lock prevents dropping below goal score', () {
      final cubit = MissionSessionCubit()..startCurrentLevel();

      while (!cubit.state.goalLocked) {
        cubit.registerCatch(isTarget: true);
      }

      cubit.registerCatch(isTarget: false);

      expect(cubit.state.goalLocked, isTrue);
      expect(cubit.state.score, cubit.state.level.goalScore);
    });

    test('opens next level intro after a win', () {
      final cubit = MissionSessionCubit();

      cubit.openNextLevelIntro();

      expect(cubit.state.status, MissionSessionStatus.intro);
      expect(cubit.state.level.number, 2);
      expect(cubit.state.level.mission.id, 'proper_meal');
      expect(cubit.state.remainingSeconds, 21);
    });

    test('wins on timer end when goal was previously locked', () {
      final cubit = MissionSessionCubit()..startCurrentLevel();

      while (!cubit.state.goalLocked) {
        cubit.registerCatch(isTarget: true);
      }

      cubit.finishLevelFromTimer();

      expect(cubit.state.status, MissionSessionStatus.won);
      expect(cubit.state.remainingSeconds, 0);
      expect(cubit.state.pendingAwardScore, cubit.state.score);
    });

    test('marks level as lost when timer ends before goal', () {
      final cubit = MissionSessionCubit()..startCurrentLevel();

      cubit.finishLevelFromTimer();

      expect(cubit.state.status, MissionSessionStatus.lost);
      expect(cubit.state.remainingSeconds, 0);
    });

    test('commits pending level score into total score on next level intro', () {
      final cubit = MissionSessionCubit()..startCurrentLevel();

      while (!cubit.state.goalLocked) {
        cubit.registerCatch(isTarget: true);
      }
      cubit.finishLevelFromTimer();

      final levelScore = cubit.state.score;
      cubit.openNextLevelIntro();

      expect(cubit.state.status, MissionSessionStatus.intro);
      expect(cubit.state.level.number, 2);
      expect(cubit.state.totalScore, levelScore);
      expect(cubit.state.pendingAwardScore, 0);
    });

    test('retry after win does not duplicate total score', () {
      final cubit = MissionSessionCubit()..startCurrentLevel();

      while (!cubit.state.goalLocked) {
        cubit.registerCatch(isTarget: true);
      }
      cubit.finishLevelFromTimer();

      cubit.retryLevel();

      expect(cubit.state.status, MissionSessionStatus.playing);
      expect(cubit.state.totalScore, 0);
      expect(cubit.state.pendingAwardScore, 0);
      expect(cubit.state.score, 0);
    });
  });
}
