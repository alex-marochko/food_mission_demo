import 'package:flutter/material.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/widgets/popups/level_intro_popup.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/widgets/popups/level_result_popup.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/widgets/popups/level_retry_popup.dart';

class BoardPopupLayer extends StatelessWidget {
  const BoardPopupLayer({
    super.key,
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
              MissionSessionStatus.intro => LevelIntroPopup(
                state: state,
                scale: scale,
                onStart: onStart,
              ),
              MissionSessionStatus.won => LevelResultPopup(
                key: ValueKey(
                  'win-${state.level.number}-${state.score}-${state.totalScore}',
                ),
                state: state,
                scale: scale,
                onRetry: onRetry,
                onNext: onNext,
              ),
              MissionSessionStatus.lost => LevelRetryPopup(
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
