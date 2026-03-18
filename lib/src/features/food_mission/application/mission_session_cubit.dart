import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/level_planner.dart';

class MissionSessionCubit extends Cubit<MissionSessionState> {
  MissionSessionCubit() : super(MissionSessionState.initial());

  void startCurrentLevel() {
    emit(
      state.resetForLevel(
        state.level,
        status: MissionSessionStatus.playing,
        totalScore: state.totalScore,
      ),
    );
  }

  void retryLevel() {
    emit(
      state.resetForLevel(
        state.level,
        status: MissionSessionStatus.playing,
        totalScore: state.totalScore,
      ),
    );
  }

  void openNextLevelIntro() {
    final committedTotalScore = state.totalScore + state.pendingAwardScore;
    final nextLevelNumber = state.canAdvance ? state.level.number + 1 : 1;
    final nextLevel = LevelPlanner.levelFor(nextLevelNumber);
    emit(
      state.resetForLevel(
        nextLevel,
        status: MissionSessionStatus.intro,
        totalScore: committedTotalScore,
      ),
    );
  }

  void registerCatch({required bool isTarget}) {
    if (!state.isPlaying) {
      return;
    }

    if (isTarget) {
      final combo = state.combo + 1;
      final points = 12 + ((combo - 1) * 2).clamp(0, 8);
      final updatedScore = state.score + points;
      emit(
        state.copyWith(
          score: updatedScore,
          goalLocked: state.goalLocked || updatedScore >= state.level.goalScore,
          combo: combo,
          bestCombo: combo > state.bestCombo ? combo : state.bestCombo,
          caughtTargets: state.caughtTargets + 1,
        ),
      );
      return;
    }

    final minimumScore = state.goalLocked ? state.level.goalScore : 0;
    emit(
      state.copyWith(
        score: (state.score - 10).clamp(minimumScore, 999999),
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

  void finishLevelFromTimer() {
    if (!state.isPlaying) {
      return;
    }

    emit(
      state.copyWith(
        status: state.achievedGoal
            ? MissionSessionStatus.won
            : MissionSessionStatus.lost,
        pendingAwardScore: state.achievedGoal ? state.score : 0,
        combo: 0,
        remainingSeconds: 0,
      ),
    );
  }
}
