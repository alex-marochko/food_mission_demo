import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_mission_demo/src/core/audio/game_sfx_player.dart';
import 'package:food_mission_demo/src/core/localization/app_locale_cubit.dart';
import 'package:food_mission_demo/src/core/localization/app_strings.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_cubit.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/level_planner.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_catalog.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/game/food_mission_game.dart';

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
    _sfxPlayer.preload();
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
    WidgetsBinding.instance.removeObserver(this);
    _gameFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      return;
    }
    _pauseGameplay();
  }

  FoodMissionGame _createGame() {
    return FoodMissionGame(
      onCatch: (isTarget) {
        _sfxPlayer.playCatch(isTarget: isTarget);
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
                    MissionSessionStatus.intro => _LevelIntroPopup(
                      state: debugState,
                      scale: scale,
                      onStart: Navigator.of(dialogContext).pop,
                    ),
                    MissionSessionStatus.won => _LevelResultPopup(
                      key: const ValueKey('debug-win-popup'),
                      state: debugState,
                      scale: scale,
                      onRetry: Navigator.of(dialogContext).pop,
                      onNext: Navigator.of(dialogContext).pop,
                    ),
                    MissionSessionStatus.lost => _LevelRetryPopup(
                      state: debugState,
                      scale: scale,
                      onRetry: Navigator.of(dialogContext).pop,
                    ),
                    MissionSessionStatus.playing => _LevelPausePopup(
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
    return BlocListener<MissionSessionCubit, MissionSessionState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.level != current.level,
      listener: (context, state) {
        if (state.isPlaying) {
          if (!_isPaused) {
            _game.startMission(state.level);
          }
        } else {
          if (_isPaused) {
            setState(() {
              _isPaused = false;
            });
          }
          _game.resetMission();
        }
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
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        final maxHeight = constraints.maxHeight;
                        final boardWidth =
                            (maxHeight * FoodMissionGame.boardAspectRatio)
                                .clamp(0.0, maxWidth);
                        final boardHeight =
                            boardWidth / FoodMissionGame.boardAspectRatio;

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
            const Positioned(
              top: 20,
              left: 20,
              child: SafeArea(child: _LanguageSwitcher()),
            ),
            if (kDebugMode)
              Positioned(
                top: 20,
                right: 20,
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
    required this.onPauseRequested,
    required this.onResumeRequested,
    required this.onRetryFromPause,
  });

  final FoodMissionGame game;
  final MissionSessionState state;
  final FocusNode focusNode;
  final bool isPaused;
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
                            child: _LevelPausePopup(
                              state: state,
                              scale: boardScale,
                              onResume: onResumeRequested,
                              onRetry: onRetryFromPause,
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

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    final selectedLocale = context.watch<AppLocaleCubit>().state;
    final strings = context.strings;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SegmentedButton<AppLocaleOption>(
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          segments: [
            ButtonSegment(
              value: AppLocaleOption.ukrainian,
              label: Text(strings.languageUaShort),
            ),
            ButtonSegment(
              value: AppLocaleOption.english,
              label: Text(strings.languageEnShort),
            ),
          ],
          selected: {selectedLocale},
          onSelectionChanged: (selection) {
            context.read<AppLocaleCubit>().select(selection.first);
          },
        ),
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
    final strings = context.strings;
    final pills = [
      _HudPill(
        label: strings.hudLevel,
        value: '${state.level.number}',
        scale: scale,
      ),
      _HudPill(
        label: strings.hudMission,
        value: strings.missionTitle(state.level.mission.id),
        scale: scale,
      ),
      _HudPill(label: strings.hudScore, value: '${state.score}', scale: scale),
      _HudPill(
        label: strings.hudGoal,
        value: '${state.level.goalScore}',
        scale: scale,
      ),
      _HudPill(
        label: strings.hudTime,
        value: strings.secondsCompact(state.remainingSeconds),
        scale: scale,
      ),
      _HudPill(label: strings.hudCombo, value: 'x${state.combo}', scale: scale),
    ];

    return Align(
      alignment: Alignment.topLeft,
      child: Wrap(spacing: 8 * scale, runSpacing: 8 * scale, children: pills),
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
                key: ValueKey(
                  'win-${state.level.number}-${state.score}-${state.totalScore}',
                ),
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
      state.level.mission.targetItemIds,
    );
    final theme = Theme.of(context);
    final strings = context.strings;

    return _PopupShell(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.levelNumber(state.level.number),
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFFE8643D),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            strings.missionTitle(state.level.mission.id),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: (theme.textTheme.headlineSmall?.fontSize ?? 28) * scale,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            strings.missionTagline(state.level.mission.id),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5B4A3E),
            ),
          ),
          SizedBox(height: 16 * scale),
          Text(
            strings.introInstructions,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B4A3E),
            ),
          ),
          SizedBox(height: 14 * scale),
          Text(
            strings.introTargetsLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFF7E6B5C),
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
                      child: Text(
                        item.emoji,
                        style: TextStyle(fontSize: 28 * scale),
                      ),
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
                label: strings.popupGoal,
                value: '${state.level.goalScore}',
                scale: scale,
              ),
              _PopupMetric(
                label: strings.popupTime,
                value: strings.secondsCompact(state.level.durationSeconds),
                scale: scale,
              ),
              _PopupMetric(
                label: strings.popupSpawn,
                value: '${state.level.totalSpawnCount}',
                scale: scale,
              ),
            ],
          ),
          SizedBox(height: 22 * scale),
          FilledButton(onPressed: onStart, child: Text(strings.startLevel)),
        ],
      ),
    );
  }
}

