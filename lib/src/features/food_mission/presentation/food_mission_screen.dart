import 'package:flame/game.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_cubit.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_catalog.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/game/food_mission_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FoodMissionScreen extends StatefulWidget {
  const FoodMissionScreen({super.key});

  @override
  State<FoodMissionScreen> createState() => _FoodMissionScreenState();
}

class _FoodMissionScreenState extends State<FoodMissionScreen> {
  late FoodMissionGame _game;
  final FocusNode _gameFocusNode = FocusNode(debugLabel: 'food-mission-game');

  @override
  void initState() {
    super.initState();
    _game = _createGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _gameFocusNode.requestFocus();
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    _game = _createGame();
    final state = context.read<MissionSessionCubit>().state;
    if (state.isPlaying) {
      _game.startMission(state.level);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _game.resetMission();
    _gameFocusNode.dispose();
    super.dispose();
  }

  FoodMissionGame _createGame() {
    return FoodMissionGame(
      onCatch: (isTarget) =>
          context.read<MissionSessionCubit>().registerCatch(isTarget: isTarget),
      onCountdown: (seconds) =>
          context.read<MissionSessionCubit>().updateRemainingSeconds(seconds),
      onFinish: () => context.read<MissionSessionCubit>().finishLevelFromTimer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MissionSessionCubit, MissionSessionState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.level != current.level,
      listener: (context, state) {
        if (state.isPlaying) {
          _game.startMission(state.level);
        } else {
          _game.resetMission();
        }
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF1DB), Color(0xFFFFFAF4), Color(0xFFFFE4C9)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final maxHeight = constraints.maxHeight;
                    final boardWidth = (maxHeight * FoodMissionGame.boardAspectRatio)
                        .clamp(0.0, maxWidth);
                    final boardHeight =
                        boardWidth / FoodMissionGame.boardAspectRatio;

                    return SizedBox(
                      width: boardWidth,
                      height: boardHeight,
                      child: BlocBuilder<MissionSessionCubit, MissionSessionState>(
                        builder: (context, state) {
                          return _GameBoard(
                            game: _game,
                            state: state,
                            focusNode: _gameFocusNode,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameBoard extends StatelessWidget {
  const _GameBoard({
    required this.game,
    required this.state,
    required this.focusNode,
  });

  final FoodMissionGame game;
  final MissionSessionState state;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MissionSessionCubit>();

    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }

        if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
            event.logicalKey == LogicalKeyboardKey.keyA) {
          game.nudgeCatchZone(-0.08);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
            event.logicalKey == LogicalKeyboardKey.keyD) {
          game.nudgeCatchZone(0.08);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardScale = FoodMissionGame.scaleForBoardWidth(
            constraints.maxWidth,
          );
          final overlayInset = (18 * boardScale).clamp(10.0, 18.0);

          void syncPointer(double dx) {
            focusNode.requestFocus();
            game.moveCatchZone(dx / constraints.maxWidth);
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(36 * boardScale),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) => syncPointer(event.localPosition.dx),
                  onPointerMove: (event) => syncPointer(event.localPosition.dx),
                  child: MouseRegion(
                    onEnter: (_) => focusNode.requestFocus(),
                    onHover: (event) => syncPointer(event.localPosition.dx),
                    child: GameWidget(game: game),
                  ),
                ),
                IgnorePointer(
                  child: Padding(
                    padding: EdgeInsets.all(overlayInset),
                    child: _BoardHud(
                      scale: boardScale,
                      maxWidth: constraints.maxWidth - (overlayInset * 2),
                      state: state,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ValueListenableBuilder<CatcherFeedback>(
                      valueListenable: game.catchFeedbackNotifier,
                      builder: (context, feedback, _) {
                        return ValueListenableBuilder<double>(
                          valueListenable: game.catchZoneNotifier,
                          builder: (context, normalizedX, child) {
                            final catcherWidth = 132 * boardScale;
                            final left =
                                (constraints.maxWidth * normalizedX) -
                                (catcherWidth / 2);
                            return Stack(
                              children: [
                                Positioned(
                                  left: left.clamp(
                                    0.0,
                                    constraints.maxWidth - catcherWidth,
                                  ),
                                  bottom: 18 * boardScale,
                                  child: child!,
                                ),
                              ],
                            );
                          },
                          child: _CatcherOverlay(
                            scale: boardScale,
                            feedback: feedback,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (!state.isPlaying)
                  Positioned.fill(
                    child: _BoardPopupLayer(
                      state: state,
                      scale: boardScale,
                      onStart: cubit.startCurrentLevel,
                      onRetry: cubit.retryLevel,
                      onNext: cubit.openNextLevelIntro,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BoardHud extends StatelessWidget {
  const _BoardHud({
    required this.scale,
    required this.maxWidth,
    required this.state,
  });

  final double scale;
  final double maxWidth;
  final MissionSessionState state;

  @override
  Widget build(BuildContext context) {
    final pills = [
      _HudPill(label: 'Рівень', value: '${state.level.number}', scale: scale),
      _HudPill(
        label: 'Місія',
        value: state.level.mission.title,
        scale: scale,
      ),
      _HudPill(label: 'Очки', value: '${state.score}', scale: scale),
      _HudPill(label: 'Ціль', value: '${state.level.goalScore}', scale: scale),
      _HudPill(label: 'Час', value: '${state.remainingSeconds}s', scale: scale),
      _HudPill(label: 'Комбо', value: 'x${state.combo}', scale: scale),
    ];

    return Align(
      alignment: Alignment.topLeft,
      child: Wrap(
        spacing: 8 * scale,
        runSpacing: 8 * scale,
        children: pills,
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({
    required this.label,
    required this.value,
    required this.scale,
  });

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: const Color(0xFF7E6B5C),
      fontSize: (theme.textTheme.labelSmall?.fontSize ?? 11) * scale * 1.3,
      height: 1.0,
    );
    final valueStyle = theme.textTheme.titleMedium?.copyWith(
      fontSize: (theme.textTheme.titleMedium?.fontSize ?? 16) * scale * 1.3,
      height: 1.0,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 10 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: labelStyle),
            SizedBox(height: 2 * scale),
            Text(value, style: valueStyle),
          ],
        ),
      ),
    );
  }
}

class _BoardPopupLayer extends StatelessWidget {
  const _BoardPopupLayer({
    required this.state,
    required this.scale,
    required this.onStart,
    required this.onRetry,
    required this.onNext,
  });

  final MissionSessionState state;
  final double scale;
  final VoidCallback onStart;
  final VoidCallback onRetry;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.18),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420 * scale.clamp(1.0, 1.4)),
          child: Padding(
            padding: EdgeInsets.all(24 * scale),
            child: switch (state.status) {
              MissionSessionStatus.intro => _LevelIntroPopup(
                state: state,
                scale: scale,
                onStart: onStart,
              ),
              MissionSessionStatus.won => _LevelResultPopup(
                state: state,
                scale: scale,
                onRetry: onRetry,
                onNext: onNext,
              ),
              MissionSessionStatus.lost => _LevelRetryPopup(
                state: state,
                scale: scale,
                onRetry: onRetry,
              ),
              MissionSessionStatus.playing => const SizedBox.shrink(),
            },
          ),
        ),
      ),
    );
  }
}

class _LevelIntroPopup extends StatelessWidget {
  const _LevelIntroPopup({
    required this.state,
    required this.scale,
    required this.onStart,
  });

  final MissionSessionState state;
  final double scale;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final previewItems = MissionCatalog.resolveItems(
      state.level.mission.targetItemIds.take(8).toList(growable: false),
    );
    final theme = Theme.of(context);

    return _PopupShell(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Рівень ${state.level.number}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFFE8643D),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            state.level.mission.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: (theme.textTheme.headlineSmall?.fontSize ?? 28) * scale,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            state.level.mission.tagline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5B4A3E),
            ),
          ),
          SizedBox(height: 16 * scale),
          Text(
            'Лови лише цільові emoji, тримай серію і закривай мету раніше за таймер.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B4A3E),
            ),
          ),
          SizedBox(height: 18 * scale),
          Wrap(
            spacing: 8 * scale,
            runSpacing: 8 * scale,
            children: previewItems
                .map(
                  (item) => DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7EFE3),
                      borderRadius: BorderRadius.circular(18 * scale),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * scale,
                        vertical: 10 * scale,
                      ),
                      child: Text(item.emoji, style: TextStyle(fontSize: 28 * scale)),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          SizedBox(height: 18 * scale),
          Wrap(
            spacing: 10 * scale,
            runSpacing: 10 * scale,
            children: [
              _PopupMetric(
                label: 'Ціль',
                value: '${state.level.goalScore}',
                scale: scale,
              ),
              _PopupMetric(
                label: 'Час',
                value: '${state.level.durationSeconds}s',
                scale: scale,
              ),
              _PopupMetric(
                label: 'Spawn',
                value: '${state.level.totalSpawnCount}',
                scale: scale,
              ),
            ],
          ),
          SizedBox(height: 22 * scale),
          FilledButton(
            onPressed: onStart,
            child: const Text('Почати рівень'),
          ),
        ],
      ),
    );
  }
}

