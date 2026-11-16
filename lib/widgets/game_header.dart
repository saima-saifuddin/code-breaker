import 'package:flutter/material.dart';

import '../utils/game_constants.dart';

/// Top status bar of the game screen.
///
/// Display-only: it shows the values given by its parent and contains no
/// gameplay logic.
///
/// - [level]: current level number (1-based).
/// - [lives]: lives the player has left. Shown as hearts; empty hearts
///   fill up to [GameConstants.maxLives].
/// - [score]: current score.
/// - [coins]: current coin balance.
class GameHeader extends StatelessWidget {
  final int level;
  final int lives;
  final int score;
  final int coins;

  const GameHeader({
    super.key,
    required this.level,
    required this.lives,
    required this.score,
    required this.coins,
  });

  // Colors taken from the existing screens (home / challenge selection).
  static const Color _cardColor = Color(0xFF1E2933);
  static const Color _accentColor = Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(
            icon: Icons.layers,
            label: 'Lv $level',
            iconColor: _accentColor,
          ),
          _LivesRow(lives: lives),
          _StatItem(
            icon: Icons.star,
            label: '$score',
            iconColor: _accentColor,
          ),
          _StatItem(
            icon: Icons.monetization_on,
            label: '$coins',
            iconColor: _accentColor,
          ),
        ],
      ),
    );
  }
}

/// Row of hearts: filled for remaining lives, outlined for lost lives.
class _LivesRow extends StatelessWidget {
  final int lives;

  const _LivesRow({required this.lives});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(GameConstants.maxLives, (index) {
        final isFilled = index < lives;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            isFilled ? Icons.favorite : Icons.favorite_border,
            color: isFilled ? AppColors.error : AppColors.locked,
            size: 20,
          ),
        );
      }),
    );
  }
}

/// Small icon + text pair used for level, score and coins.
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
