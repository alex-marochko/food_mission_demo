import 'package:flutter/material.dart';
import 'package:food_mission_demo/src/core/localization/app_strings.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_catalog.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/widgets/popups/popup_frame.dart';

class LevelIntroPopup extends StatelessWidget {
  const LevelIntroPopup({
    super.key,
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

    return PopupShell(
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
              PopupMetric(
                label: strings.popupGoal,
                value: '${state.level.goalScore}',
                scale: scale,
              ),
              PopupMetric(
                label: strings.popupTime,
                value: strings.secondsCompact(state.level.durationSeconds),
                scale: scale,
              ),
              PopupMetric(
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
