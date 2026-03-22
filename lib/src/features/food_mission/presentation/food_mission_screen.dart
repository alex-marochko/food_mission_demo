import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_mission_demo/src/core/audio/game_sfx_player.dart';
import 'package:food_mission_demo/src/core/localization/app_strings.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_cubit.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/level_planner.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/game/food_mission_game.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/widgets/board_overlays.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/widgets/level_popups.dart';

class FoodMissionScreen extends StatefulWidget {
  const FoodMissionScreen({super.key});

  @override
  State<FoodMissionScreen> createState() => _FoodMissionScreenState();
}

class _FoodMissionScreenState extends State<FoodMissionScreen>
    with WidgetsBindingObserver {
  late FoodMissionGame _game;
  final GameSfxPlayer _sfxPlayer = GameSfxPlayer();
  final FocusNode _gameFocusNode = FocusNode(debugLabel: 'food-mission-game');
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = _createGame();
    unawaited(_sfxPlayer.preload());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _gameFocusNode.requestFocus();
      }
    });
  }

  bool _isHandheldWeb(BuildContext context) {
    if (!kIsWeb) {
      return false;
    }

    final platform = Theme.of(context).platform;
    final isMobilePlatform =
        platform == TargetPlatform.android || platform == TargetPlatform.iOS;
    final size = MediaQuery.sizeOf(context);
    return isMobilePlatform || size.shortestSide < 600;
  }

  Future<void> _unlockAudio() => _sfxPlayer.unlockOnUserGesture();

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
    WidgetsBinding.instance.removeObserver(this);
    _gameFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _pauseGameplay();
    }
  }

  FoodMissionGame _createGame() {
    return FoodMissionGame(
      onCatch: (isTarget) {
        unawaited(_sfxPlayer.playCatch(isTarget: isTarget));
        context.read<MissionSessionCubit>().registerCatch(isTarget: isTarget);
      },
      onCountdown: (seconds) =>
          context.read<MissionSessionCubit>().updateRemainingSeconds(seconds),
      onFinish: () =>
          context.read<MissionSessionCubit>().finishLevelFromTimer(),
    );
  }

  MissionSessionState _debugStateFor(MissionSessionStatus status) {
    final level = LevelPlanner.levelFor(switch (status) {
      MissionSessionStatus.intro => 6,
      MissionSessionStatus.playing => 8,
      MissionSessionStatus.won => 17,
      MissionSessionStatus.lost => 14,
    });

    return MissionSessionState(
      level: level,
      status: status,
      totalScore: 1240,
      pendingAwardScore: status == MissionSessionStatus.won ? 188 : 0,
      score: status == MissionSessionStatus.lost ? level.goalScore - 26 : 188,
      goalLocked: status == MissionSessionStatus.won,
      combo: status == MissionSessionStatus.playing ? 4 : 0,
      bestCombo: 8,
      caughtTargets: 14,
      caughtDistractors: 2,
      remainingSeconds: status == MissionSessionStatus.playing ? 23 : 0,
    );
  }

  Future<void> _openPopupPreview(MissionSessionStatus status) async {
    final currentState = context.read<MissionSessionCubit>().state;
    final shouldResumeAfterPreview = currentState.isPlaying && !_isPaused;
    if (shouldResumeAfterPreview) {
      _pauseGameplay();
    }

    final debugState = _debugStateFor(status);

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'debug-popup-preview',
      barrierColor: Colors.black.withValues(alpha: 0.24),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final popupWidth = constraints.maxWidth.clamp(320.0, 460.0);
                  final scale = popupWidth / 420;

                  final child = switch (status) {
                    MissionSessionStatus.intro => LevelIntroPopup(
                      state: debugState,
                      scale: scale,
                      onStart: Navigator.of(dialogContext).pop,
                    ),
                    MissionSessionStatus.won => LevelResultPopup(
                      key: const ValueKey('debug-win-popup'),
                      state: debugState,
                      scale: scale,
                      onRetry: Navigator.of(dialogContext).pop,
                      onNext: Navigator.of(dialogContext).pop,
                    ),
                    MissionSessionStatus.lost => LevelRetryPopup(
                      state: debugState,
                      scale: scale,
                      onRetry: Navigator.of(dialogContext).pop,
                    ),
                    MissionSessionStatus.playing => LevelPausePopup(
                      state: debugState,
                      scale: scale,
                      onResume: Navigator.of(dialogContext).pop,
                      onRetry: Navigator.of(dialogContext).pop,
                    ),
                  };

                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: popupWidth),
                    child: child,
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );

    if (!mounted || !shouldResumeAfterPreview) {
      return;
    }

    final state = context.read<MissionSessionCubit>().state;
    if (state.isPlaying && _isPaused) {
      _resumeGameplay();
    }
  }

  void _pauseGameplay() {
    final state = context.read<MissionSessionCubit>().state;
    if (!mounted || !state.isPlaying || _isPaused) {
      return;
    }

    _game.pauseMission();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeGameplay() {
    if (!_isPaused) {
      return;
    }

    _game.resumeMission();
    setState(() {
      _isPaused = false;
    });
    _gameFocusNode.requestFocus();
  }

  void _retryFromPause() {
    final level = context.read<MissionSessionCubit>().state.level;
    setState(() {
      _isPaused = false;
    });
    context.read<MissionSessionCubit>().retryLevel();
    _game.startMission(level);
    _gameFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final isHandheldWeb = _isHandheldWeb(context);
    return BlocListener<MissionSessionCubit, MissionSessionState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.level != current.level,
      listener: (context, state) {
        if (state.isPlaying) {
          if (!_isPaused) {
            _game.startMission(state.level);
          }
          return;
        }

        if (_isPaused) {
          setState(() {
            _isPaused = false;
          });
        }
        _game.resetMission();
      },
      child: Scaffold(
        body: Stack(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF1DB),
                    Color(0xFFFFFAF4),
                    Color(0xFFFFE4C9),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(_isHandheldWeb(context) ? 0 : 20),
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isHandheldWeb = _isHandheldWeb(context);
                        final boardWidth = isHandheldWeb
                            ? constraints.maxWidth
                            : (constraints.maxHeight *
                                      FoodMissionGame.boardAspectRatio)
                                  .clamp(0.0, constraints.maxWidth);
                        final boardHeight = isHandheldWeb
                            ? constraints.maxHeight
                            : boardWidth / FoodMissionGame.boardAspectRatio;

                        return SizedBox(
                          width: boardWidth,
                          height: boardHeight,
                          child:
                              BlocBuilder<
                                MissionSessionCubit,
                                MissionSessionState
                              >(
                                builder: (context, state) {
                                  return _GameBoard(
                                    game: _game,
                                    state: state,
                                    focusNode: _gameFocusNode,
                                    isPaused: _isPaused,
                                    isHandheldWeb: isHandheldWeb,
                                    onUserInteraction: _unlockAudio,
                                    onPauseRequested: _pauseGameplay,
                                    onResumeRequested: _resumeGameplay,
                                    onRetryFromPause: _retryFromPause,
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
            BlocBuilder<MissionSessionCubit, MissionSessionState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status,
              builder: (context, state) {
                final showLanguageSwitcher = !isHandheldWeb || !state.isPlaying;
                if (!showLanguageSwitcher) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  top: isHandheldWeb ? 10 : 20,
                  left: isHandheldWeb ? null : 20,
                  right: isHandheldWeb ? 10 : null,
                  child: const SafeArea(child: LanguageSwitcher()),
                );
              },
            ),
            if (kDebugMode)
              Positioned(
                top: isHandheldWeb ? 10 : 20,
                right: isHandheldWeb ? 10 : 20,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            _openPopupPreview(MissionSessionStatus.intro),
                        icon: const Icon(Icons.play_circle_outline),
                        label: Text(context.strings.debugIntroPopup),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            _openPopupPreview(MissionSessionStatus.won),
                        icon: const Icon(Icons.emoji_events_outlined),
                        label: Text(context.strings.debugWinPopup),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            _openPopupPreview(MissionSessionStatus.lost),
                        icon: const Icon(Icons.sentiment_dissatisfied_outlined),
                        label: Text(context.strings.debugLosePopup),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            _openPopupPreview(MissionSessionStatus.playing),
                        icon: const Icon(Icons.pause_circle_outline),
                        label: Text(context.strings.debugPausePopup),
                      ),
                    ],
                  ),
                ),
              ),
          ],
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
    required this.isPaused,
    required this.isHandheldWeb,
    required this.onUserInteraction,
    required this.onPauseRequested,
    required this.onResumeRequested,
    required this.onRetryFromPause,
  });

  final FoodMissionGame game;
  final MissionSessionState state;
  final FocusNode focusNode;
  final bool isPaused;
  final bool isHandheldWeb;
  final Future<void> Function() onUserInteraction;
  final VoidCallback onPauseRequested;
  final VoidCallback onResumeRequested;
  final VoidCallback onRetryFromPause;

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
          if (isPaused) {
            return KeyEventResult.handled;
          }
          game.nudgeCatchZone(-0.08);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
            event.logicalKey == LogicalKeyboardKey.keyD) {
          if (isPaused) {
            return KeyEventResult.handled;
          }
          game.nudgeCatchZone(0.08);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          if (isPaused) {
            onResumeRequested();
          } else {
            onPauseRequested();
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardScale = isHandheldWeb
              ? (constraints.maxWidth / 420).clamp(0.92, 1.18)
              : FoodMissionGame.scaleForBoardWidth(constraints.maxWidth);
          final overlayInset = (18 * boardScale).clamp(10.0, 18.0);

          void syncPointer(double dx) {
            focusNode.requestFocus();
            unawaited(onUserInteraction());
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
                    child: BoardHud(scale: boardScale, state: state),
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
                          child: CatcherOverlay(
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
                    child: BoardPopupLayer(
                      state: state,
                      scale: boardScale,
                      onStart: () {
                        unawaited(onUserInteraction());
                        cubit.startCurrentLevel();
                      },
                      onRetry: () {
                        unawaited(onUserInteraction());
                        cubit.retryLevel();
                      },
                      onNext: () {
                        unawaited(onUserInteraction());
                        cubit.openNextLevelIntro();
                      },
                    ),
                  ),
                if (state.isPlaying && isPaused)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.18),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 420 * boardScale.clamp(1.0, 1.4),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(24 * boardScale),
                            child: LevelPausePopup(
                              state: state,
                              scale: boardScale,
                              onResume: () {
                                unawaited(onUserInteraction());
                                onResumeRequested();
                              },
                              onRetry: () {
                                unawaited(onUserInteraction());
                                onRetryFromPause();
                              },
                            ),
                          ),
                        ),
                      ),
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
