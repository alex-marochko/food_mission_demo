import 'package:equatable/equatable.dart';

enum MissionMood { vitamins, properMeal, goodbyeDiet }

class MissionDefinition extends Equatable {
  const MissionDefinition({
    required this.id,
    required this.goalScore,
    required this.durationSeconds,
    required this.mood,
    required this.targetItemIds,
    required this.distractorItemIds,
  });

  final String id;
  final int goalScore;
  final int durationSeconds;
  final MissionMood mood;
  final List<String> targetItemIds;
  final List<String> distractorItemIds;

  @override
  List<Object?> get props => [
    id,
    goalScore,
    durationSeconds,
    mood,
    targetItemIds,
    distractorItemIds,
  ];
}
