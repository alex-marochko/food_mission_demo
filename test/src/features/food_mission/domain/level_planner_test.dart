import 'package:flutter_test/flutter_test.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/level_planner.dart';

void main() {
  group('LevelPlanner', () {
    test('rotates missions in the expected order', () {
      expect(LevelPlanner.levelFor(1).mission.id, 'goodbye_diet');
      expect(LevelPlanner.levelFor(2).mission.id, 'proper_meal');
      expect(LevelPlanner.levelFor(3).mission.id, 'vitamins');
      expect(LevelPlanner.levelFor(4).mission.id, 'goodbye_diet');
    });

    test('grows duration by one second per level', () {
      expect(LevelPlanner.levelFor(1).durationSeconds, 20);
      expect(LevelPlanner.levelFor(21).durationSeconds, 40);
      expect(LevelPlanner.levelFor(90).durationSeconds, 109);
    });

    test('makes the first level notably denser and less target-heavy', () {
      final level = LevelPlanner.levelFor(1);
      final targetShare = level.targetSpawnCount / level.totalSpawnCount;

      expect(level.totalSpawnCount, 22);
      expect(targetShare, closeTo(0.59, 0.03));
    });

    test('builds ordered spawn timeline inside the level duration', () {
      final level = LevelPlanner.levelFor(21);

      expect(level.spawnTimeline, isNotEmpty);
      expect(level.spawnTimeline.length, level.totalSpawnCount);
      expect(
        level.spawnTimeline.every(
          (entry) =>
              entry.timeSeconds >= 0 &&
              entry.timeSeconds <= level.durationSeconds,
        ),
        isTrue,
      );

      for (var index = 1; index < level.spawnTimeline.length; index++) {
        expect(
          level.spawnTimeline[index].timeSeconds,
          greaterThanOrEqualTo(level.spawnTimeline[index - 1].timeSeconds),
        );
      }
    });

    test('final level has exactly enough target spawns for perfect score', () {
      final level = LevelPlanner.levelFor(90);

      expect(level.targetSpawnCount, level.requiredPerfectTargetCatches);
      expect(
        LevelPlanner.perfectScoreForTargetCount(level.targetSpawnCount),
        level.goalScore,
      );
    });
  });
}
