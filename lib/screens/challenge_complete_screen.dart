import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../services/sound_service.dart';
import '../utils/game_constants.dart';
import 'game_screen.dart';
import 'result_screen.dart';

/// Shown when the player finishes all five levels of a challenge.
///
/// - NEXT CHALLENGE opens the next challenge with a fresh game state. It is
///   hidden for the last challenge, so a nonexistent challenge is never
///   opened.
/// - BACK TO CHALLENGES returns to the challenge list.
class ChallengeCompleteScreen extends StatelessWidget {
  final int challengeNumber;
  final int score;
  final int coins;

  const ChallengeCompleteScreen({
    super.key,
    required this.challengeNumber,
    required this.score,
    required this.coins,
  });

  // Colors taken from the existing screens (home / challenge selection).
  static const Color _cardColor = Color(0xFF1E2933);
  static const Color _accentColor = Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context) {
    // The secret code is the answer of the final level (Level 5).
    final secretCode = findPuzzle(
      challengeNumber,
      GameConstants.levelsPerChallenge,
    )?.correctAnswer;

    final bool isLastChallenge =
        challengeNumber >= GameConstants.totalChallenges;

    // PopScope also stops the sound for system back / back gesture.
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) SoundService.instance.stopChallengeCompleteSound();
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // LayoutBuilder gives the visible height so the content can fill the
        // whole screen (centered) and still scroll on very small screens.
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 48
                      ? constraints.maxHeight - 48
                      : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: AppColors.warning,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'CHALLENGE COMPLETE!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Challenge $challengeNumber',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _InfoItem(
                                icon: Icons.star,
                                label: 'Score',
                                value: '$score',
                              ),
                              _InfoItem(
                                icon: Icons.monetization_on,
                                label: 'Coins',
                                value: '$coins',
                              ),
                            ],
                          ),
                          if (secretCode != null) ...[
                            const SizedBox(height: 14),
                            const Divider(color: Color(0xFF334155)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.key,
                                  color: _accentColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Secret Code: $secretCode',
                                    style: const TextStyle(
                                      color: _accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          const Divider(color: Color(0xFF334155)),
                          const SizedBox(height: 6),
                          for (final levelName in GameConstants.levelNames)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    levelName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (isLastChallenge) ...[
                      const Text(
                        'You completed every challenge!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            SoundService.instance.stopChallengeCompleteSound();
                            // Replace this screen so the new game starts with
                            // a fresh state and "back" returns to the list.
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => GameScreen(
                                  challengeNumber: challengeNumber + 1,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text(
                            'NEXT CHALLENGE',
                            style: TextStyle(letterSpacing: 1.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: const Color(0xFF101820),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          SoundService.instance.stopChallengeCompleteSound();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ResultScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('VIEW RESULTS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8C78FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          SoundService.instance.stopChallengeCompleteSound();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.grid_view, color: Colors.white),
                        label: const Text(
                          'BACK TO CHALLENGES',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF334155),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ));
  }
}

/// Small icon + value + label block used for the score and coins summary.
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
