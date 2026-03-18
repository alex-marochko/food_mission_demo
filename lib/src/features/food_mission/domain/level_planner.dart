import 'dart:math';

import 'package:food_mission_demo/src/features/food_mission/domain/level_definition.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_catalog.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_definition.dart';

class LevelPlanner {
  const LevelPlanner._();

  static const int maxLevel = 90;
  static const double _waveDurationSeconds = 20;
  static const double _sampleStepSeconds = 0.25;

  static LevelDefinition levelFor(int levelNumber) {
    final clampedLevel = levelNumber.clamp(1, maxLevel);
    final progress = (clampedLevel - 1) / (maxLevel - 1);
    final durationSeconds = 19 + clampedLevel;
    final mission = _missionForLevel(clampedLevel);

    final averageSpawnsPerSecond = clampedLevel == 1
        ? 1.1
        : _lerp(0.9, 1.03, progress);
    final totalSpawnCount = max(
      10,
      (durationSeconds * averageSpawnsPerSecond).round(),
    );

    final targetShare = clampedLevel == 1 ? 0.58 : _lerp(0.7, 0.45, progress);
    final targetSpawnCount = max(
      1,
      min(totalSpawnCount - 1, (totalSpawnCount * targetShare).round()),
    );
    final distractorSpawnCount = totalSpawnCount - targetSpawnCount;

    final spareRatio = _lerp(0.32, 0.0, progress);
    final requiredPerfectTargetCatches = clampedLevel == maxLevel
        ? targetSpawnCount
        : max(1, (targetSpawnCount * (1 - spareRatio)).round());

    final goalScore = perfectScoreForTargetCount(requiredPerfectTargetCatches);
    final spawnTimeline = _buildSpawnTimeline(
      levelNumber: clampedLevel,
      durationSeconds: durationSeconds,
      totalSpawnCount: totalSpawnCount,
      targetSpawnCount: targetSpawnCount,
    );

    return LevelDefinition(
      number: clampedLevel,
      mission: mission,
      durationSeconds: durationSeconds,
      goalScore: goalScore,
      totalSpawnCount: totalSpawnCount,
      targetSpawnCount: targetSpawnCount,
      distractorSpawnCount: distractorSpawnCount,
      requiredPerfectTargetCatches: requiredPerfectTargetCatches,
      spawnTimeline: spawnTimeline,
    );
  }

  static int perfectScoreForTargetCount(int targetCount) {
    var score = 0;
    for (var index = 0; index < targetCount; index++) {
      score += 12 + min(index * 2, 8);
    }
    return score;
  }

  static MissionDefinition _missionForLevel(int levelNumber) {
    const rotation = ['goodbye_diet', 'proper_meal', 'vitamins'];
    final missionId = rotation[(levelNumber - 1) % rotation.length];
    return MissionCatalog.missionById(missionId);
  }

  static List<LevelSpawnEntry> _buildSpawnTimeline({
    required int levelNumber,
    required int durationSeconds,
    required int totalSpawnCount,
    required int targetSpawnCount,
  }) {
    final samples = <_WeightedSample>[];
    var time = _sampleStepSeconds / 2;
    while (time < durationSeconds) {
      samples.add(
        _WeightedSample(
          timeSeconds: time,
          weight: _waveWeight(time % _waveDurationSeconds),
        ),
      );
      time += _sampleStepSeconds;
    }

    final totalWeight = samples.fold<double>(
      0,
      (sum, sample) => sum + sample.weight,
    );

    final spawnTimes = <double>[];
    for (var index = 0; index < totalSpawnCount; index++) {
      final targetWeight = totalWeight * ((index + 0.5) / totalSpawnCount);
      var cumulativeWeight = 0.0;
      for (final sample in samples) {
        cumulativeWeight += sample.weight;
        if (cumulativeWeight >= targetWeight) {
          spawnTimes.add(sample.timeSeconds);
          break;
        }
      }
    }

    final spawnPattern = _buildSpawnPattern(
      levelNumber: levelNumber,
      totalSpawnCount: totalSpawnCount,
      targetSpawnCount: targetSpawnCount,
    );

    return List.generate(
      totalSpawnCount,
      (index) => LevelSpawnEntry(
        timeSeconds: spawnTimes[index],
        isTarget: spawnPattern[index],
      ),
      growable: false,
    );
  }

  static List<bool> _buildSpawnPattern({
    required int levelNumber,
    required int totalSpawnCount,
    required int targetSpawnCount,
  }) {
    final pattern = <bool>[
      ...List<bool>.filled(targetSpawnCount, true),
      ...List<bool>.filled(totalSpawnCount - targetSpawnCount, false),
    ];
    pattern.shuffle(Random(levelNumber * 9973));

    if (targetSpawnCount > 0 && !pattern.first) {
      final targetIndex = pattern.indexWhere((value) => value);
      if (targetIndex > 0) {
        final first = pattern.first;
        pattern[0] = pattern[targetIndex];
        pattern[targetIndex] = first;
      }
    }

    return List.unmodifiable(pattern);
  }

  static double _waveWeight(double localSeconds) {
    if (localSeconds <= 13) {
      return _lerp(0.55, 1.6, localSeconds / 13);
    }

    final tailProgress = (localSeconds - 13) / 7;
    return _lerp(1.6, 0.62, tailProgress.clamp(0, 1));
  }

  static double _lerp(double from, double to, double t) =>
      from + ((to - from) * t);
}

class _WeightedSample {
  const _WeightedSample({
    required this.timeSeconds,
    required this.weight,
  });

  final double timeSeconds;
  final double weight;
}
