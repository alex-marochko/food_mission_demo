import 'dart:math';

import 'package:flame/game.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/food_item.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_catalog.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_definition.dart';
import 'package:flutter/material.dart';

typedef CatchCallback = void Function(bool isTarget);
typedef CountdownCallback = void Function(int secondsLeft);
typedef FinishCallback = void Function();

enum CatcherFeedback { idle, success, error }

class FoodMissionGame extends FlameGame {
  FoodMissionGame({
    required CatchCallback onCatch,
    required CountdownCallback onCountdown,
    required FinishCallback onFinish,
  }) : _onCatch = onCatch,
       _onCountdown = onCountdown,
       _onFinish = onFinish;

  static const double boardAspectRatio = 0.72;
  static const double baseBoardWidth = 720;
  static const double baseBoardHeight = baseBoardWidth / boardAspectRatio;
  static const double _gravity = 910;
  static const double _spawnIntervalMin = 0.58;
  static const double _spawnIntervalVariance = 0.34;
  static const double _foodRadius = 24;
  static const double _foodFontSize = 46;
  static const double _foodRestitution = 0.88;
  static const double _obstacleRestitution = 0.84;
  static const double _wallRestitution = 0.82;
  static const double _foodLinearDamping = 0.015;
  static const double _foodAngularDamping = 0.28;
  static const double _catchHitboxWidth = 164;
  static const double _catchHitboxHeight = 88;
  static const double _catchVisualWidth = 112;
  static const double _catchBottomPadding = 18;

  final CatchCallback _onCatch;
  final CountdownCallback _onCountdown;
  final FinishCallback _onFinish;
  final Random _random = Random();
  final ValueNotifier<double> catchZoneNotifier = ValueNotifier<double>(0.5);
  final ValueNotifier<CatcherFeedback> catchFeedbackNotifier =
      ValueNotifier<CatcherFeedback>(CatcherFeedback.idle);

  final List<_FoodBody> _foods = [];
  final Map<String, TextPainter> _emojiPainters = {};
  Vector2 _lastBoardSize = Vector2.zero();

  MissionDefinition? _mission;
  List<_BoardObstacle> _obstacles = const [];
  bool _running = false;
  double _catchZoneNormalizedX = 0.5;
  double _spawnTimer = 0;
  double _remainingTime = 0;
  int _reportedSeconds = 0;
  double _catchFeedbackTimeRemaining = 0;

  @override
  Color backgroundColor() => Colors.transparent;

  static double scaleForBoardWidth(double boardWidth) => boardWidth / baseBoardWidth;

  double get boardScale => scaleForBoardWidth(size.x <= 0 ? baseBoardWidth : size.x);

  double get catcherVisualWidth => _catchVisualWidth * boardScale;

  double get catcherBottomPadding => _catchBottomPadding * boardScale;

  double get boardCornerRadius => 36 * boardScale;

  @override
  void onGameResize(Vector2 size) {
    final previousSize = _lastBoardSize.clone();
    super.onGameResize(size);
    _rescaleScene(previousSize, size);
    _lastBoardSize = size.clone();
    _emojiPainters.clear();
    _obstacles = _buildObstacles(size);
  }

  void startMission(MissionDefinition mission) {
    resetMission();
    _mission = mission;
    _remainingTime = mission.durationSeconds.toDouble();
    _reportedSeconds = mission.durationSeconds;
    _spawnTimer = 0.2;
    _onCountdown(_reportedSeconds);
    _running = true;
  }

  void resetMission() {
    _running = false;
    _mission = null;
    _foods.clear();
    _catchFeedbackTimeRemaining = 0;
    catchFeedbackNotifier.value = CatcherFeedback.idle;
  }

  void moveCatchZone(double normalizedX) {
    _catchZoneNormalizedX = normalizedX.clamp(0.12, 0.88);
    catchZoneNotifier.value = _catchZoneNormalizedX;
  }

