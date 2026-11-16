import 'package:flutter/material.dart';

/// Card that shows one collected clue (used before the final level).
///
/// Display-only: it just shows the text it receives.
///
/// - [clueNumber]: number shown in the circle (for example 1 to 4).
/// - [clueValue]: the clue itself.
/// - [sourceLevelName]: name of the level that gave this clue.
class ClueCard extends StatelessWidget {
  final int clueNumber;
  final String clueValue;
  final String sourceLevelName;

  const ClueCard({
    super.key,
    required this.clueNumber,
    required this.clueValue,
    required this.sourceLevelName,
  });

  // Colors taken from the existing screens (home / challenge selection).
  static const Color _cardColor = Color(0xFF1E2933);
  static const Color _accentColor = Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _accentColor.withValues(alpha: 0.15),
            child: Text(
              '$clueNumber',
              style: const TextStyle(
                color: _accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Expanded keeps long clue text from overflowing the row.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From: $sourceLevelName',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  clueValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
