import 'package:equatable/equatable.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/level_definition.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/level_planner.dart';

enum MissionSessionStatus { intro, playing, won, lost }

class MissionSessionState extends Equatable {
  const MissionSessionState({
    required this.level,
    required this.status,
    required this.score,
    required this.goalLocked,
    required this.combo,
    required this.bestCombo,
    required this.caughtTargets,
    required this.caughtDistractors,
    required this.remainingSeconds,
  });

  factory MissionSessionState.initial() {
    final level = LevelPlanner.levelFor(1);
    return MissionSessionState(
      level: level,
      status: MissionSessionStatus.intro,
      score: 0,
      goalLocked: false,
      combo: 0,
      bestCombo: 0,
      caughtTargets: 0,
      caughtDistractors: 0,
      remainingSeconds: level.durationSeconds,
    );
  }

  final LevelDefinition level;
  final MissionSessionStatus status;
  final int score;
  final bool goalLocked;
  final int combo;
  final int bestCombo;
  final int caughtTargets;
  final int caughtDistractors;
  final int remainingSeconds;

  bool get isPlaying => status == MissionSessionStatus.playing;
  bool get isIntro => status == MissionSessionStatus.intro;
  bool get isWon => status == MissionSessionStatus.won;
  bool get isLost => status == MissionSessionStatus.lost;
  bool get isFinished => isWon || isLost;
  bool get achievedGoal => goalLocked || score >= level.goalScore;
  bool get canAdvance => level.number < LevelPlanner.maxLevel;
  double get progressToGoal =>
      goalLocked ? 1 : (score / level.goalScore).clamp(0, 1);

  MissionSessionState copyWith({
    LevelDefinition? level,
    MissionSessionStatus? status,
    int? score,
    bool? goalLocked,
    int? combo,
    int? bestCombo,
    int? caughtTargets,
    int? caughtDistractors,
    int? remainingSeconds,
  }) {
    return MissionSessionState(
      level: level ?? this.level,
      status: status ?? this.status,
      score: score ?? this.score,
      goalLocked: goalLocked ?? this.goalLocked,
      combo: combo ?? this.combo,
      bestCombo: bestCombo ?? this.bestCombo,
      caughtTargets: caughtTargets ?? this.caughtTargets,
      caughtDistractors: caughtDistractors ?? this.caughtDistractors,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  MissionSessionState resetForLevel(
    LevelDefinition nextLevel, {
    required MissionSessionStatus status,
  }) {
    return MissionSessionState(
      level: nextLevel,
      status: status,
      score: 0,
      goalLocked: false,
      combo: 0,
      bestCombo: 0,
      caughtTargets: 0,
      caughtDistractors: 0,
      remainingSeconds: nextLevel.durationSeconds,
    );
  }

  @override
  List<Object?> get props => [
    level,
    status,
    score,
    goalLocked,
    combo,
    bestCombo,
    caughtTargets,
    caughtDistractors,
    remainingSeconds,
  ];
}
