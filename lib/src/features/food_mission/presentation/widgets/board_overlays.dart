import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_mission_demo/src/core/localization/app_locale_cubit.dart';
import 'package:food_mission_demo/src/core/localization/app_strings.dart';
import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:food_mission_demo/src/features/food_mission/presentation/game/food_mission_game.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

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

class BoardHud extends StatelessWidget {
  const BoardHud({super.key, required this.scale, required this.state});

  final double scale;
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

class CatcherOverlay extends StatelessWidget {
  const CatcherOverlay({
    super.key,
    required this.scale,
    required this.feedback,
  });

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