  void nudgeCatchZone(double delta) {
    moveCatchZone(_catchZoneNormalizedX + delta);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateCatchFeedback(dt);

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
      _spawnTimer =
          _spawnIntervalMin + (_random.nextDouble() * _spawnIntervalVariance);
    }

    _stepPhysics(dt);
    _checkCatchZone();
    _removeMissedFood();

    if (_remainingTime <= 0) {
      _running = false;
      _onFinish();
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF2C7), Color(0xFFFFD6BF), Color(0xFFFFF8EE)],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(36)),
      backgroundPaint,
    );

    final ambientPaint = Paint()..color = const Color(0x22E8643D);
    canvas.drawCircle(Offset(size.x * 0.20, size.y * 0.19), 54, ambientPaint);
    canvas.drawCircle(Offset(size.x * 0.82, size.y * 0.30), 72, ambientPaint);
    canvas.drawCircle(Offset(size.x * 0.50, size.y * 0.70), 88, ambientPaint);

    for (final obstacle in _obstacles) {
      obstacle.render(canvas);
    }

    for (final food in _foods) {
      _renderFood(canvas, food);
    }

    super.render(canvas);
  }

  Rect get catchZoneRect {
    final catchWidth = _catchHitboxWidth * boardScale;
    final catchHeight = _catchHitboxHeight * boardScale;
    final bottomPadding = catcherBottomPadding;
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
    if (mission == null || size.x <= 0 || size.y <= 0) {
      return;
    }

    final isTarget = _random.nextDouble() > 0.34;
    final source = isTarget ? mission.targetItemIds : mission.distractorItemIds;
    final item =
        MissionCatalog.itemsById[source[_random.nextInt(source.length)]]!;

    final scale = boardScale;
    final foodRadius = _foodRadius * scale;
    final spawnInset = (foodRadius + (24 * scale));
    final spawnX =
        spawnInset + _random.nextDouble() * max(60 * scale, size.x - (spawnInset * 2));
    final initialVelocity = Vector2(
      (_random.nextDouble() - 0.5) * (210 * scale),
      (20 * scale) + (_random.nextDouble() * (90 * scale)),
    );

    _foods.add(
      _FoodBody(
        foodItem: item,
        isTarget: isTarget,
        position: Vector2(spawnX, -foodRadius - (_random.nextDouble() * (24 * scale))),
        velocity: initialVelocity,
        radius: foodRadius,
        angle: (_random.nextDouble() - 0.5) * 0.25,
        angularVelocity: (_random.nextDouble() - 0.5) * 4.2,
      ),
    );
  }

  void _stepPhysics(double dt) {
    final scaledGravity = _gravity * boardScale;
    for (final food in _foods) {
      food.velocity.y += scaledGravity * dt;
      food.velocity.x *= 1 - (_foodLinearDamping * dt * 60);
      food.angularVelocity *= 1 - (_foodAngularDamping * dt);
      food.position += food.velocity * dt;
      food.angle += food.angularVelocity * dt;

      _resolveWallCollisions(food);
      for (final obstacle in _obstacles) {
        obstacle.resolve(food);
      }
    }

    for (var i = 0; i < _foods.length; i++) {
      for (var j = i + 1; j < _foods.length; j++) {
        _resolveFoodCollision(_foods[i], _foods[j]);
      }
    }
  }

  void _resolveWallCollisions(_FoodBody food) {
    if (food.position.x - food.radius < 0) {
      food.position.x = food.radius;
      food.velocity.x = food.velocity.x.abs() * _wallRestitution;
      food.angularVelocity += 0.5;
    } else if (food.position.x + food.radius > size.x) {
      food.position.x = size.x - food.radius;
      food.velocity.x = -food.velocity.x.abs() * _wallRestitution;
      food.angularVelocity -= 0.5;
    }

    if (food.position.y - food.radius < 0) {
      food.position.y = food.radius;
      food.velocity.y = food.velocity.y.abs() * _wallRestitution;
    }
  }

  void _resolveFoodCollision(_FoodBody first, _FoodBody second) {
    final delta = second.position - first.position;
    final distance = delta.length;
    final minDistance = first.radius + second.radius;
    if (distance >= minDistance) {
      return;
    }

    final safeDistance = distance <= 0.0001 ? 0.0001 : distance;
    final normal = delta / safeDistance;
    final penetration = minDistance - safeDistance;
    final correction = normal * (penetration / 2);
    first.position -= correction;
    second.position += correction;

    final relativeVelocity = second.velocity - first.velocity;
    final velocityAlongNormal = relativeVelocity.dot(normal);
    if (velocityAlongNormal > 0) {
      return;
    }

    const restitution = _foodRestitution;
    final impulseMagnitude = -(1 + restitution) * velocityAlongNormal / 2;
    final impulse = normal * impulseMagnitude;
    first.velocity -= impulse;
    second.velocity += impulse;

    final tangent = Vector2(-normal.y, normal.x);
    final spin = relativeVelocity.dot(tangent) * 0.012;
    first.angularVelocity -= spin;
    second.angularVelocity += spin;
  }

  void _checkCatchZone() {
    final catcher = catchZoneRect;
    _foods.removeWhere((food) {
      final foodRect = Rect.fromCircle(
        center: Offset(food.position.x, food.position.y),
        radius: food.radius,
      );
      if (!foodRect.overlaps(catcher)) {
        return false;
      }
      _onCatch(food.isTarget);
      _triggerCatchFeedback(food.isTarget);
      return true;
    });
  }

  void _removeMissedFood() {
    _foods.removeWhere(
      (food) => food.position.y - food.radius > size.y + (64 * boardScale),
    );
  }

  void _renderFood(Canvas canvas, _FoodBody food) {
    final fontSize = _foodFontSize * boardScale;
    final painter = _emojiPainters.putIfAbsent(
      food.foodItem.emoji,
      () => TextPainter(
        text: TextSpan(
          text: food.foodItem.emoji,
          style: TextStyle(fontSize: fontSize),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );

    canvas.save();
    canvas.translate(food.position.x, food.position.y);
    canvas.rotate(food.angle);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  List<_BoardObstacle> _buildObstacles(Vector2 boardSize) {
    if (boardSize.x <= 0 || boardSize.y <= 0) {
      return const [];
    }

    final scale = scaleForBoardWidth(boardSize.x);

    return [
      _CircleObstacle(
        renderScale: scale,
        center: Offset(boardSize.x * 0.18, boardSize.y * 0.235),
        radius: 20 * scale,
        color: const Color(0xFFF4A261),
      ),
      _SquareObstacle(
        renderScale: scale,
        rect: Rect.fromCenter(
          center: Offset(boardSize.x * 0.38, boardSize.y * 0.19),
          width: 40 * scale,
          height: 40 * scale,
        ),
        color: const Color(0xFFE76F51),
      ),
      _TriangleObstacle(
        renderScale: scale,
        points: [
          Offset(boardSize.x * 0.58, boardSize.y * 0.15),
          Offset(boardSize.x * 0.53, boardSize.y * 0.235),
          Offset(boardSize.x * 0.63, boardSize.y * 0.235),
        ],
        color: const Color(0xFF2A9D8F),
      ),
      _CircleObstacle(
        renderScale: scale,
        center: Offset(boardSize.x * 0.78, boardSize.y * 0.22),
        radius: 18 * scale,
        color: const Color(0xFFE9C46A),
      ),
    ];
  }

  void _rescaleScene(Vector2 previousSize, Vector2 newSize) {
    if (previousSize.x <= 0 || previousSize.y <= 0 || _foods.isEmpty) {
      return;
    }

    final scale = min(newSize.x / previousSize.x, newSize.y / previousSize.y);
    for (final food in _foods) {
      food.position = Vector2(food.position.x * scale, food.position.y * scale);
      food.velocity = Vector2(food.velocity.x * scale, food.velocity.y * scale);
      food.radius *= scale;
    }
  }

  void _triggerCatchFeedback(bool isTarget) {
    catchFeedbackNotifier.value = isTarget
        ? CatcherFeedback.success
        : CatcherFeedback.error;
    _catchFeedbackTimeRemaining = 0.18;
  }

  void _updateCatchFeedback(double dt) {
    if (_catchFeedbackTimeRemaining <= 0) {
      return;
    }

    _catchFeedbackTimeRemaining = max(0, _catchFeedbackTimeRemaining - dt);
    if (_catchFeedbackTimeRemaining == 0 &&
        catchFeedbackNotifier.value != CatcherFeedback.idle) {
      catchFeedbackNotifier.value = CatcherFeedback.idle;
    }
  }
}

class _FoodBody {
  _FoodBody({
    required this.foodItem,
    required this.isTarget,
    required this.position,
    required this.velocity,
    required this.radius,
    required this.angle,
    required this.angularVelocity,
  });

  final FoodItem foodItem;
  final bool isTarget;
  Vector2 position;
  Vector2 velocity;
  double radius;
  double angle;
  double angularVelocity;
}

sealed class _BoardObstacle {
  const _BoardObstacle({required this.renderScale});

  final double renderScale;

  void render(Canvas canvas);

  bool resolve(_FoodBody food);

  void reflect(
    _FoodBody food,
    Vector2 normal,
    double penetration,
    double restitution,
  ) {
    final safeNormal = normal.length2 == 0
        ? Vector2(0, -1)
        : normal.normalized();
    food.position += safeNormal * penetration;
    final velocityAlongNormal = food.velocity.dot(safeNormal);
    if (velocityAlongNormal < 0) {
      food.velocity -= safeNormal * ((1 + restitution) * velocityAlongNormal);
    }
    food.angularVelocity += safeNormal.x * 0.4;
  }

  Paint shadowPaint() => Paint()..color = const Color(0x26000000);

  Paint fillPaint(Color color) => Paint()..color = color;

  Paint strokePaint() =>
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * renderScale
        ..color = const Color(0xCC2A211B);
}

class _CircleObstacle extends _BoardObstacle {
  const _CircleObstacle({
    required super.renderScale,
    required this.center,
    required this.radius,
    required this.color,
  });

  final Offset center;
  final double radius;
  final Color color;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(center.translate(0, 6 * renderScale), radius, shadowPaint());
    canvas.drawCircle(center, radius, fillPaint(color));
    canvas.drawCircle(center, radius, strokePaint());
  }

  @override
  bool resolve(_FoodBody food) {
    final delta = food.position - Vector2(center.dx, center.dy);
    final distance = delta.length;
    final minDistance = radius + food.radius;
    if (distance >= minDistance) {
      return false;
    }

    final safeDistance = distance <= 0.0001 ? 0.0001 : distance;
    final normal = delta / safeDistance;
    reflect(
      food,
      normal,
      minDistance - safeDistance,
      FoodMissionGame._obstacleRestitution,
    );
    return true;
  }
}

class _SquareObstacle extends _BoardObstacle {
  const _SquareObstacle({
    required super.renderScale,
    required this.rect,
    required this.color,
  });

  final Rect rect;
  final Color color;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.shift(Offset(0, 6 * renderScale)),
        Radius.circular(8 * renderScale),
      ),
      shadowPaint(),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8 * renderScale)),
      fillPaint(color),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8 * renderScale)),
      strokePaint(),
    );
  }

  @override
  bool resolve(_FoodBody food) {
    final circleCenter = Offset(food.position.x, food.position.y);
    final closestX = circleCenter.dx.clamp(rect.left, rect.right);
    final closestY = circleCenter.dy.clamp(rect.top, rect.bottom);
    final deltaX = circleCenter.dx - closestX;
    final deltaY = circleCenter.dy - closestY;
    final distanceSquared = (deltaX * deltaX) + (deltaY * deltaY);
    final radiusSquared = food.radius * food.radius;

    if (distanceSquared > radiusSquared && !rect.contains(circleCenter)) {
      return false;
    }

    Vector2 normal;
    double penetration;
    if (rect.contains(circleCenter)) {
      final leftPen = circleCenter.dx - rect.left;
      final rightPen = rect.right - circleCenter.dx;
      final topPen = circleCenter.dy - rect.top;
      final bottomPen = rect.bottom - circleCenter.dy;
      final minPen = [leftPen, rightPen, topPen, bottomPen].reduce(min);

      if (minPen == leftPen) {
        normal = Vector2(1, 0);
        penetration = food.radius + leftPen;
      } else if (minPen == rightPen) {
        normal = Vector2(-1, 0);
        penetration = food.radius + rightPen;
      } else if (minPen == topPen) {
        normal = Vector2(0, 1);
        penetration = food.radius + topPen;
      } else {
        normal = Vector2(0, -1);
        penetration = food.radius + bottomPen;
      }
    } else {
      final distance = sqrt(distanceSquared);
      final safeDistance = distance <= 0.0001 ? 0.0001 : distance;
      normal = Vector2(deltaX / safeDistance, deltaY / safeDistance);
      penetration = food.radius - safeDistance;
    }

    reflect(food, normal, penetration, FoodMissionGame._obstacleRestitution);
    return true;
  }
}

