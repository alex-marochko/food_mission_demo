import 'package:food_mission_demo/src/features/food_mission/application/mission_session_state.dart';
import 'package:flutter/material.dart';

class MissionStatusPanel extends StatelessWidget {
  const MissionStatusPanel({
    super.key,
    required this.state,
    required this.onPrimaryAction,
  });

  final MissionSessionState state;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFinished = state.isFinished;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Правила', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              'Перетягуй кошик по горизонталі та лови лише цільові emoji. '
              'За серію правильних ловів росте combo і множаться очки.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: state.progressToGoal,
                backgroundColor: const Color(0xFFF0E3D4),
                color: state.achievedGoal
                    ? const Color(0xFF5D9E34)
                    : const Color(0xFFE8643D),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricChip(
                  label: 'Мета',
                  value: '${state.selectedMission.goalScore}',
                ),
                _MetricChip(label: 'Очки', value: '${state.score}'),
                _MetricChip(label: 'Комбо', value: 'x${state.bestCombo}'),
                _MetricChip(
                  label: 'Таймер',
                  value: '${state.remainingSeconds}s',
                ),
              ],
            ),
            const SizedBox(height: 22),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: Text(
                isFinished
                    ? state.status == MissionSessionStatus.won
                          ? 'Місію виконано. Промо-модуль може відкривати нагороду.'
                          : 'Не дотягнув до цілі. Тут можна давати soft retry або bonus spin.'
                    : state.isPlaying
                    ? 'Гра триває. Лови таргет і не розбивай серію.'
                    : 'Обери місію й натисни старт.',
                key: ValueKey(state.status),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF5B4A3E),
                ),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: onPrimaryAction,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                backgroundColor: const Color(0xFF191613),
                foregroundColor: Colors.white,
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              child: Text(switch (state.status) {
                MissionSessionStatus.ready => 'Почати місію',
                MissionSessionStatus.playing => 'Рестарт місії',
                MissionSessionStatus.won => 'Запустити ще раз',
                MissionSessionStatus.lost => 'Спробувати ще',
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFF7E6B5C),
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}
