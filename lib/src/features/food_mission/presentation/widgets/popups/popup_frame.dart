import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PopupShell extends StatelessWidget {
  const PopupShell({super.key, required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0x29000000),
            blurRadius: 32 * scale,
            offset: Offset(0, 20 * scale),
          ),
        ],
      ),
      child: Padding(padding: EdgeInsets.all(24 * scale), child: child),
    );
  }
}

class PopupMetric extends StatelessWidget {
  const PopupMetric({
    super.key,
    required this.label,
    required this.value,
    required this.scale,
  });

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE3),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 10 * scale,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: const Color(0xFF7E6B5C)),
            ),
            SizedBox(height: 4 * scale),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class AnimatedMetricCard extends StatelessWidget {
  const AnimatedMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.scale,
    required this.width,
    required this.accent,
  });

  final String label;
  final String value;
  final double scale;
  final double width;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EFE3),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(
          color: accent.withValues(alpha: 0.22),
          width: 1.5 * scale,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFF7E6B5C),
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: accent,
              fontSize: (theme.textTheme.headlineSmall?.fontSize ?? 24) * scale,
            ),
          ),
        ],
      ),
    );
  }
}

class RewardSweepCard extends StatelessWidget {
  const RewardSweepCard({
    super.key,
    required this.child,
    required this.scale,
    required this.width,
    required this.progress,
    required this.accent,
  });

  final Widget child;
  final double scale;
  final double width;
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final radius = 18 * scale;

    return SizedBox(
      width: width,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          if (progress > 0.001)
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FutureBuilder<ui.FragmentProgram>(
                    future: _RewardSweepProgramLoader.load(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      return CustomPaint(
                        painter: _RewardSweepPainter(
                          program: snapshot.data!,
                          progress: progress,
                          accent: accent,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _RewardSweepProgramLoader {
  static Future<ui.FragmentProgram>? _program;

  static Future<ui.FragmentProgram> load() {
    return _program ??= ui.FragmentProgram.fromAsset(
      'shaders/reward_sweep.frag',
    );
  }
}

class _RewardSweepPainter extends CustomPainter {
  const _RewardSweepPainter({
    required this.program,
    required this.progress,
    required this.accent,
  });

  final ui.FragmentProgram program;
  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final shader = program.fragmentShader()
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, progress)
      ..setFloat(3, Curves.easeOut.transform(progress))
      ..setFloat(4, accent.r / 255)
      ..setFloat(5, accent.g / 255)
      ..setFloat(6, accent.b / 255);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = shader
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _RewardSweepPainter oldDelegate) {
    return oldDelegate.program != program ||
        oldDelegate.progress != progress ||
        oldDelegate.accent != accent;
  }
}