class _LevelResultPopup extends StatelessWidget {
  const _LevelResultPopup({
    required this.state,
    required this.scale,
    required this.onRetry,
    required this.onNext,
  });

  final MissionSessionState state;
  final double scale;
  final VoidCallback onRetry;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextLabel = state.canAdvance ? 'Наступний рівень' : 'На 1 рівень';

    return _PopupShell(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Рівень ${state.level.number} пройдено',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: (theme.textTheme.headlineSmall?.fontSize ?? 28) * scale,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Мета закрита. Можна або закріпити результат, або рухатися далі.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5B4A3E),
            ),
          ),
          SizedBox(height: 18 * scale),
          Wrap(
            spacing: 10 * scale,
            runSpacing: 10 * scale,
            children: [
              _PopupMetric(label: 'Очки', value: '${state.score}', scale: scale),
              _PopupMetric(
                label: 'Комбо',
                value: 'x${state.bestCombo}',
                scale: scale,
              ),
              _PopupMetric(
                label: 'Залишок',
                value: '${state.remainingSeconds}s',
                scale: scale,
              ),
            ],
          ),
          SizedBox(height: 22 * scale),
          Wrap(
            spacing: 10 * scale,
            runSpacing: 10 * scale,
            children: [
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Пройти знову'),
              ),
              FilledButton(
                onPressed: onNext,
                child: Text(nextLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelRetryPopup extends StatelessWidget {
  const _LevelRetryPopup({
    required this.state,
    required this.scale,
    required this.onRetry,
  });

  final MissionSessionState state;
  final double scale;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _PopupShell(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('😕', style: TextStyle(fontSize: 44 * scale)),
          SizedBox(height: 8 * scale),
          Text(
            'Рівень ${state.level.number} не закрито',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: (theme.textTheme.headlineSmall?.fontSize ?? 28) * scale,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Цього разу не вистачило очок. Спробуй ще раз і втримай серію довше.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5B4A3E),
            ),
          ),
          SizedBox(height: 18 * scale),
          _PopupMetric(label: 'Очки', value: '${state.score}', scale: scale),
          SizedBox(height: 22 * scale),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Спробувати ще'),
          ),
        ],
      ),
    );
  }
}

