import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/food_item.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_catalog.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_definition.dart';
import 'package:flutter/material.dart';

typedef CatchCallback = void Function(bool isTarget);
typedef CountdownCallback = void Function(int secondsLeft);
typedef FinishCallback = void Function();

class FoodMissionGame extends FlameGame {
  FoodMissionGame({
    required CatchCallback onCatch,
    required CountdownCallback onCountdown,
    required FinishCallback onFinish,
  }) : _onCatch = onCatch,
       _onCountdown = onCountdown,
       _onFinish = onFinish;

  final CatchCallback _onCatch;
  final CountdownCallback _onCountdown;
  final FinishCallback _onFinish;
  final Random _random = Random();
  final List<_FallingFoodComponent> _activeItems = [];
  final ValueNotifier<double> catchZoneNotifier = ValueNotifier<double>(0.5);

  MissionDefinition? _mission;
  bool _running = false;
  double _catchZoneNormalizedX = 0.5;
  double _spawnTimer = 0;
  double _remainingTime = 0;
  int _reportedSeconds = 0;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  void render(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF2C7), Color(0xFFFFD6BF), Color(0xFFFFF8EE)],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(36)),
      gradient,
    );

    final accentPaint = Paint()..color = const Color(0x33E8643D);
    canvas.drawCircle(Offset(size.x * 0.18, size.y * 0.16), 58, accentPaint);
    canvas.drawCircle(Offset(size.x * 0.84, size.y * 0.28), 74, accentPaint);
    canvas.drawCircle(Offset(size.x * 0.5, size.y * 0.72), 92, accentPaint);

    super.render(canvas);
  }

  void startMission(MissionDefinition mission) {
    resetMission();
    _mission = mission;
    _remainingTime = mission.durationSeconds.toDouble();
    _reportedSeconds = mission.durationSeconds;
    _onCountdown(_reportedSeconds);
    _running = true;
  }

  void resetMission() {
    _running = false;
    _mission = null;
    for (final item in List<_FallingFoodComponent>.from(_activeItems)) {
      item.removeFromParent();
    }
    _activeItems.clear();
  }

  void moveCatchZone(double normalizedX) {
    _catchZoneNormalizedX = normalizedX.clamp(0.1, 0.9);
    catchZoneNotifier.value = _catchZoneNormalizedX;
  }

  void nudgeCatchZone(double delta) {
    moveCatchZone(_catchZoneNormalizedX + delta);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_running || _mission == null) {
      return;
    }

    _remainingTime = max(0, _remainingTime - dt);
    final remainingSeconds = _remainingTime.ceil();
    if (remainingSeconds != _reportedSeconds) {
      _reportedSeconds = remainingSeconds;
      _onCountdown(_reportedSeconds);
    }

    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnFood();
      _spawnTimer = 0.48 + (_random.nextDouble() * 0.22);
    }

    _checkCollisionsAndBounds();

    if (_remainingTime <= 0) {
      _running = false;
      _onFinish();
    }
  }

  Rect get catchZoneRect {
    const catchWidth = 164.0;
    const catchHeight = 88.0;
    const bottomPadding = 18.0;
    final left = (size.x * _catchZoneNormalizedX) - (catchWidth / 2);
    return Rect.fromLTWH(
      left.clamp(0, max(0, size.x - catchWidth)),
      size.y - catchHeight - bottomPadding,
      catchWidth,
      catchHeight,
    );
  }

  void _spawnFood() {
    final mission = _mission;
    if (mission == null) {
      return;
    }

    final isTarget = _random.nextDouble() > 0.32;
    final source = isTarget ? mission.targetItemIds : mission.distractorItemIds;
    final item =
        MissionCatalog.itemsById[source[_random.nextInt(source.length)]]!;
    final spawnX = 36 + _random.nextDouble() * (size.x - 72);
    final component = _FallingFoodComponent(
      foodItem: item,
      isTarget: isTarget,
      initialPosition: Vector2(spawnX, -12),
      speed: 150 + _random.nextDouble() * 120,
      drift: (_random.nextDouble() - 0.5) * 20,
    );
    _activeItems.add(component);
    add(component);
  }

  void _checkCollisionsAndBounds() {
    final catchRect = catchZoneRect;
    for (final item in List<_FallingFoodComponent>.from(_activeItems)) {
      if (item.collisionRect.overlaps(catchRect)) {
        _activeItems.remove(item);
        item.removeFromParent();
        _onCatch(item.isTarget);
        continue;
      }
      if (item.position.y > size.y + 40) {
        _activeItems.remove(item);
        item.removeFromParent();
      }
    }
  }
}

class _FallingFoodComponent extends TextComponent {
  _FallingFoodComponent({
    required this.foodItem,
    required this.isTarget,
    required Vector2 initialPosition,
    required this.speed,
    required this.drift,
  }) : super(
         text: foodItem.emoji,
         position: initialPosition,
         anchor: Anchor.center,
         priority: 2,
         textRenderer: TextPaint(style: const TextStyle(fontSize: 34)),
       );

  final FoodItem foodItem;
  final bool isTarget;
  final double speed;
  final double drift;

  Rect get collisionRect => Rect.fromCenter(
    center: Offset(position.x, position.y),
    width: 34,
    height: 34,
  );

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    position.x += drift * dt;
  }
}
