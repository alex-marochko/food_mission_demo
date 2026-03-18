import 'package:flame/game.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_cubit.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_catalog.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/game/food_mission_game.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/widgets/mission_brief_card.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/widgets/mission_selector.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/widgets/mission_status_panel.dart';
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
      _game.startMission(state.selectedMission);
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
      onFinish: () => context.read<MissionSessionCubit>().finishSession(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MissionSessionCubit, MissionSessionState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.selectedMission != current.selectedMission,
      listener: (context, state) {
        if (state.status == MissionSessionStatus.playing) {
          _game.startMission(state.selectedMission);
        } else if (!state.isPlaying) {
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: BlocBuilder<MissionSessionCubit, MissionSessionState>(
                    builder: (context, state) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 980;
                          final gamePanel = _GamePanel(
                            game: _game,
                            state: state,
                            useFlexibleBoard: isWide,
                            focusNode: _gameFocusNode,
                          );
                          final sidebar = _Sidebar(
                            state: state,
                            showMissionBrief: isWide,
                          );

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 6, child: gamePanel),
                                const SizedBox(width: 18),
                                SizedBox(
                                  width: 380,
                                  child: SingleChildScrollView(child: sidebar),
                                ),
                              ],
                            );
                          }

                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                gamePanel,
                                const SizedBox(height: 18),
                                sidebar,
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GamePanel extends StatelessWidget {
  const _GamePanel({
    required this.game,
    required this.state,
    required this.useFlexibleBoard,
    required this.focusNode,
  });

  final FoodMissionGame game;
  final MissionSessionState state;
  final bool useFlexibleBoard;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final board = _GameBoard(game: game, state: state, focusNode: focusNode);
    final aspectBoard = AspectRatio(
      aspectRatio: FoodMissionGame.boardAspectRatio,
      child: board,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Promo Playground', style: theme.textTheme.displaySmall),
        const SizedBox(height: 10),
        Text(
          'Flame-powered демка для gamified e-com місій. '
          'Лови правильні food emoji, тримай combo і закривай ціль по очках.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF5B4A3E),
          ),
        ),
        const SizedBox(height: 18),
        if (!useFlexibleBoard) ...[
          MissionBriefCard(mission: state.selectedMission),
          const SizedBox(height: 18),
        ],
        if (useFlexibleBoard)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final maxHeight = constraints.maxHeight;
                final boardWidth = (maxHeight * FoodMissionGame.boardAspectRatio)
                    .clamp(0.0, maxWidth);
                final boardHeight = boardWidth / FoodMissionGame.boardAspectRatio;

                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: boardWidth,
                    height: boardHeight,
                    child: board,
                  ),
                );
              },
            ),
          )
        else
          aspectBoard,
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.state, required this.showMissionBrief});

  final MissionSessionState state;
  final bool showMissionBrief;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MissionSessionCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showMissionBrief) ...[
          MissionBriefCard(mission: state.selectedMission),
          const SizedBox(height: 18),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Місії', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                MissionSelector(
                  missions: MissionCatalog.missions,
                  selectedMission: state.selectedMission,
                  enabled: !state.isPlaying,
                  onSelected: cubit.selectMission,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        MissionStatusPanel(
          state: state,
          onPrimaryAction: () {
            if (state.isPlaying) {
              cubit.restartSession();
              return;
            }
            cubit.startSession();
          },
        ),
      ],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BoardTopOverlay(
                          scale: boardScale,
                          maxWidth: constraints.maxWidth - (overlayInset * 2),
                          missionTitle: state.selectedMission.title,
                          goalScore: state.selectedMission.goalScore,
                          remainingSeconds: state.remainingSeconds,
                        ),
                      ],
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
                            final catcherWidth = 112 * boardScale;
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
              ],
            ),
          );
        },
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
    final gradient = switch (feedback) {
      CatcherFeedback.success => const [Color(0xFF68D97F), Color(0xFF2FB863)],
      CatcherFeedback.error => const [Color(0xFFFF8A80), Color(0xFFE24D43)],
      CatcherFeedback.idle => const [Color(0xFFFFCE4A), Color(0xFFFF8B3D)],
    };
    final glowColor = switch (feedback) {
      CatcherFeedback.success => const Color(0x663CCB69),
      CatcherFeedback.error => const Color(0x66E24D43),
      CatcherFeedback.idle => const Color(0x29000000),
    };
    final pulseScale = feedback == CatcherFeedback.idle ? 1.0 : 1.08;

    return AnimatedScale(
      scale: pulseScale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(24 * scale),
          border: Border.all(color: const Color(0xFF191613), width: 3 * scale),
          boxShadow: [
            BoxShadow(
              color: glowColor,
              offset: Offset(0, 12 * scale),
              blurRadius: 18 * scale,
            ),
          ],
        ),
        child: SizedBox(
          width: 112 * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 12 * scale,
            ),
            child: Center(
              child: Text('🛒', style: TextStyle(fontSize: 46 * scale)),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardTopOverlay extends StatelessWidget {
  const _BoardTopOverlay({
    required this.scale,
    required this.maxWidth,
    required this.missionTitle,
    required this.goalScore,
    required this.remainingSeconds,
  });

  final double scale;
  final double maxWidth;
  final String missionTitle;
  final int goalScore;
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final pills = [
      _OverlayPill(label: 'Місія', value: missionTitle, scale: scale),
      _OverlayPill(label: 'Ціль', value: '$goalScore', scale: scale),
      _OverlayPill(label: 'Час', value: '${remainingSeconds}s', scale: scale),
    ];

    if (maxWidth < 360) {
      return Wrap(
        spacing: 8 * scale,
        runSpacing: 8 * scale,
        children: pills,
      );
    }

    return Row(
      children: [
        pills[0],
        SizedBox(width: 8 * scale),
        pills[1],
        const Spacer(),
        pills[2],
      ],
    );
  }
}

class _OverlayPill extends StatelessWidget {
  const _OverlayPill({
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
        color: Colors.white.withValues(alpha: 0.82),
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