class _TriangleObstacle extends _BoardObstacle {
  _TriangleObstacle({
    required super.renderScale,
    required List<Offset> points,
    required this.color,
  })
    : assert(points.length == 3),
      points = List.unmodifiable(points),
      path = Path()..addPolygon(points, true);

  final List<Offset> points;
  final Color color;
  final Path path;

  @override
  void render(Canvas canvas) {
    canvas.drawPath(path.shift(Offset(0, 6 * renderScale)), shadowPaint());
    canvas.drawPath(path, fillPaint(color));
    canvas.drawPath(path, strokePaint());
  }

  @override
  bool resolve(_FoodBody food) {
    final center = Offset(food.position.x, food.position.y);
    final inside = _pointInTriangle(center, points[0], points[1], points[2]);

    double bestDistance = double.infinity;
    Offset? bestPoint;
    for (var index = 0; index < points.length; index++) {
      final start = points[index];
      final end = points[(index + 1) % points.length];
      final closest = _closestPointOnSegment(center, start, end);
      final distance = (center - closest).distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        bestPoint = closest;
      }
    }

    if (!inside && bestDistance > food.radius) {
      return false;
    }

    final collisionPoint = bestPoint ?? center;
    final normal = Vector2(
      center.dx - collisionPoint.dx,
      center.dy - collisionPoint.dy,
    );
    final penetration = inside ? food.radius + 2 : food.radius - bestDistance;
    reflect(food, normal, penetration, FoodMissionGame._obstacleRestitution);
    return true;
  }

  bool _pointInTriangle(Offset point, Offset a, Offset b, Offset c) {
    final d1 = _sign(point, a, b);
    final d2 = _sign(point, b, c);
    final d3 = _sign(point, c, a);
    final hasNegative = (d1 < 0) || (d2 < 0) || (d3 < 0);
    final hasPositive = (d1 > 0) || (d2 > 0) || (d3 > 0);
    return !(hasNegative && hasPositive);
  }

  double _sign(Offset p1, Offset p2, Offset p3) {
    return (p1.dx - p3.dx) * (p2.dy - p3.dy) -
        (p2.dx - p3.dx) * (p1.dy - p3.dy);
  }

  Offset _closestPointOnSegment(Offset point, Offset start, Offset end) {
    final segment = end - start;
    final segmentLengthSquared =
        (segment.dx * segment.dx) + (segment.dy * segment.dy);
    if (segmentLengthSquared == 0) {
      return start;
    }
    final projection =
        (((point.dx - start.dx) * segment.dx) +
            ((point.dy - start.dy) * segment.dy)) /
        segmentLengthSquared;
    final t = projection.clamp(0.0, 1.0);
    return Offset(start.dx + (segment.dx * t), start.dy + (segment.dy * t));
  }
}
