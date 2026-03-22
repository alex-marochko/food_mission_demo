import 'package:flutter/material.dart';
import 'package:food_mission_demo/src/core/localization/app_strings.dart';
import 'package:food_mission_demo/src/core/theme/app_theme.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/widgets/popups/popup_frame.dart';

class LevelRetryPopup extends StatelessWidget {
  const LevelRetryPopup({
    super.key,
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

    return PopupShell(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '😕',
            style: TextStyle(
              fontSize: 44 * scale,
              fontFamily: notoColorEmojiFontFamily,
            ),
          ),
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
            ],
          ),
          SizedBox(height: 22 * scale),
          FilledButton(onPressed: onRetry, child: Text(strings.tryAgain)),
        ],
      ),
    );
  }
}
