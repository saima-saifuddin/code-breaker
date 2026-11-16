import 'package:flutter/material.dart';

import '../utils/game_constants.dart';

/// Row of dots showing where the player is inside a challenge
/// (for example "level 3 of 5").
///
/// Display-only: the parent passes the values, this widget never changes them.
///
/// - [currentLevel]: current level, 1-based. Values outside the valid range
///   are clamped so the widget never breaks.
/// - [totalLevels]: number of dots. Defaults to
///   [GameConstants.levelsPerChallenge].
class LevelProgressBar extends StatelessWidget {
  final int currentLevel;
  final int totalLevels;

  const LevelProgressBar({
    super.key,
    required this.currentLevel,
    this.totalLevels = GameConstants.levelsPerChallenge,
  });

  // Colors taken from the existing screens (home / challenge selection).
  static const Color _accentColor = Color(0xFF00E5FF);
  static const Color _inactiveColor = Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    // Safe values: at least one dot, and the level stays inside 1..total.
    final int total = totalLevels < 1 ? 1 : totalLevels;
    final int current = currentLevel.clamp(1, total);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final int levelNumber = index + 1;
        final bool isCompleted = levelNumber < current;
        final bool isCurrent = levelNumber == current;

        // Completed = accent, current = accent but wider, upcoming = muted.
        final Color color = (isCompleted || isCurrent)
            ? _accentColor
            : _inactiveColor;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          // The current level is a wider pill so it stands out.
          width: isCurrent ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isCompleted ? color.withValues(alpha: 0.6) : color,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}
