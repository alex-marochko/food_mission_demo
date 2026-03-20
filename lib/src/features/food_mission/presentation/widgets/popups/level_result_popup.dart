import 'package:flutter/material.dart';
import 'package:food_mission_demo/src/core/localization/app_strings.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/widgets/popups/popup_frame.dart';

class LevelResultPopup extends StatefulWidget {
  const LevelResultPopup({
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
  State<LevelResultPopup> createState() => _LevelResultPopupState();
}

class _LevelResultPopupState extends State<LevelResultPopup>
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFlightAnchors());
  }

  @override
  void didUpdateWidget(covariant LevelResultPopup oldWidget) {
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
    final levelScore = widget.state.pendingAwardScore;
    final currentTotal = widget.state.totalScore;
    final targetTotal = currentTotal + levelScore;
    final nextLabel = widget.state.canAdvance
        ? strings.nextLevel
        : strings.backToLevelOne;

    return FadeTransition(
      opacity: _entrance,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1).animate(_entrance),
        child: PopupShell(
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
                  _ResultMetricsBoard(
                    flightLayerKey: _flightLayerKey,
                    scoreCardKey: _scoreCardKey,
                    totalCardKey: _totalCardKey,
                    scale: widget.scale,
                    state: widget.state,
                    strings: strings,
                    sourceValue: sourceValue,
                    totalValue: totalValue,
                    levelScore: levelScore,
                    totalSweep: _totalSweep.value,
                    flight: _flight.value,
                    floatingOpacity: floatingOpacityValue,
                    scoreCardCenter: _scoreCardCenter,
                    totalCardCenter: _totalCardCenter,
                    onLayout: _updateFlightAnchors,
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

class _ResultMetricsBoard extends StatelessWidget {
  const _ResultMetricsBoard({
    required this.flightLayerKey,
    required this.scoreCardKey,
    required this.totalCardKey,
    required this.scale,
    required this.state,
    required this.strings,
    required this.sourceValue,
    required this.totalValue,
    required this.levelScore,
    required this.totalSweep,
    required this.flight,
    required this.floatingOpacity,
    required this.scoreCardCenter,
    required this.totalCardCenter,
    required this.onLayout,
  });

  final GlobalKey flightLayerKey;
  final GlobalKey scoreCardKey;
  final GlobalKey totalCardKey;
  final double scale;
  final MissionSessionState state;
  final AppStrings strings;
  final int sourceValue;
  final int totalValue;
  final int levelScore;
  final double totalSweep;
  final double flight;
  final double floatingOpacity;
  final Offset? scoreCardCenter;
  final Offset? totalCardCenter;
  final VoidCallback onLayout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 206 * scale,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardGap = 14 * scale;
          final cardWidth = (constraints.maxWidth - cardGap) / 2;
          final cardHeight = 92 * scale;

          final scoreOrigin = const Offset(0, 0);
          final comboOrigin = Offset(cardWidth + cardGap, 0);
          final goalOrigin = Offset(0, cardHeight + cardGap);
          final totalOrigin = Offset(cardWidth + cardGap, cardHeight + cardGap);

          WidgetsBinding.instance.addPostFrameCallback((_) => onLayout());

          final resolvedScoreCenter =
              scoreCardCenter ??
              Offset(
                scoreOrigin.dx + (cardWidth / 2),
                scoreOrigin.dy + (cardHeight / 2),
              );
          final resolvedTotalCenter =
              totalCardCenter ??
              Offset(
                totalOrigin.dx + (cardWidth / 2),
                totalOrigin.dy + (cardHeight / 2),
              );
          final flightPosition = Offset.lerp(
            resolvedScoreCenter,
            resolvedTotalCenter,
            flight,
          )!;

          return Stack(
            key: flightLayerKey,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: scoreOrigin.dx,
                top: scoreOrigin.dy,
                child: AnimatedMetricCard(
                  key: scoreCardKey,
                  label: strings.levelScore,
                  value: '$sourceValue',
                  scale: scale,
                  width: cardWidth,
                  accent: const Color(0xFFE8643D),
                ),
              ),
              Positioned(
                left: comboOrigin.dx,
                top: comboOrigin.dy,
                child: AnimatedMetricCard(
                  label: strings.hudCombo,
                  value: 'x${state.bestCombo}',
                  scale: scale,
                  width: cardWidth,
                  accent: const Color(0xFF191613),
                ),
              ),
              Positioned(
                left: goalOrigin.dx,
                top: goalOrigin.dy,
                child: AnimatedMetricCard(
                  label: strings.popupGoal,
                  value: '${state.level.goalScore}',
                  scale: scale,
                  width: cardWidth,
                  accent: const Color(0xFF7E6B5C),
                ),
              ),
              Positioned(
                left: totalOrigin.dx,
                top: totalOrigin.dy,
                child: RewardSweepCard(
                  key: totalCardKey,
                  scale: scale,
                  width: cardWidth,
                  progress: totalSweep,
                  accent: const Color(0xFF16C451),
                  child: AnimatedMetricCard(
                    label: strings.totalScore,
                    value: '$totalValue',
                    scale: scale,
                    width: cardWidth,
                    accent: const Color(0xFF16C451),
                  ),
                ),
              ),
              if (floatingOpacity > 0)
                Positioned(
                  left: flightPosition.dx - (54 * scale),
                  top: flightPosition.dy - (26 * scale),
                  child: Opacity(
                    opacity: floatingOpacity,
                    child: Transform.scale(
                      scale: 1.0 + (0.08 * (1 - flight)),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0x99FFCE4A), Color(0x99FF8B3D)],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x44E8643D),
                              blurRadius: 18 * scale,
                              offset: Offset(0, 10 * scale),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * scale,
                            vertical: 8 * scale,
                          ),
                          child: Text(
                            '+$levelScore',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontSize:
                                  (theme.textTheme.titleMedium?.fontSize ??
                                      16) *
                                  scale,
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
    );
  }
}