class _PopupMetric extends StatelessWidget {
  const _PopupMetric({
    required this.label,
    required this.value,
    required this.scale,
  });

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE3),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 10 * scale,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF7E6B5C),
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _PopupShell extends StatelessWidget {
  const _PopupShell({
    required this.scale,
    required this.child,
  });

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0x29000000),
            blurRadius: 32 * scale,
            offset: Offset(0, 20 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: child,
      ),
    );
  }
}

class _CatcherOverlay extends StatelessWidget {
  const _CatcherOverlay({required this.scale, required this.feedback});

  final double scale;
  final CatcherFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final iconColor = switch (feedback) {
      CatcherFeedback.success => const Color(0xFF16C451),
      CatcherFeedback.error => const Color(0xFFFF3B30),
      CatcherFeedback.idle => const Color(0xFF191613),
    };
    final shadowColor = switch (feedback) {
      CatcherFeedback.success => const Color(0xAA16C451),
      CatcherFeedback.error => const Color(0xAAFF3B30),
      CatcherFeedback.idle => const Color(0x3D000000),
    };
    final pulseScale = feedback == CatcherFeedback.idle ? 1.0 : 1.14;

    return AnimatedScale(
      scale: pulseScale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutBack,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        style: TextStyle(
          fontSize: 116 * scale,
          color: iconColor,
          shadows: [
            Shadow(
              color: shadowColor,
              offset: Offset(0, 10 * scale),
              blurRadius: 24 * scale,
            ),
          ],
        ),
        child: const Text('🛒'),
      ),
    );
  }
}
