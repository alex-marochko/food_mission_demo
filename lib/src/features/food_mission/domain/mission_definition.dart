import 'package:equatable/equatable.dart';

enum MissionMood { dessert, vitamins, roadTrip, breakfast, coffeeBreak }

class MissionDefinition extends Equatable {
  const MissionDefinition({
    required this.id,
    required this.title,
    required this.tagline,
    required this.brief,
    required this.goalScore,
    required this.durationSeconds,
    required this.mood,
    required this.targetItemIds,
    required this.distractorItemIds,
  });

  final String id;
  final String title;
  final String tagline;
  final String brief;
  final int goalScore;
  final int durationSeconds;
  final MissionMood mood;
  final List<String> targetItemIds;
  final List<String> distractorItemIds;

  @override
  List<Object?> get props => [
    id,
    title,
    tagline,
    brief,
    goalScore,
    durationSeconds,
    mood,
    targetItemIds,
    distractorItemIds,
  ];
}
