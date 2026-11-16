
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/puzzle_data.dart';
import '../models/puzzle.dart';
import '../utils/game_constants.dart';
import '../widgets/game_header.dart';
import '../widgets/answer_button.dart';
import '../widgets/level_progress_bar.dart';
import '../widgets/clue_card.dart';
import '../services/progress_tracker.dart';
import 'challenge_complete_screen.dart';
import 'game_over_screen.dart';
import '../services/sound_service.dart';
import '../services/result_storage_service.dart';

class GameScreen extends StatefulWidget {
  final int challengeNumber;

  const GameScreen({
    super.key,
    this.challengeNumber = 1,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Results for each level in the current challenge.
  final List<Map<String, dynamic>> levelResults = [];

  int levelStartScore = 0;
  int correctAnswers = 0;
  int wrongAttempts = 0;
  // start game 
  int currentLevel = 1;
  int lives = GameConstants.maxLives;
  int score = 0;
  int coins = 0;
  int secondsLeft = GameConstants.timePerPuzzle;

  final List<String> collectedClues = [];
  Timer? gameTimer;

  bool answered = false;
  bool gameEnded = false;

  // The option the player picked correctly (null until a correct answer).
  // It drives the green button and the explanation below the answers.
  String? correctOption;

  // Guards against opening the Game Over / Challenge Complete screen twice.
  bool _navigated = false;

  // True while the hint dialog is open (see _closeHintDialogIfOpen).
  bool _hintDialogOpen = false;

  // True when no puzzle data exists for this challenge (handled safely).
  late final bool _puzzleDataMissing;

  // Only call this when the puzzle data exists (see _puzzleDataMissing).
  Puzzle get currentPuzzle =>
      findPuzzle(widget.challengeNumber, currentLevel)!;

  @override
  void initState() {
    super.initState();
    _puzzleDataMissing = findPuzzle(widget.challengeNumber, 1) == null;
    // Active gameplay: hand audio back to the main game sound (if Sound ON).
    SoundService.instance.resumeGameplaySound();
    if (!_puzzleDataMissing) {
      startTimer();
    }
  }

  void startTimer() {
    gameTimer?.cancel();
    secondsLeft = GameConstants.timePerPuzzle;

    gameTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted || gameEnded || answered) {
          timer.cancel();
          return;
        }

        if (secondsLeft <= 1) {
          timer.cancel();
          wrongAttempts++;
          loseLife();
        } else {
          setState(() {
            secondsLeft--;
          });
        }
      },
    );
  }

  void checkAnswer(String answer) {
    if (answered || gameEnded) return;

    if (answer == currentPuzzle.correctAnswer) {
      gameTimer?.cancel();

      correctAnswers++;

      setState(() {
        answered = true;
        correctOption = answer;
        score += GameConstants.correctAnswerScore;
        coins += GameConstants.correctAnswerCoins;

        if (secondsLeft >=
            GameConstants.fastAnswerThresholdSeconds) {
          score += GameConstants.fastAnswerBonusScore;
        }

        if (!currentPuzzle.isFinalLevel &&
            currentPuzzle.clue != null) {
          collectedClues.add(currentPuzzle.clue!);
        }
      });

      // Long enough for the player to see the green button and read the
      // explanation before the next level (or the completion screen).
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted || gameEnded) return;

        if (currentLevel == GameConstants.levelsPerChallenge) {
          showCompletion();
        } else {
          levelResults.add({
            'level': currentLevel,
            'levelName': GameConstants.levelNames[currentLevel - 1],
            'score': score - levelStartScore,
            'correctAnswers': 1,
            'wrongAttempts': wrongAttempts,
            'completed': true,
          });

          levelStartScore = score;

          setState(() {
            currentLevel++;
            wrongAttempts = 0;
            answered = false;
            correctOption = null;
          });

          startTimer();
        }
      });
    } else {
      wrongAttempts++;
      loseLife();
    }
  }

  void loseLife() {
    if (gameEnded || answered) return;
    SoundService.instance.playWrongSound();//create a sound when loselife

    gameTimer?.cancel();

    if (lives <= 1) {
      SoundService.instance.playGameOverSound();
      setState(() {
        lives = 0;
        gameEnded = true;
      });
      
      showGameOver();
    } else {
      setState(() {
        lives--;
      });

      startTimer();
    }
  }

  void useHint() {
    if (answered || gameEnded) return;

    if (coins < GameConstants.hintCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins for a hint!'),
        ),
      );
      return;
    }

    setState(() {
      coins -= GameConstants.hintCost;
    });

    _hintDialogOpen = true;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hint 💡'),
        content: Text(
          currentPuzzle.hint ?? 'No hint available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    ).then((_) => _hintDialogOpen = false);
  }

  // The timer keeps running while the hint dialog is open. If the game ends
  // meanwhile, close the dialog first so the new screen replaces the game
  // screen and not the dialog.
  void _closeHintDialogIfOpen() {
    if (!_hintDialogOpen) return;
    final gameRoute = ModalRoute.of(context);
    Navigator.of(context).popUntil((route) => route == gameRoute);
    _hintDialogOpen = false;
  }

  Future<void> showCompletion() async {
    if (_navigated) return;
    SoundService.instance.playChallengeCompleteSound();

    // Keep your existing navigation code here

    _navigated = true;
    gameTimer?.cancel();

    setState(() {
      gameEnded = true;
      score += GameConstants.challengeCompleteBonusScore;
      coins += GameConstants.challengeCompleteBonusCoins;
    });
    // Save the result of the final level.
    levelResults.add({
      'level': currentLevel,
      'levelName': GameConstants.levelNames[currentLevel - 1],
      'score': score - levelStartScore,
      'correctAnswers': 1,
      'wrongAttempts': wrongAttempts,
      'completed': true,
    });
    // Save this completed challenge permanently.
    await ResultStorageService.saveChallengeResult({
      'challengeNumber': widget.challengeNumber,
      'score': score,
      'coins': coins,
      'correctAnswers': correctAnswers,
      'wrongAttempts': levelResults.fold<int>(
        0,
        (total, level) => total + (level['wrongAttempts'] as int),
      ),
      'completed': true,
      'levels': levelResults,
      'completedAt': DateTime.now().toIso8601String(),
    });

    // Unlock the next challenge in the challenge list.
    ProgressTracker.markChallengeCompleted(widget.challengeNumber);

    _closeHintDialogIfOpen();

    // Replace the game screen with the Challenge Complete screen. Passing
    // `true` tells the challenge list that this challenge was completed.
    Navigator.of(context).pushReplacement<bool, bool>(
      MaterialPageRoute<bool>(
        builder: (context) => ChallengeCompleteScreen(
          challengeNumber: widget.challengeNumber,
          score: score,
          coins: coins,
        ),
      ),
      result: true,
    );
  }

  void showGameOver() {
    if (_navigated) return;
    _navigated = true;

    gameTimer?.cancel();

    _closeHintDialogIfOpen();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameOverScreen(
          challengeNumber: widget.challengeNumber,
          score: score,
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_puzzleDataMissing) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          title: const Text('Code Breaker'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Puzzle data for this challenge is not available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ),
        ),
      );
    }

    final puzzle = currentPuzzle;

    // Read the available screen dimensions.
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Responsive spacing and font sizes.
    final horizontalPadding =
        (screenWidth * 0.05).clamp(12.0, 32.0).toDouble();

    final questionFontSize =
        (screenWidth * 0.045).clamp(15.0, 20.0).toDouble();

    final timerFontSize =
        (screenWidth * 0.05).clamp(18.0, 24.0).toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Code Breaker'),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Score, lives, level and coins.
              GameHeader(
                level: currentLevel,
                lives: lives,
                score: score,
                coins: coins,
              ),

              const SizedBox(height: 10),

              // Level progress indicator.
              LevelProgressBar(
                currentLevel: currentLevel,
              ),

              const SizedBox(height: 10),

              // Responsive countdown timer.
              Center(
                child: Text(
                  '⏱ $secondsLeft seconds',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondsLeft <= 10
                        ? AppColors.error
                        : AppColors.primary,
                    fontSize: timerFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // The puzzle area takes all the remaining height and scrolls
              // only when its content is taller than the screen.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Current level and puzzle type.
                      Text(
                        'LEVEL $currentLevel · '
                        '${puzzle.type.toUpperCase()}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Responsive question card.
                      Container(
                        padding: EdgeInsets.all(
                          (screenWidth * 0.045)
                              .clamp(12.0, 24.0)
                              .toDouble(),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          puzzle.question,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: questionFontSize,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Show collected clues on the final level.
                      if (puzzle.isFinalLevel) ...[
                        const Text(
                          'COLLECTED CLUES',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        ...List.generate(
                          collectedClues.length,
                          (index) => ClueCard(
                            clueNumber: index + 1,
                            clueValue: collectedClues[index],
                            sourceLevelName:
                                GameConstants.levelNames[index],
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],

                      // Answer options.
                      ...puzzle.options.map(
                        (option) => AnswerButton(
                          text: option,
                          isEnabled: !answered && !gameEnded,
                          // Green only for the correctly answered option.
                          isCorrect: correctOption == option,
                          onPressed: () => checkAnswer(option),
                        ),
                      ),

                      // Explanation: shown only after the correct answer.
                      if (correctOption != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2933),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Correct!',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                puzzle.explanation,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Hint button.
              ElevatedButton.icon(
                onPressed:
                    answered || gameEnded ? null : useHint,
                icon: const Icon(Icons.lightbulb_outline),
                label: Text(
                  'Use Hint (${GameConstants.hintCost} Coins)',
                  textAlign: TextAlign.center,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 14,
                  ),
                  minimumSize: const Size(0, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
