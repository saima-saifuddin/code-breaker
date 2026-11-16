
class Puzzle {
  final int challengeNumber; 
  final int levelNumber; 
  final String type; 
  final String question; 
  final List<String> options; 
  final String correctAnswer; 
  final String explanation; 
  final String difficulty; 
  final String? clue; // the clue this puzzle unlocks (null for Level 5)
  final String? hint; 

  const Puzzle({
    required this.challengeNumber,
    required this.levelNumber,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    this.clue,
    this.hint,
  });

  // Convenience getter: is this the special Level 5 "final code" puzzle?
  bool get isFinalLevel => levelNumber == 5;
}
