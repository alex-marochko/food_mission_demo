import 'package:equatable/equatable.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_catalog.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_definition.dart';

enum MissionSessionStatus { ready, playing, won, lost }

class MissionSessionState extends Equatable {
  const MissionSessionState({
    required this.selectedMission,
    required this.status,
    required this.score,
    required this.combo,
    required this.bestCombo,
    required this.caughtTargets,
    required this.caughtDistractors,
    required this.remainingSeconds,
  });

  factory MissionSessionState.initial() {
    final mission = MissionCatalog.initialMission;
    return MissionSessionState(
      selectedMission: mission,
      status: MissionSessionStatus.ready,
      score: 0,
      combo: 0,
      bestCombo: 0,
      caughtTargets: 0,
      caughtDistractors: 0,
      remainingSeconds: mission.durationSeconds,
    );
  }

  final MissionDefinition selectedMission;
  final MissionSessionStatus status;
  final int score;
  final int combo;
  final int bestCombo;
  final int caughtTargets;
  final int caughtDistractors;
  final int remainingSeconds;

  bool get isPlaying => status == MissionSessionStatus.playing;
  bool get isFinished =>
      status == MissionSessionStatus.won || status == MissionSessionStatus.lost;
  bool get achievedGoal => score >= selectedMission.goalScore;
  double get progressToGoal => (score / selectedMission.goalScore).clamp(0, 1);

  MissionSessionState copyWith({
    MissionDefinition? selectedMission,
    MissionSessionStatus? status,
    int? score,
    int? combo,
    int? bestCombo,
    int? caughtTargets,
    int? caughtDistractors,
    int? remainingSeconds,
  }) {
    return MissionSessionState(
      selectedMission: selectedMission ?? this.selectedMission,
      status: status ?? this.status,
      score: score ?? this.score,
      combo: combo ?? this.combo,
      bestCombo: bestCombo ?? this.bestCombo,
      caughtTargets: caughtTargets ?? this.caughtTargets,
      caughtDistractors: caughtDistractors ?? this.caughtDistractors,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  @override
  List<Object?> get props => [
    selectedMission,
    status,
    score,
    combo,
    bestCombo,
    caughtTargets,
    caughtDistractors,
    remainingSeconds,
  ];
}
