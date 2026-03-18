import 'package:food_mission_demo/src/core/theme/app_theme.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_catalog.dart';
import 'package:food_mission_demo/src/features/food_mission/domain/mission_definition.dart';
import 'package:flutter/material.dart';

class MissionBriefCard extends StatelessWidget {
  const MissionBriefCard({super.key, required this.mission});

  final MissionDefinition mission;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = _paletteForMission(mission.mood);
    final targets = MissionCatalog.resolveItems(
      mission.targetItemIds.take(5).toList(),
    );

    return Card(
      color: palette.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: palette.badge,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                mission.title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.badgeText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(mission.tagline, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(
              mission.brief,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF5B4A3E),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: targets
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        '${item.emoji} ${item.label}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamilyFallback: emojiFontFallback,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionPalette {
  const _MissionPalette({
    required this.surface,
    required this.badge,
    required this.badgeText,
  });

  final Color surface;
  final Color badge;
  final Color badgeText;
}

_MissionPalette _paletteForMission(MissionMood mood) {
  return switch (mood) {
    MissionMood.vitamins => const _MissionPalette(
      surface: Color(0xFFF3FBE8),
      badge: Color(0xFF5D9E34),
      badgeText: Colors.white,
    ),
    MissionMood.properMeal => const _MissionPalette(
      surface: Color(0xFFFFF4DE),
      badge: Color(0xFFD67B00),
      badgeText: Colors.white,
    ),
    MissionMood.goodbyeDiet => const _MissionPalette(
      surface: Color(0xFFFFEEF2),
      badge: Color(0xFFE14B67),
      badgeText: Colors.white,
    ),
  };
}
