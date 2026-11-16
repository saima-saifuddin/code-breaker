import 'package:flutter/material.dart';

import '../services/sound_service.dart';
import '../utils/game_constants.dart';
import 'game_screen.dart';

/// Shown when the player runs out of lives.
///
/// - RETRY starts the same challenge again with a brand-new game state
///   (a new [GameScreen], so no old timer or question state is reused).
/// - BACK TO CHALLENGES returns to the challenge list.
class GameOverScreen extends StatelessWidget {
  final int challengeNumber;
  final int score;

  const GameOverScreen({
    super.key,
    required this.challengeNumber,
    required this.score,
  });

  // Colors taken from the existing screens (home / challenge selection).
  static const Color _cardColor = Color(0xFF1E2933);
  static const Color _accentColor = Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context) {
    // PopScope also stops the sound for system back / back gesture.
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) SoundService.instance.stopGameOverSound();
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
                      Icons.heart_broken,
                      color: AppColors.error,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'GAME OVER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You ran out of lives.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Challenge $challengeNumber',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star,
                                color: _accentColor,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Score: $score',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          SoundService.instance.stopGameOverSound();
                          // Replace this screen with a fresh game so the
                          // player cannot go "back" into the finished one.
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => GameScreen(
                                challengeNumber: challengeNumber,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'RETRY',
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
                    SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          SoundService.instance.stopGameOverSound();
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
