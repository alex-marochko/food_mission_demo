import 'package:equatable/equatable.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_definition.dart';

class LevelSpawnEntry extends Equatable {
  const LevelSpawnEntry({required this.timeSeconds, required this.isTarget});

  final double timeSeconds;
  final bool isTarget;

  @override
  List<Object?> get props => [timeSeconds, isTarget];
}

class LevelDefinition extends Equatable {
  const LevelDefinition({
    required this.number,
    required this.mission,
    required this.durationSeconds,
    required this.goalScore,
    required this.totalSpawnCount,
    required this.targetSpawnCount,
    required this.distractorSpawnCount,
    required this.requiredPerfectTargetCatches,
    required this.spawnTimeline,
  });

  final int number;
  final MissionDefinition mission;
  final int durationSeconds;
  final int goalScore;
  final int totalSpawnCount;
  final int targetSpawnCount;
  final int distractorSpawnCount;
  final int requiredPerfectTargetCatches;
  final List<LevelSpawnEntry> spawnTimeline;

  bool get isFinalLevel => number == 90;

  @override
  List<Object?> get props => [
    number,
    mission,
    durationSeconds,
    goalScore,
    totalSpawnCount,
    targetSpawnCount,
    distractorSpawnCount,
    requiredPerfectTargetCatches,
    spawnTimeline,
  ];
}