class _LevelResultPopup extends StatefulWidget {
  const _LevelResultPopup({
    super.key,
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
  State<_LevelResultPopup> createState() => _LevelResultPopupState();
}

class _LevelResultPopupState extends State<_LevelResultPopup>
    with SingleTickerProviderStateMixin {
  final GlobalKey _flightLayerKey = GlobalKey();
  final GlobalKey _scoreCardKey = GlobalKey();
  final GlobalKey _totalCardKey = GlobalKey();

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..forward();

  late final Animation<double> _entrance = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.18, curve: Curves.easeOutBack),
  );
  late final Animation<double> _scoreBuild = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.32, 0.52, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _floatingOpacity =
      TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 0.2),
        TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.6),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 0.2),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.46, 0.88, curve: Curves.easeInOut),
        ),
      );
  late final Animation<double> _flight = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.56, 0.78, curve: Curves.easeInOutCubic),
  );
  late final Animation<double> _totalBuild = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.76, 0.9, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _totalSweep = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.89, 1.0, curve: Curves.easeInOutCubicEmphasized),
  );

  Offset? _scoreCardCenter;
  Offset? _totalCardCenter;

  @override
  void initState() {
    super.initState();
    _RewardSweepProgramLoader.load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFlightAnchors());
  }

  @override
  void didUpdateWidget(covariant _LevelResultPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFlightAnchors());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateFlightAnchors() {
    if (!mounted) {
      return;
    }

    final layerContext = _flightLayerKey.currentContext;
    final scoreContext = _scoreCardKey.currentContext;
    final totalContext = _totalCardKey.currentContext;
    if (layerContext == null || scoreContext == null || totalContext == null) {
      return;
    }

    final layerBox = layerContext.findRenderObject() as RenderBox?;
    final scoreBox = scoreContext.findRenderObject() as RenderBox?;
    final totalBox = totalContext.findRenderObject() as RenderBox?;
    if (layerBox == null || scoreBox == null || totalBox == null) {
      return;
    }

    final nextScoreCenter = scoreBox.localToGlobal(
      scoreBox.size.center(Offset.zero),
      ancestor: layerBox,
    );
    final nextTotalCenter = totalBox.localToGlobal(
      totalBox.size.center(Offset.zero),
      ancestor: layerBox,
    );

    if (_scoreCardCenter == nextScoreCenter &&
        _totalCardCenter == nextTotalCenter) {
      return;
    }

    setState(() {
      _scoreCardCenter = nextScoreCenter;
      _totalCardCenter = nextTotalCenter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.strings;
    final nextLabel = widget.state.canAdvance
        ? strings.nextLevel
        : strings.backToLevelOne;
    final levelScore = widget.state.pendingAwardScore;
    final currentTotal = widget.state.totalScore;
    final targetTotal = currentTotal + levelScore;

    return FadeTransition(
      opacity: _entrance,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1).animate(_entrance),
        child: _PopupShell(
          scale: widget.scale,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final sourceValue = IntTween(
                begin: 0,
                end: levelScore,
              ).evaluate(_scoreBuild);
              final totalValue = _controller.value < 0.76
                  ? currentTotal
                  : IntTween(
                      begin: currentTotal,
                      end: targetTotal,
                    ).evaluate(_totalBuild);

              final floatingOpacityValue = _floatingOpacity.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.levelCompleted(widget.state.level.number),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize:
                          (theme.textTheme.headlineSmall?.fontSize ?? 28) *
                          widget.scale,
                    ),
                  ),
                  SizedBox(height: 10 * widget.scale),
                  Text(
                    strings.winSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF5B4A3E),
                    ),
                  ),
                  SizedBox(height: 20 * widget.scale),
                  SizedBox(
                    height: 206 * widget.scale,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cardGap = 14 * widget.scale;
                        final cardWidth = (constraints.maxWidth - cardGap) / 2;
                        final cardHeight = 92 * widget.scale;

                        final scoreOrigin = const Offset(0, 0);
                        final comboOrigin = Offset(cardWidth + cardGap, 0);
                        final goalOrigin = Offset(0, cardHeight + cardGap);
                        final totalOrigin = Offset(
                          cardWidth + cardGap,
                          cardHeight + cardGap,
                        );

                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _updateFlightAnchors(),
                        );

                        final scoreCenter =
                            _scoreCardCenter ??
                            Offset(
                              scoreOrigin.dx + (cardWidth / 2),
                              scoreOrigin.dy + (cardHeight / 2),
                            );
                        final totalCenter =
                            _totalCardCenter ??
                            Offset(
                              totalOrigin.dx + (cardWidth / 2),
                              totalOrigin.dy + (cardHeight / 2),
                            );
                        final flightPosition = Offset.lerp(
                          scoreCenter,
                          totalCenter,
                          _flight.value,
                        )!;

                        return Stack(
                          key: _flightLayerKey,
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: scoreOrigin.dx,
                              top: scoreOrigin.dy,
                              child: _AnimatedMetricCard(
                                key: _scoreCardKey,
                                label: strings.levelScore,
                                value: '$sourceValue',
                                scale: widget.scale,
                                width: cardWidth,
                                accent: const Color(0xFFE8643D),
                              ),
                            ),
                            Positioned(
                              left: comboOrigin.dx,
                              top: comboOrigin.dy,
                              child: _AnimatedMetricCard(
                                label: strings.hudCombo,
                                value: 'x${widget.state.bestCombo}',
                                scale: widget.scale,
                                width: cardWidth,
                                accent: const Color(0xFF191613),
                              ),
                            ),
                            Positioned(
                              left: goalOrigin.dx,
                              top: goalOrigin.dy,
                              child: _AnimatedMetricCard(
                                label: strings.popupGoal,
                                value: '${widget.state.level.goalScore}',
                                scale: widget.scale,
                                width: cardWidth,
                                accent: const Color(0xFF7E6B5C),
                              ),
                            ),
                            Positioned(
                              left: totalOrigin.dx,
                              top: totalOrigin.dy,
                              child: _RewardSweepCard(
                                key: _totalCardKey,
                                scale: widget.scale,
                                width: cardWidth,
                                progress: _totalSweep.value,
                                accent: const Color(0xFF16C451),
                                child: _AnimatedMetricCard(
                                  label: strings.totalScore,
                                  value: '$totalValue',
                                  scale: widget.scale,
                                  width: cardWidth,
                                  accent: const Color(0xFF16C451),
                                ),
                              ),
                            ),
                            if (floatingOpacityValue > 0)
                              Positioned(
                                left: flightPosition.dx - (54 * widget.scale),
                                top: flightPosition.dy - (26 * widget.scale),
                                child: Opacity(
                                  opacity: floatingOpacityValue,
                                  child: Transform.scale(
                                    scale: 1.0 + (0.08 * (1 - _flight.value)),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0x99FFCE4A),
                                            Color(0x99FF8B3D),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0x44E8643D),
                                            blurRadius: 18 * widget.scale,
                                            offset: Offset(
                                              0,
                                              10 * widget.scale,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12 * widget.scale,
                                          vertical: 8 * widget.scale,
                                        ),
                                        child: Text(
                                          '+$levelScore',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontSize:
                                                    (theme
                                                            .textTheme
                                                            .titleMedium
                                                            ?.fontSize ??
                                                        16) *
                                                    widget.scale,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 22 * widget.scale),
                  Wrap(
                    spacing: 10 * widget.scale,
                    runSpacing: 10 * widget.scale,
                    children: [
                      OutlinedButton(
                        onPressed: widget.onRetry,
                        child: Text(strings.retryLevel),
                      ),
                      FilledButton(
                        onPressed: widget.onNext,
                        child: Text(nextLabel),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
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
    final strings = context.strings;

    return _PopupShell(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('😕', style: TextStyle(fontSize: 44 * scale)),
          SizedBox(height: 8 * scale),
          Text(
            strings.levelFailed(state.level.number),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: (theme.textTheme.headlineSmall?.fontSize ?? 28) * scale,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            strings.loseSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5B4A3E),
            ),
          ),
          SizedBox(height: 18 * scale),
          Wrap(
            spacing: 10 * scale,
            runSpacing: 10 * scale,
            children: [
              _PopupMetric(
                label: strings.hudScore,
                value: '${state.score}',
                scale: scale,
              ),
              _PopupMetric(
                label: strings.popupGoal,
                value: '${state.level.goalScore}',
                scale: scale,
              ),
            ],
          ),
          SizedBox(height: 22 * scale),
          FilledButton(onPressed: onRetry, child: Text(strings.tryAgain)),
        ],
      ),
    );
  }
}

