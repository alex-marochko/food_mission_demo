import 'package:flutter/material.dart';
import 'package:food_mission_demo/src/core/localization/app_strings.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/widgets/popups/popup_frame.dart';

class LevelPausePopup extends StatelessWidget {
  const LevelPausePopup({
    super.key,
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

    return PopupShell(
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
              PopupMetric(
                label: strings.hudScore,
                value: '${state.score}',
                scale: scale,
              ),
              PopupMetric(
                label: strings.popupGoal,
                value: '${state.level.goalScore}',
                scale: scale,
              ),
              PopupMetric(
                label: strings.popupTime,
                value: strings.secondsCompact(state.remainingSeconds),
                scale: scale,
              ),
              PopupMetric(
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
