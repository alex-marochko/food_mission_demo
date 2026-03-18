import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_definition.dart';

class MissionSessionCubit extends Cubit<MissionSessionState> {
  MissionSessionCubit() : super(MissionSessionState.initial());

  void selectMission(MissionDefinition mission) {
    if (state.isPlaying || mission == state.selectedMission) {
      return;
    }

    emit(
      MissionSessionState(
        selectedMission: mission,
        status: MissionSessionStatus.ready,
        score: 0,
        combo: 0,
        bestCombo: 0,
        caughtTargets: 0,
        caughtDistractors: 0,
        remainingSeconds: mission.durationSeconds,
      ),
    );
  }

  void startSession() {
    emit(
      state.copyWith(
        status: MissionSessionStatus.playing,
        score: 0,
        combo: 0,
        bestCombo: 0,
        caughtTargets: 0,
        caughtDistractors: 0,
        remainingSeconds: state.selectedMission.durationSeconds,
      ),
    );
  }

  void restartSession() {
    emit(
      state.copyWith(
        status: MissionSessionStatus.ready,
        score: 0,
        combo: 0,
        bestCombo: 0,
        caughtTargets: 0,
        caughtDistractors: 0,
        remainingSeconds: state.selectedMission.durationSeconds,
      ),
    );
    startSession();
  }

  void registerCatch({required bool isTarget}) {
    if (!state.isPlaying) {
      return;
    }

    if (isTarget) {
      final combo = state.combo + 1;
      final points = 12 + ((combo - 1) * 2).clamp(0, 8);
      emit(
        state.copyWith(
          score: state.score + points,
          combo: combo,
          bestCombo: combo > state.bestCombo ? combo : state.bestCombo,
          caughtTargets: state.caughtTargets + 1,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        score: (state.score - 10).clamp(0, 9999),
        combo: 0,
        caughtDistractors: state.caughtDistractors + 1,
      ),
    );
  }

  void updateRemainingSeconds(int seconds) {
    if (!state.isPlaying || seconds == state.remainingSeconds) {
      return;
    }
    emit(state.copyWith(remainingSeconds: seconds));
  }

  void finishSession() {
    if (!state.isPlaying) {
      return;
    }

    emit(
      state.copyWith(
        status: state.achievedGoal
            ? MissionSessionStatus.won
            : MissionSessionStatus.lost,
        combo: 0,
        remainingSeconds: 0,
      ),
    );
  }

  void resetSession() {
    emit(
      state.copyWith(
        status: MissionSessionStatus.ready,
        score: 0,
        combo: 0,
        bestCombo: 0,
        caughtTargets: 0,
        caughtDistractors: 0,
        remainingSeconds: state.selectedMission.durationSeconds,
      ),
    );
  }
}