class _LevelPausePopup extends StatelessWidget {
  const _LevelPausePopup({
    required this.state,
    required this.scale,
    required this.onResume,
    required this.onRetry,
  });

  final MissionSessionState state;
  final double scale;
  final VoidCallback onResume;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.strings;

    return _PopupShell(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⏸️', style: TextStyle(fontSize: 44 * scale)),
          SizedBox(height: 8 * scale),
          Text(
            strings.pauseTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: (theme.textTheme.headlineSmall?.fontSize ?? 28) * scale,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            strings.pauseSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5B4A3E),
            ),
          ),
          SizedBox(height: 18 * scale),
          Wrap(
            spacing: 10 * scale,
            runSpacing: 10 * scale,
            children: [
              _PopupMetric(
                label: strings.hudScore,
                value: '${state.score}',
                scale: scale,
              ),
              _PopupMetric(
                label: strings.popupGoal,
                value: '${state.level.goalScore}',
                scale: scale,
              ),
              _PopupMetric(
                label: strings.popupTime,
                value: strings.secondsCompact(state.remainingSeconds),
                scale: scale,
              ),
              _PopupMetric(
                label: strings.hudCombo,
                value: 'x${state.combo}',
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
                child: Text(strings.retryLevel),
              ),
              FilledButton(
                onPressed: onResume,
                child: Text(strings.continueAction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class _RewardSweepProgramLoader {
  static Future<ui.FragmentProgram>? _program;

  static Future<ui.FragmentProgram> load() {
    return _program ??= ui.FragmentProgram.fromAsset(
      'shaders/reward_sweep.frag',
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
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: const Color(0xFF7E6B5C)),
            ),
            SizedBox(height: 4 * scale),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _RewardSweepCard extends StatelessWidget {
  const _RewardSweepCard({
    super.key,
    required this.child,
    required this.scale,
    required this.width,
    required this.progress,
    required this.accent,
  });

  final Widget child;
  final double scale;
  final double width;
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final radius = 18 * scale;

    return SizedBox(
      width: width,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          if (progress > 0.001)
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FutureBuilder<ui.FragmentProgram>(
                    future: _RewardSweepProgramLoader.load(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      return CustomPaint(
                        painter: _RewardSweepPainter(
                          program: snapshot.data!,
                          progress: progress,
                          accent: accent,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RewardSweepPainter extends CustomPainter {
  const _RewardSweepPainter({
    required this.program,
    required this.progress,
    required this.accent,
  });

  final ui.FragmentProgram program;
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final shader = program.fragmentShader()
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, progress)
      ..setFloat(3, Curves.easeOut.transform(progress))
      ..setFloat(4, accent.r / 255)
      ..setFloat(5, accent.g / 255)
      ..setFloat(6, accent.b / 255);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _RewardSweepPainter oldDelegate) {
    return oldDelegate.program != program ||
        oldDelegate.progress != progress ||
        oldDelegate.accent != accent;
  }
}

class _AnimatedMetricCard extends StatelessWidget {
  const _AnimatedMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.scale,
    required this.width,
    required this.accent,
  });

  final String label;
  final String value;
  final double scale;
  final double width;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE3),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(
          color: accent.withValues(alpha: 0.22),
          width: 1.5 * scale,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFF7E6B5C),
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: accent,
              fontSize: (theme.textTheme.headlineSmall?.fontSize ?? 24) * scale,
            ),
          ),
        ],
      ),
    );
  }
}

class _PopupShell extends StatelessWidget {
  const _PopupShell({required this.scale, required this.child});

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
      child: Padding(padding: EdgeInsets.all(24 * scale), child: child),
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
