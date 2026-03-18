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
    final aspectBoard = AspectRatio(aspectRatio: 0.72, child: board);

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
                final boardWidth = (maxHeight * 0.72).clamp(0.0, maxWidth);
                final boardHeight = boardWidth / 0.72;

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: LayoutBuilder(
          builder: (context, constraints) {
            void syncPointer(double dx) {
              focusNode.requestFocus();
              game.moveCatchZone(dx / constraints.maxWidth);
            }

            return Stack(
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
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _OverlayPill(
                              label: 'Місія',
                              value: state.selectedMission.title,
                            ),
                            const SizedBox(width: 8),
                            _OverlayPill(
                              label: 'Ціль',
                              value: '${state.selectedMission.goalScore}',
                            ),
                            const Spacer(),
                            _OverlayPill(
                              label: 'Час',
                              value: '${state.remainingSeconds}s',
                            ),
                          ],
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: state.isPlaying
                              ? _ComboBanner(combo: state.combo)
                              : _ReadyBanner(state: state),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ValueListenableBuilder<double>(
                      valueListenable: game.catchZoneNotifier,
                      builder: (context, normalizedX, child) {
                        const catcherWidth = 112.0;
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
                              bottom: 18,
                              child: child!,
                            ),
                          ],
                        );
                      },
                      child: const _CatcherOverlay(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CatcherOverlay extends StatelessWidget {
  const _CatcherOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFCE4A), Color(0xFFFF8B3D)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF191613), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            offset: Offset(0, 12),
            blurRadius: 16,
          ),
        ],
      ),
      child: const SizedBox(
        width: 112,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: Text('🛒', style: TextStyle(fontSize: 46)),
          ),
        ),
      ),
    );
  }
}

class _OverlayPill extends StatelessWidget {
  const _OverlayPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: const Color(0xFF7E6B5C),
              ),
            ),
            Text(value, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _ReadyBanner extends StatelessWidget {
  const _ReadyBanner({required this.state});

  final MissionSessionState state;

  @override
  Widget build(BuildContext context) {
    final text = switch (state.status) {
      MissionSessionStatus.ready => 'Перетягни миску та запускай місію',
      MissionSessionStatus.won =>
        'Ціль виконано. Можна показувати reward reveal',
      MissionSessionStatus.lost => 'Ще одна спроба і можна докрутити баланс',
      MissionSessionStatus.playing => '',
    };

    return Align(
      alignment: Alignment.bottomLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Text(text, style: Theme.of(context).textTheme.titleMedium),
        ),
      ),
    );
  }
}

class _ComboBanner extends StatelessWidget {
  const _ComboBanner({required this.combo});

  final int combo;

  @override
  Widget build(BuildContext context) {
    final title = combo >= 5
        ? 'Hot streak x$combo'
        : combo >= 3
        ? 'Combo x$combo'
        : 'Лови цільові emoji';

    return Align(
      alignment: Alignment.bottomLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF191613), Color(0xFFE8643D)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
